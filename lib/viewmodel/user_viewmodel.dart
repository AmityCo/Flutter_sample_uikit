import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../components/alert_dialog.dart';
import '../utils/env_manager.dart';

class UserVM extends ChangeNotifier {
  ///testtt
  final List<AmityUser> _userList = [];
  List<String> selectedUserList = [];
  String? accessToken;
  List<AmityUser> getUserList() {
    return _userList;
  }

  void clearSelectedUser() {
    selectedUserList.clear();
    notifyListeners();
  }

  Future<void> initAccessToken() async {
    var dio = Dio();
    final response = await dio.post(
      "https://api.${env!.region}.amity.co/api/v3/sessions",
      data: {
        'userId': AmityCoreClient.getUserId(),
        'deviceId': AmityCoreClient.getUserId()
      },
      options: Options(
        headers: {
          "x-api-key": env!.apikey // set content-length
        },
      ),
    );
    if (response.statusCode == 200) {
      accessToken = response.data["accessToken"];
    } else {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: response.data);
    }
  }

  Future<AmityUser?> getUserByID(String id) async {
    AmityUser? amityUser;
    await AmityCoreClient.newUserRepository().getUser(id).then((user) {
      log("IsGlobalban: ${user.isGlobalBan}");
      amityUser = user;
    }).onError((error, stackTrace) async {
      log('ERROR UserVM getUserByID:$error');
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
    return amityUser;
  }

  void setSelectedUserList(String id) {
    if (selectedUserList.isNotEmpty && selectedUserList.contains(id)) {
      selectedUserList.remove(id);
    } else {
      selectedUserList.add(id);
    }
    notifyListeners();
  }

  bool checkIfSelected(String id) {
    return selectedUserList.contains(id);
  }

  Future<void> getUsers() async {
    AmityCoreClient.newUserRepository()
        .getUsers()
        .sortBy(AmityUserSortOption.DISPLAY)
        .query()
        .then((users) async {
      _userList.clear();
      _userList.addAll(users);
      notifyListeners();
    }).catchError((error, stackTrace) async {
      log('ERROR UserVM getUsers:$error');
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
      notifyListeners();
    });
  }
}
