import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../../components/alert_dialog.dart';

class UserFeedVM extends ChangeNotifier {
  late AmityUser? amityUser;
  late AmityUserFollowInfo amityMyFollowInfo = AmityUserFollowInfo();
  late PagingController<AmityPost> _controller;
  final amityPosts = <AmityPost>[];

  final scrollcontroller = ScrollController();
  bool loading = false;

  void initUserFeed(AmityUser user) async {
    getUser(user);
    listenForUserFeed(user.userId!);
  }

  void getUser(AmityUser user) {
    log("getUser=> ${user.userId}");
    if (user.id == AmityCoreClient.getUserId()) {
      log("isCurrentUser:${user.id}");
      amityUser = AmityCoreClient.getCurrentUser();
    } else {
      log("isNotCurrentUser:${user.id}");
      amityUser = user;
    }

    amityUser!.relationship().getFollowInfo().then((value) {
      amityMyFollowInfo = value;
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error", message: error.toString());
    });
  }

  void listenForUserFeed(String userId) {
    _controller = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getUserFeed(userId)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_controller.error == null) {
            amityPosts.clear();
            amityPosts.addAll(_controller.loadedItems);

            notifyListeners();
          } else {
            //Error on pagination controller
            log("Error: listenForUserFeed... with userId = $userId");
            log("ERROR::${_controller.error.toString()}");
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.fetchNextPage();
    });

    scrollcontroller.addListener(loadnextpage);
  }

  void loadnextpage() {
    if ((scrollcontroller.position.pixels ==
            scrollcontroller.position.maxScrollExtent) &&
        _controller.hasMoreItems) {
      _controller.fetchNextPage();
    }
  }

  Future<void> editCurrentUserInfo(
      {String? displayName, String? description, String? avatarFileID}) async {
    if (displayName != null) {
      await AmityCoreClient.getCurrentUser()
          .update()
          .displayName(displayName)
          .update()
          .then((value) => {log("update displayname success")})
          .onError((error, stackTrace) async => {
                log("update displayname fail"),
                await AmityDialog().showAlertErrorDialog(
                    title: "Error!", message: error.toString())
              });
    }
    if (description != null) {
      await AmityCoreClient.getCurrentUser()
          .update()
          .description(description)
          .update()
          .then((value) => {log("update description success")})
          .onError((error, stackTrace) async => {
                log("update description fail"),
                await AmityDialog().showAlertErrorDialog(
                    title: "Error!", message: error.toString())
              });
    }
    if (avatarFileID != null) {
      await AmityCoreClient.getCurrentUser()
          .update()
          .avatarFileId(avatarFileID)
          .update()
          .then((value) => {log("update avatarFileID success")})
          .onError((error, stackTrace) async => {
                log("avatarFileID displayname fail"),
                await AmityDialog().showAlertErrorDialog(
                    title: "Error!", message: error.toString())
              });
    }
  }
}
