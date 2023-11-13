import 'dart:developer';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../components/alert_dialog.dart';
import 'community_feed_viewmodel.dart';

class AmityFileInfoWithUploadStatus {
  AmityFileInfo? fileInfo;
  bool isComplete = false;
  File? file;

  void addFile(AmityFileInfo amityFileInfo) {
    fileInfo = amityFileInfo;
    isComplete = true;
  }

  void addFilePath(File file) {
    this.file = file;
  }
}

class CreatePostVM extends ChangeNotifier {
  final TextEditingController textEditingController =
      TextEditingController(text: "");
  final ImagePicker _picker = ImagePicker();
  List<UploadStatus<AmityImage>> amityImages = <UploadStatus<AmityImage>>[];
  AmityFileInfoWithUploadStatus? amityVideo;
  bool isloading = false;
  bool isUploading = false;
  AmityPost? lastPost;

  void inits() {
    textEditingController.clear();
    amityVideo = null;
    amityImages.clear();
    isUploading = false;
    lastPost = null;
  }

  bool isNotSelectedImageYet() {
    if (amityImages.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  bool isNotSelectVideoYet() {
    if (amityVideo == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addFiles() async {
    if (isNotSelectVideoYet()) {
      final List<XFile> images =
          await _picker.pickMultiImage(imageQuality: 100);
      if (images.isNotEmpty) {
        for (var image in images) {
          uploadImage(File(image.path));
        }
      }
    }
  }

  Future<void> addFileFromCamera() async {
    if (isNotSelectVideoYet()) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        uploadImage(File(image.path));
      }
    }
  }

  void uploadImage(File imageFile) {
    amityImages.add(UploadStatus<AmityImage>(path: imageFile.path));
    notifyListeners();
    isUploading = true;
    AmityCoreClient.newFileRepository()
        .uploadImage(imageFile, isFullImage: false)
        .stream
        .listen((amityUploadResult) {
      amityUploadResult.when(
        progress: (uploadInfo, cancelToken) {
          // int progress = uploadInfo.getProgressPercentage();
        },
        complete: (file) {
          //check if the upload result is complete

          final AmityImage uploadedImage = file;
          int idx = amityImages
              .indexWhere((element) => element.path == imageFile.path);
          if (idx != -1) {
            final uploadStatus = amityImages[idx];
            amityImages[idx] =
                uploadStatus.copyWith(data: uploadedImage, isComplete: true);
            notifyListeners();
          }
          _checkUploadImage();
        },
        error: (error) async {
          final AmityException amityException = error;

          log("error: $error");
          await AmityDialog().showAlertErrorDialog(
              title: "Error ${amityException.code}!",
              message: amityException.message);
          notifyListeners();
        },
        cancel: () {
          //upload is cancelled
          int idx = amityImages
              .indexWhere((element) => element.path == imageFile.path);
          if (idx != -1) {
            amityImages.removeAt(idx);
            notifyListeners();
          }
        },
      );
    });
  }

  void _checkUploadImage(){
    bool uploading = false;
    for(final data in amityImages){
      if(!data.isComplete){
        uploading = true;
      }
    }
    isUploading = uploading;
    notifyListeners();
  }

  Future<void> addVideo() async {
    if (isNotSelectedImageYet()) {
      try {
        final XFile? video =
            await _picker.pickVideo(source: ImageSource.gallery);

        if (video != null) {
          isUploading = true;
          var fileWithStatus = AmityFileInfoWithUploadStatus();
          amityVideo = fileWithStatus;
          amityVideo!.file = File(video.path);

          notifyListeners();
          AmityCoreClient.newFileRepository()
              .uploadVideo(File(video.path))
              .stream
              .listen(onUploadVideo);
              
        } else {
          log("error: video is null");
          // await AmityDialog().showAlertErrorDialog(
          //     title: "Error!", message: "error: video is null");
        }
      } catch (error) {
        log("error: $error");
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      }
    }
  }

  void onUploadVideo(AmityUploadResult<AmityVideo> amityResult) {
    amityResult.when(
      progress: (uploadInfo, cancelToken) {},
      complete: (value) {
        var fileInfo = value;
        amityVideo!.addFile(fileInfo);
        isUploading = false;
        notifyListeners();
      },
      error: (error) async {
        log("error: $error");
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      },
      cancel: () {
        // handle cancel request
      },
    );
  }

  void deleteImageAt({required int index}) {
    amityImages.removeAt(index);
    notifyListeners();
  }

  Future<void> createPost({BuildContext? context, String? communityId}) async {
    isloading = true;
    notifyListeners();
    HapticFeedback.heavyImpact();
    if (isNotSelectVideoYet() && isNotSelectedImageYet()) {
      log("isNotSelectVideoYet() & isNotSelectVideoYet()");

      ///create text post
      await createTextpost(
        context,
        communityId: communityId,
      );
    } else if (isNotSelectedImageYet()) {
      log("isNotSelectedImageYet");

      ///create video post
      await createVideoPost(
        context,
        communityId: communityId,
      );
    } else if (isNotSelectVideoYet()) {
      log("isNotSelectVideoYet");

      ///create image post
      await createImagePost(
        context,
        communityId: communityId,
      );
    }

    isloading = false;
    notifyListeners();
  }

  Future<void> createTextpost(BuildContext? context,
      {String? communityId}) async {
    log("createTextpost...");
    bool isCommunity = (communityId != null) ? true : false;
    AmityPostCreateDataTypeSelector client =
        AmitySocialClient.newPostRepository().createPost().targetMe();

    if (isCommunity) {
      client = AmitySocialClient.newPostRepository()
          .createPost()
          .targetCommunity(communityId);
    }

    await client.text(textEditingController.text).post().then((AmityPost post) {
      _updateCommuFeedVM(context, post);
    }).onError((error, stackTrace) async {
      log('ERROR CreatePostVM createTextpost:$error');
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> createImagePost(BuildContext? context,
      {String? communityId}) async {
    log("creatImagePost...");
    List<AmityImage> images = [];
    for (final up in amityImages) {
      final im = up.data;
      if (im != null) {
        images.add(im);
      }
    }
    log(images.toString());
    bool isCommunity = (communityId != null) ? true : false;

    AmityPostCreateDataTypeSelector client =
        AmitySocialClient.newPostRepository().createPost().targetMe();

    if (isCommunity) {
      client = AmitySocialClient.newPostRepository()
          .createPost()
          .targetCommunity(communityId);
    }

    await client
        .image(images)
        .text(textEditingController.text)
        .post()
        .then((AmityPost post) {
      _updateCommuFeedVM(context, post);
    }).onError((error, stackTrace) async {
      log('ERROR CreatePostVM creatImagePost:$error');
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> createVideoPost(BuildContext? context,
      {String? communityId, bool isOutside = false}) async {
    log("creatVideoPost...");
    if (amityVideo != null) {
      bool isCommunity = (communityId != null) ? true : false;
      AmityPostCreateDataTypeSelector client =
          AmitySocialClient.newPostRepository().createPost().targetMe();

      if (isCommunity) {
        client = AmitySocialClient.newPostRepository()
            .createPost()
            .targetCommunity(communityId);
      }
      await client
          .video([amityVideo?.fileInfo as AmityVideo])
          .text(textEditingController.text)
          .post()
          .then((AmityPost post) {
            _updateCommuFeedVM(context, post);
          })
          .onError((error, stackTrace) async {
            log('ERROR CreatePostVM creatVideoPost:$error');
            await AmityDialog().showAlertErrorDialog(
                title: "Error!", message: error.toString());
          });
    }
  }

  void _updateCommuFeedVM(
    BuildContext? context,
    AmityPost post,
  ) {
    lastPost = post;
    if (context != null) {
      ///add post to feed
      Provider.of<CommuFeedVM>(context, listen: false).addPostToFeed(post);
      Provider.of<CommuFeedVM>(context, listen: false)
          .scrollcontroller
          .jumpTo(0);
      notifyListeners();
    }
  }
}

class UploadStatus<T> extends Equatable {
  final bool isComplete;
  final String path;
  final T? data;
  const UploadStatus({
    this.isComplete = false,
    this.data,
    required this.path,
  });

  @override
  List<dynamic> get props => [isComplete, data];

  @override
  bool get stringify => true;

  UploadStatus<T> copyWith({
    bool? isComplete,
    T? data,
    String? path,
  }) {
    return UploadStatus<T>(
      isComplete: isComplete ?? this.isComplete,
      data: data ?? this.data,
      path: path ?? this.path,
    );
  }
}
