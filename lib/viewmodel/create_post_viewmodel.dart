import 'dart:async';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';

import '../../components/alert_dialog.dart';
import 'community_feed_viewmodel.dart';
import 'feed_viewmodel.dart';

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
  List<AmityFileInfoWithUploadStatus> amityImages =
      <AmityFileInfoWithUploadStatus>[];
  AmityFileInfoWithUploadStatus? amityVideo;
  bool isloading = false;
  void inits() {
    textEditingController.clear();
    amityVideo = null;
    amityImages.clear();
  }

  bool isNotSelectedImageYet() {
    if (amityImages.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  final Map<String, int> _progressMap = {};

  int? getProgress(String filePath) {
    return _progressMap[filePath];
  }

  void setProgress(String filePath, int progress) {
    _progressMap[filePath] = progress;
  }

  bool isNotSelectVideoYet() {
    if (amityVideo == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> uploadFile(File file) async {
    final completer = Completer<void>();
    print("FILE::::" + file.path);
    AmityCoreClient.newFileRepository().uploadImage(file).stream.listen(
      (amityUploadResult) {
        amityUploadResult.when(
          progress: (uploadInfo, cancelToken) {
            int progress = uploadInfo.getProgressPercentage();
            setProgress(file.path, progress);
            notifyListeners();
            print(progress);
          },
          complete: (file) {
            print("complete");
            final AmityImage uploadedImage = file;
            amityImages
                .add(AmityFileInfoWithUploadStatus()..addFile(uploadedImage));
            notifyListeners();
            completer.complete();
          },
          error: (error) async {
            final AmityException amityException = error;
            await AmityDialog().showAlertErrorDialog(
              title: "Error!",
              message: error.toString(),
            );
            completer.completeError(error);
          },
          cancel: () {
            completer.completeError(Exception('Upload cancelled'));
          },
        );
      },
    );

    return completer.future;
  }

// List to store already selected image paths
  List<String> selectedImagePaths = [];
  Future<void> addFiles() async {
    if (isNotSelectVideoYet()) {
      final List<XFile>? images =
          await _picker.pickMultiImage(imageQuality: 100);
      if (images != null) {
        print("_progressMap");
        print(_progressMap);
        for (var image in images) {
          // Check if the image is already in the list of selected images
          if (_progressMap[image.path] == null) {
            await uploadFile(File(image.path));
            // Add the image path to the list after successful upload
          }
        }
      }
    }
  }

  Future<void> addFileFromCamera() async {
    if (isNotSelectVideoYet()) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        var fileWithStatus = AmityFileInfoWithUploadStatus();
        amityImages.add(fileWithStatus);
        notifyListeners();
        await AmityCoreClient.newFileRepository()
            .uploadImage(File(image.path))
            .done
            .then((value) {
          var fileInfo = value as AmityUploadComplete;

          amityImages.last.addFile(fileInfo.getFile);
          notifyListeners();
        }).onError((error, stackTrace) async {
          log("error: $error");
          await AmityDialog()
              .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      }
    }
  }

  Future<void> addVideo() async {
    if (isNotSelectedImageYet()) {
      // try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        print("got Video");
        // var fileWithStatus = AmityFileInfoWithUploadStatus();
        // amityVideo = fileWithStatus;
        // amityVideo!.file = File(video.path);

        // notifyListeners();
        // await AmityCoreClient.newFileRepository()
        //     .uploadImage(File(video.path))
        //     .done
        //     .then((value) {
        //   var fileInfo = value as AmityUploadComplete;

        //   amityVideo!.addFile(fileInfo.getFile);
        //   log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${fileInfo.getFile.fileId}");

        //   notifyListeners();
        // }).onError((error, stackTrace) async {
        //   log("error: $error");
        //   await AmityDialog()
        //       .showAlertErrorDialog(title: "Error!", message: error.toString());
        // });
      } else {
        log("error: video is null");
        // await AmityDialog().showAlertErrorDialog(
        //     title: "Error!", message: "error: video is null");
      }
      // } catch (error) {
      //   log("error: $error");
      //   await AmityDialog()
      //       .showAlertErrorDialog(title: "Error!", message: error.toString());
      // }
    }
  }

  void deleteImageAt({required int index}) {
    amityImages.removeAt(index);
    notifyListeners();
  }

  Future<void> createPost(BuildContext context,
      {String? communityId, required Function(bool, String?) callback}) async {
    print("create post with communityId: ${communityId}");
    isloading = true;
    notifyListeners();
    HapticFeedback.heavyImpact();
    bool isCommunity = (communityId != null) ? true : false;
    if (isCommunity) {
      print("is community");
      if (isNotSelectVideoYet() && isNotSelectedImageYet()) {
        print("isNotSelectVideoYet() & isNotSelectVideoYet()");

        ///create text post
        await createTextpost(context, communityId: communityId).then((_) {
          callback(true, null); // Successful callback
        }).catchError((e) {
          callback(false, e.toString()); // Error callback
        });
      } else if (isNotSelectedImageYet()) {
        print("isNotSelectedImageYet");

        ///create video post
        await creatVideoPost(context, communityId: communityId).then((_) {
          callback(true, null); // Successful callback
        }).catchError((e) {
          callback(false, e.toString()); // Error callback
        });
      } else if (isNotSelectVideoYet()) {
        print("isNotSelectVideoYet");

        ///create image post
        await creatImagePost(context, communityId: communityId).then((_) {
          callback(true, null); // Successful callback
        }).catchError((e) {
          callback(false, e.toString()); // Error callback
        });
      }
    } else {
      if (isNotSelectVideoYet() && isNotSelectedImageYet()) {
        log("isNotSelectImageYet() & isNotSelectVideoYet()");

        ///create text post
        await createTextpost(context).then((_) {
          callback(true, null); // Successful callback
        }).catchError((e) {
          callback(false, e.toString()); // Error callback
        });
      } else if (isNotSelectedImageYet()) {
        log("isNotSelectedImageYet");

        ///create video post
        await creatVideoPost(context).then((_) {
          callback(true, null); // Successful callback
        }).catchError((e) {
          callback(false, e.toString()); // Error callback
        });
      } else if (isNotSelectVideoYet()) {
        log("isNotSelectVideoYet");

        ///create image post
        await creatImagePost(context).then((_) {
          callback(true, null); // Successful callback
        }).catchError((e) {
          callback(false, e.toString()); // Error callback
        });
      }
    }
    isloading = false;
    notifyListeners();
  }

  Future<void> createTextpost(BuildContext context,
      {String? communityId}) async {
    log("createTextpost...");
    bool isCommunity = (communityId != null) ? true : false;
    if (isCommunity) {
      log("in community...");
      await AmitySocialClient.newPostRepository()
          .createPost()
          .targetCommunity(communityId)
          .text(textEditingController.text)
          .post()
          .then((AmityPost post) {
        ///add post to feed
        if (communityId != null) {
          var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        } else {
          var viewModel = Provider.of<FeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        }
      }).onError((error, stackTrace) async {
        log(error.toString());
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    } else {
      await AmitySocialClient.newPostRepository()
          .createPost()
          .targetMe() // or targetMe(), targetCommunity(communityId: String)
          .text(textEditingController.text)
          .post()
          .then((AmityPost post) {
        ///add post to feed
        if (communityId != null) {
          var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        } else {
          var viewModel = Provider.of<FeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        }
        notifyListeners();
      }).onError((error, stackTrace) async {
        print(error.toString());
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
  }

  Future<void> creatImagePost(BuildContext context,
      {String? communityId}) async {
    print("creatImagePost...");
    List<AmityImage> images = [];
    print(amityImages);
    for (var amityImage in amityImages) {
      if (amityImage.fileInfo is AmityImage) {
        var image = amityImage.fileInfo as AmityImage;
        images.add(image);
        log("add file to _images");
      }
    }
    log(images.toString());
    bool isCommunity = (communityId != null) ? true : false;
    if (isCommunity) {
      await AmitySocialClient.newPostRepository()
          .createPost()
          .targetCommunity(communityId)
          .image(images)
          .text(textEditingController.text)
          .post()
          .then((AmityPost post) {
        ///add post to feedx
        print("success");
        var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
        viewModel.addPostToFeed(post);
        if (viewModel.scrollcontroller.hasClients) {
          viewModel.scrollcontroller.jumpTo(0);
        }
      }).onError((error, stackTrace) async {
        log(error.toString());
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    } else {
      await AmitySocialClient.newPostRepository()
          .createPost()
          .targetMe()
          .image(images)
          .text(textEditingController.text)
          .post()
          .then((AmityPost post) {
        ///add post to feedx
        if (communityId != null) {
          var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        } else {
          var viewModel = Provider.of<FeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        }
      }).onError((error, stackTrace) async {
        log(error.toString());
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
  }

  Future<void> creatVideoPost(BuildContext context,
      {String? communityId}) async {
    log("creatVideoPost...");
    if (amityVideo != null) {
      bool isCommunity = (communityId != null) ? true : false;
      if (isCommunity) {
        await AmitySocialClient.newPostRepository()
            .createPost()
            .targetCommunity(communityId)
            .video([amityVideo?.fileInfo as AmityVideo])
            .text(textEditingController.text)
            .post()
            .then((AmityPost post) {
              ///add post to feedx
              Provider.of<CommuFeedVM>(context, listen: false)
                  .addPostToFeed(post);
              Provider.of<CommuFeedVM>(context, listen: false)
                  .scrollcontroller
                  .jumpTo(0);
            })
            .onError((error, stackTrace) async {
              await AmityDialog().showAlertErrorDialog(
                  title: "Error!", message: error.toString());
            });
      } else {
        await AmitySocialClient.newPostRepository()
            .createPost()
            .targetMe()
            .video([amityVideo?.fileInfo as AmityVideo])
            .text(textEditingController.text)
            .post()
            .then((AmityPost post) {
              if (communityId != null) {
                var viewModel =
                    Provider.of<CommuFeedVM>(context, listen: false);
                viewModel.addPostToFeed(post);
                if (viewModel.scrollcontroller.hasClients) {
                  viewModel.scrollcontroller.jumpTo(0);
                }
              } else {
                var viewModel = Provider.of<FeedVM>(context, listen: false);
                viewModel.addPostToFeed(post);
                if (viewModel.scrollcontroller.hasClients) {
                  viewModel.scrollcontroller.jumpTo(0);
                }
              }
            })
            .onError((error, stackTrace) async {
              await AmityDialog().showAlertErrorDialog(
                  title: "Error!", message: error.toString());
            });
      }
    }
  }
}
