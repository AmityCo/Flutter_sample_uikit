import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../components/alert_dialog.dart';
import '../utils/env_manager.dart';
import 'create_post_viewmodel.dart';

class EditPostVM extends CreatePostVM {
  String? videoUrl;
  late AmityPost currentPost;
  VideoData? videoData;

  void initForEditPost(AmityPost post) {
    currentPost = post;
    textEditingController.clear();
    inits();
    videoUrl = null;

    var textdata = post.data as TextData;
    textEditingController.text = textdata.text!;
    var children = post.children;
    if (children != null) {
      if (children[0].data is ImageData) {
        amityImages = [];
        for (var child in children) {
          var imageData = child.data as ImageData;
          amityImages.add(
            UploadStatus(
              path: imageData.fileInfo.fileUrl,
              data: imageData.image,
              isComplete: true,
            ),
          );
        }

        log("AmityImages: $amityImages");
      } else if (children[0].data is VideoData) {
        var vData = children[0].data as VideoData;
        videoData = vData;
        videoUrl =
            "https://api.${env!.region}.amity.co/api/v3/files/${vData.fileId}/download?size=full";
        log("VideoPost: $videoUrl");
      }
    }
  }

  @override
  Future<void> createTextpost(
    BuildContext? context, {
    String? communityId,
  }) async {
    log("createTextpost...");

    currentPost
        .edit()
        .text(textEditingController.text)
        .build()
        .update()
        .then((value) {
      log('Update Post OK');
    }).onError((error, stackTrace) async {
      log('ERROR EditPostVM createTextpost:$error');
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  @override
  bool isNotSelectedImageYet() {
    return false;
  }

  @override
  bool isNotSelectVideoYet() {
    return false;
  }
}
