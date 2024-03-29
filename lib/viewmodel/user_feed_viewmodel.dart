import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/alert_dialog.dart';
import 'amity_viewmodel.dart';

class UserFeedVM extends ChangeNotifier {
  late AmityUser? amityUser;
  late AmityUserFollowInfo amityMyFollowInfo = AmityUserFollowInfo();
  late PagingController<AmityPost> _controller;
  late PagingController<AmityPost> _mediaController;
  final amityPosts = <AmityPost>[];
  final amityMediaPosts = <AmityPost>[];

  final scrollcontroller = ScrollController();
  bool loading = false;

  void initUserFeed(AmityUser user) async {
    getUser(user);
    listenForUserFeed(user.userId!);
  }

  void initUserGalleryFeed(AmityUser user) async {
    getUser(user);
    listenForUserMediaFeed(user.userId!);
  }

  void getUser(AmityUser user) {
    log("getUser=> ${user.userId}");
    if (user.id == AmityCoreClient.getUserId()) {
      log("isCurrentUser:${user.id}");
      amityUser = Provider.of<AmityVM>(
              NavigationService.navigatorKey.currentContext!,
              listen: false)
          .currentamityUser;
    } else {
      log("isNotCurrentUser:${user.id}");
      amityUser = user;
    }
    amityUser!.relationship().getFollowInfo(user.userId ?? '').then((value) {
      amityMyFollowInfo = value;
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error", message: error.toString());
    });
  }

  void listenForUserMediaFeed(String userId) {
    _mediaController = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getUserFeed(userId)
          .includeDeleted(false)
          .types([AmityDataType.IMAGE, AmityDataType.VIDEO])
          .getPagingData(
              token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_mediaController.error == null) {
            amityMediaPosts.clear();
            amityMediaPosts.addAll(_mediaController.loadedItems);
            log("successfully query media post ${_mediaController.loadedItems.length}");
            notifyListeners();
          } else {
            //Error on pagination controller
            log("Error: listenForUserMediaFeed... with userId = $userId");
            log("ERROR::${_controller.error.toString()}");
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _mediaController.fetchNextPage();
    });

    scrollcontroller.addListener(loadnextpage);
  }

  void listenForUserFeed(String userId) {
    _controller = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getUserFeed(userId)
          .includeDeleted(false)
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
    } else if ((scrollcontroller.position.pixels ==
            scrollcontroller.position.maxScrollExtent) &&
        _mediaController.hasMoreItems) {
      _mediaController.fetchNextPage();
    }
  }

  Future<void> editCurrentUserInfo(
      {required String displayName,
      required String description,
      String? avatarFileId}) async {
    if (avatarFileId != null) {
      await AmityCoreClient.getCurrentUser()
          .update()
          .avatarFileId(avatarFileId)
          .description(description)
          .displayName(displayName)
          .update()
          .then((value) =>
              {log("update displayname & description & avatarFileUrl success")})
          .onError((error, stackTrace) async => {
                log("update displayname & description & avatarFileUrl fail"),
                await AmityDialog().showAlertErrorDialog(
                    title: "Error!", message: error.toString())
              });
    } else {
      await AmityCoreClient.getCurrentUser()
          .update()
          .displayName(displayName)
          .description(description)
          .update()
          .then((value) => {log("update displayname & description success")})
          .onError((error, stackTrace) async => {
                log("update displayname & description fail"),
                await AmityDialog().showAlertErrorDialog(
                    title: "Error!", message: error.toString())
              });
    }
  }

  Future<void> followButtonAction(AmityUser user, AmityFollowStatus amityFollowStatus) async {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      await sendFollowRequest(user: user);
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      await withdrawFollowRequest(user);
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      await withdrawFollowRequest(user);
    } else {
      AmityDialog().showAlertErrorDialog(
          title: "Error!",
          message: "followButtonAction: cant handle amityFollowStatus");
    }
    await Future.delayed(const Duration(milliseconds: 700));
    initUserFeed(user);
    initUserGalleryFeed(user);
  }

  Future<void> sendFollowRequest({required AmityUser user}) async {
    AmityCoreClient.newUserRepository()
        .relationship()
        .follow(user.userId!)
        .then((AmityFollowStatus followStatus) {
      //success
      log("sendFollowRequest: Success");
      notifyListeners();
    }).onError((error, stackTrace) {
      //handle error
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> withdrawFollowRequest(AmityUser user) async {
   await AmityCoreClient.newUserRepository()
        .relationship()
        .unfollow(user.userId!)
        .then((value) {
      log("withdrawFollowRequest: Success");
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
}
