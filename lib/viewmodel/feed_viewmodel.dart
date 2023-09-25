import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/utils/de_bounce.dart';
import 'package:flutter/material.dart';

import '../../components/alert_dialog.dart';

enum Feedtype { global, commu }

class FeedVM extends ChangeNotifier {
  final _amityGlobalFeedPosts = <AmityPost>[];

  late PagingController<AmityPost> _controllerGlobal;

  final scrollcontroller = ScrollController();
  bool isLoading = false;
  final debounce = Debounce(duration: const Duration(seconds: 2));

  bool loadingNexPage = false;
  List<AmityPost> getAmityPosts() {
    return _amityGlobalFeedPosts;
  }

  Future<void> addPostToFeed(AmityPost post) async {
    _controllerGlobal.addAtIndex(0, post);
    notifyListeners();
  }

  Future<void> deletePost(AmityPost post, int postIndex) async {
    await AmitySocialClient.newPostRepository()
        .deletePost(postId: post.postId!)
        .onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
      return;
    });

    _amityGlobalFeedPosts.removeAt(postIndex);
    notifyListeners();
  }

  Future<void> initAmityGlobalfeed() async {
    isLoading = true;
    _controllerGlobal = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getGlobalFeed()
          .getPagingData(token: token, limit: 5),
      pageSize: 5,
    )..addListener(
        () async {
          log("initAmityGlobalfeed listener...");
          if (_controllerGlobal.error == null) {
            _amityGlobalFeedPosts.clear();
            _amityGlobalFeedPosts.addAll(_controllerGlobal.loadedItems);

            notifyListeners();
          } else {
            //Error on pagination controller

            log("error");
            await AmityDialog().showAlertErrorDialog(
                title: "Error!", message: _controllerGlobal.error.toString());
          }
          debounce.run(() {
            isLoading = false;
            notifyListeners();
          });
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controllerGlobal.fetchNextPage();
    });
    scrollcontroller.removeListener(() {});
    scrollcontroller.addListener(loadnextpage);

    // //inititate the PagingController
    // await AmitySocialClient.newFeedRepository()
    //     .getGlobalFeed()
    //     .getPagingData()
    //     .then((value) async {
    //   _amityGlobalFeedPosts = value.data;
    //   if (_amityGlobalFeedPosts.isEmpty) {
    //     await AmityDialog().showAlertErrorDialog(
    //         title: "No Post yet!",
    //         message: "please join some community or follow some user 🥳");
    //   }
    // }).onError(
    //   (error, stackTrace) async {
    //     await AmityDialog()
    //         .showAlertErrorDialog(title: "Error!", message: error.toString());
    //   },
    // );
    // notifyListeners();
  }

  void updatePost(AmityPost post) {
    AmitySocialClient.newPostRepository()
        .getPost(post.postId!)
        .then((AmityPost post) {
      final idx = _amityGlobalFeedPosts
          .indexWhere((element) => element.postId == post.postId);
      if (idx != -1) {
        _amityGlobalFeedPosts[idx] = post;
        notifyListeners();
      }
    }).onError<AmityException>((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
      return;
    });
  }

  void loadnextpage() async {
    // log(scrollcontroller.offset);
    if ((scrollcontroller.position.pixels >
            scrollcontroller.position.maxScrollExtent - 800) &&
        _controllerGlobal.hasMoreItems &&
        !loadingNexPage) {
      loadingNexPage = true;
      notifyListeners();
      log("loading Next Page...");
      await _controllerGlobal.fetchNextPage().then((value) {
        loadingNexPage = false;
        notifyListeners();
      });
    }
  }
}
