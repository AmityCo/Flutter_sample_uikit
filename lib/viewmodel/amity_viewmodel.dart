import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

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

  void logout(){
    isLogin = false;
    notifyListeners();
  }
}
