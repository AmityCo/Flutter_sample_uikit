import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/alert_dialog.dart';

class PostVM extends ChangeNotifier {
  late AmityPost amityPost;
  late PagingController<AmityComment> _controller;
  final amityComments = <AmityComment>[];
  final amityReplyComments = <AmityComment>[];

  final scrollcontroller = ScrollController();

  final AmityCommentSortOption _sortOption =
      AmityCommentSortOption.FIRST_CREATED;

  void getPost(String postId, AmityPost initialPostData) {
    amityPost = initialPostData;
    AmitySocialClient.newPostRepository()
        .getPost(postId)
        .then((AmityPost post) {
      amityPost = post;
    }).onError<AmityException>((error, stackTrace) async {
      log('ERROR PostVM getPost:$error');
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<bool> editComment(AmityComment comment, String text) async {
    try {
      await comment.edit().text(text).build().update();
      // Success, notify listeners and return true
      int index = _controller.loadedItems
          .indexWhere((element) => comment.commentId == element.commentId);
      if (index != -1) {
        _controller.loadedItems[index] = comment;
      }
      notifyListeners(); // Replace 'notifyListener()' with the actual method call to notify listeners
      return true;
    } catch (error, _) {
      // Error occurred, notify listeners and return false
      notifyListeners(); // Replace 'notifyListener()' with the actual method call to notify listeners
      return false;
    }
  }

  void listenForReplyComments(String postID, String commentID) {
    _controller = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommentRepository()
          .getComments()
          .post(postID)
          .includeDeleted(false)
          .parentId(commentID)
          .sortBy(_sortOption)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          if (_controller.error == null) {
            amityReplyComments.clear();
            amityReplyComments.addAll(_controller.loadedItems);
            notifyListeners();
          } else {
            //Error on pagination controller
            log("error");
            await AmityDialog().showAlertErrorDialog(
                title: "Error!", message: _controller.error.toString());
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.fetchNextPage();
    });

    scrollcontroller.addListener(loadnextpage);
  }

  void listenForComments(String postID) {
    _controller = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommentRepository()
          .getComments()
          .post(postID)
          .includeDeleted(false)
          .sortBy(_sortOption)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          if (_controller.error == null) {
            amityComments.clear();
            amityComments.addAll(_controller.loadedItems);
            notifyListeners();
          } else {
            //Error on pagination controller
            log("error");
            await AmityDialog().showAlertErrorDialog(
                title: "Error!", message: _controller.error.toString());
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

  void updateScrollController() {
    try {
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        scrollcontroller.jumpTo(scrollcontroller.position.maxScrollExtent);
      });
    } catch (e) {
      log('UpdateScrollController Error:$e');
    }
  }

  Future<void> createComment(String postId, String text) async {
    await AmitySocialClient.newCommentRepository()
        .createComment()
        .post(postId)
        .create()
        .text(text)
        .send()
        .then((comment) async {
      _controller.add(comment);
      amityComments.clear();
      amityComments.addAll(_controller.loadedItems);
      updateScrollController();
    }).onError((error, stackTrace) async {
      log('ERROR PostVM createComment:$error');
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> createReplyComment(
      String postId, String commentId, String text) async {
    await AmitySocialClient.newCommentRepository()
        .createComment()
        .post(postId)
        .parentId(commentId)
        .create()
        .text(text)
        .send()
        .then((comment) async {
      _controller.add(comment);
      amityReplyComments.clear();
      amityReplyComments.addAll(_controller.loadedItems);
       updateScrollController();
    }).onError((error, stackTrace) async {
      log('ERROR PostVM createReplyComment:$error');
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void addCommentReaction(AmityComment comment) {
    HapticFeedback.heavyImpact();
    comment.react().addReaction('like').then((value) {});
  }

  void addPostReaction(AmityPost post) {
    HapticFeedback.heavyImpact();
    post.react().addReaction('like').then((value) => {
          //success
        });
  }

  void flagPost(AmityPost post) {
    post.report().flag().then((value) {
      log("flag success $value");
      notifyListeners();
    }).onError((error, stackTrace) async {
      log("flag error ${error.toString()}");
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void unflagPost(AmityPost post) {
    post.report().unflag().then((value) {
      //success
      log("unflag success $value");
      notifyListeners();
    }).onError((error, stackTrace) async {
      log("unflag error ${error.toString()}");
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void removePostReaction(AmityPost post) {
    HapticFeedback.heavyImpact();
    post.react().removeReaction('like').then((value) => {
          //success
        });
  }

  void deleteComment(AmityComment comment) {
    comment.delete().then((value){
          // success
          amityComments
              .removeWhere((element) => element.commentId == comment.commentId);
          
          int index = _controller.loadedItems
          .indexWhere((element) => comment.commentId == element.commentId);
          if(index != -1){
            _controller.loadedItems.removeAt(index);
          }
          notifyListeners();
        });
  }

  void deleteReplyComment(AmityComment comment) {
    comment.delete().then((value){
          // success
          amityReplyComments
              .removeWhere((element) => element.commentId == comment.commentId);

          int index = _controller.loadedItems
          .indexWhere((element) => comment.commentId == element.commentId);
          if(index != -1){
            _controller.loadedItems.removeAt(index);
          }
          
          notifyListeners();

        });
  }

  void removeCommentReaction(AmityComment comment) {
    HapticFeedback.heavyImpact();
    comment.react().removeReaction('like').then((value) => {
          //success
        });
  }

  bool isliked(AmityComment comment) {
    return comment.myReactions?.isNotEmpty ?? false;
  }
}
