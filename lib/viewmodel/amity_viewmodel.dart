import 'dart:developer';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../components/alert_dialog.dart';

class AmityVM extends ChangeNotifier {
  AmityUser? currentamityUser;
  bool isProcessing = false;
  bool isLogin = false;
  Future<void> login(
      {required String userID, String? displayName, String? authToken}) async {
    if (!isProcessing) {
      isProcessing = true;
      log("login with $userID");
      final client = AmityCoreClient.login(userID);

      if (authToken != null) {
        client.authToken(authToken);
      }

      if (displayName != null) {
        client.displayName(displayName);
      }

      await client.submit().then((value) async {
        log("success");
        isProcessing = false;
        currentamityUser = value;
        getUserByID(userID);
        isLogin = true;
        notifyListeners();
      }).catchError((error, stackTrace) async {
        isProcessing = false;
        log('ERROR AmityVM login:$error');
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
        isLogin = false;
      });
    } else {
      /// processing
      log("processing login...");
    }
  }

  void setProcessing(bool isProcessing) {
    this.isProcessing = isProcessing;
    notifyListeners();
  }

  Future<void> refreshCurrentUserData() async {
    if (currentamityUser != null) {
      await AmityCoreClient.newUserRepository()
          .getUser(currentamityUser!.userId!)
          .then((user) {
        currentamityUser = user;
        notifyListeners();
      }).onError((error, stackTrace) async {
        log('ERROR AmityVM refreshCurrentUserData:$error');
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
  }

  Future<void> getUserByID(String id) async {
    await AmityCoreClient.newUserRepository().getUser(id).then((user) {
      log("IsGlobalban: ${user.isGlobalBan}");
    }).onError((error, stackTrace) async {
      log('ERROR AmityVM getUserByID:$error');
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void logout() {
    isLogin = false;
    notifyListeners();
  }

  Future<void> _uploadImageUrlProfile(String url) async {
    final directory = await getTemporaryDirectory();
    final filename = url.split('/').last;
    final savePath = '${directory.path}/comunity/$filename';
    debugPrint('uploadImageProfile path $url');
    final response = await Dio().download(url, savePath);
    if (response.statusCode == 200) {
      final File file = File(savePath);
      _uploadImageProfile(file);
    }
  }

  void _uploadImageProfile(File imageFile) {
    AmityCoreClient.newFileRepository()
        .uploadImage(imageFile, isFullImage: false)
        .stream
        .listen((amityUploadResult) {
      amityUploadResult.when(
        progress: (uploadInfo, cancelToken) {
          // int progress = uploadInfo.getProgressPercentage();
        },
        complete: (file) {
          final AmityImage uploadedImage = file;
          _updateImageProfile(uploadedImage);
        },
        error: (error) async {
          final AmityException amityException = error;

          log("error: $error");
          await AmityDialog().showAlertErrorDialog(
              title: "Error ${amityException.code}!",
              message: amityException.message);
        },
        cancel: () {
          //upload is cancelled
        },
      );
    });
  }

  Future<void> _updateImageProfile(AmityImage amityImage) async {
    await AmityCoreClient.getCurrentUser()
        .update()
        .avatarFileId(amityImage.fileId ?? '')
        .update()
        .then((value) {
      log("UpdateImageProfile success");
      refreshCurrentUserData();
    }).onError((error, stackTrace) async {
      log("update avatarFileUrl fail");
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> updateProfile({
    String? displayName,
    String? description,
    String? url,
  }) async {
    if (url != null) {
      _uploadImageUrlProfile(url);
    }

    final update = AmityCoreClient.getCurrentUser().update();
    bool isUpdate = false;
    if (displayName != null) {
      update.displayName(displayName);
      isUpdate = true;
    }

    if (description != null) {
      update.description(description);
      isUpdate = true;
    }
    if (isUpdate) {
      await update.update().then((value) {
        log("update displayname & description & UpdateImageProfile success");
        refreshCurrentUserData();
      }).onError((error, stackTrace) async {
        log("update displayname & description & avatarFileUrl fail");
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
  }
}
