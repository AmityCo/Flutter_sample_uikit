import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/social/post_content_widget.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/post_viewmodel.dart';

class CommentScreen extends StatefulWidget {
  final AmityPost amityPost;

  const CommentScreen({Key? key, required this.amityPost}) : super(key: key);

  @override
  CommentScreenState createState() => CommentScreenState();
}

class Comments {
  String image;
  String name;

  Comments(this.image, this.name);
}

class CommentScreenState extends State<CommentScreen> {
  final _commentTextEditController = TextEditingController();
  @override
  void initState() {
    //query comment here

    Provider.of<PostVM>(context, listen: false)
        .getPost(widget.amityPost.postId!, widget.amityPost);

    super.initState();
  }

  bool isMediaPosts() {
    final childrenPosts =
        Provider.of<PostVM>(context, listen: false).amityPost.children;
    if (childrenPosts != null && childrenPosts.isNotEmpty) {
      return true;
    }
    return false;
  }

  Widget mediaPostWidgets() {
    final childrenPosts =
        Provider.of<PostVM>(context, listen: false).amityPost.children;
    if (childrenPosts != null && childrenPosts.isNotEmpty) {
      return AmityPostWidget(childrenPosts, true, false);
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    var postData =
        Provider.of<PostVM>(context, listen: false).amityPost.data as TextData;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bHeight = mediaQuery.size.height - mediaQuery.padding.top;

    return Consumer<PostVM>(builder: (context, vm, _) {
      return StreamBuilder<AmityPost>(
          key: Key(postData.postId),
          stream: vm.amityPost.listen,
          initialData: vm.amityPost,
          builder: (context, snapshot) {
            return Scaffold(
              body: FadedSlideAnimation(
                beginOffset: const Offset(0, 0.3),
                endOffset: const Offset(0, 0),
                slideCurve: Curves.linearToEaseOut,
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: vm.scrollcontroller,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.chevron_left,
                                      color: Colors.black, size: 35),
                                ),
                              ),
                              Stack(
                                children: [
                                  isMediaPosts()
                                      ? SizedBox(
                                          width: double.infinity,
                                          height: (bHeight - 120) * 0.4,
                                          child: mediaPostWidgets()
                                          // Image.asset(
                                          //   'assets/images/Layer709.png',
                                          //   fit: BoxFit.fitWidth,
                                          // ),
                                          )
                                      : Container(),
                                  Container(
                                    // color: isMediaPosts()
                                    //     ? Colors.black
                                    //     : Colors.transparent,
                                    padding: isMediaPosts()
                                        ? const EdgeInsets.only(top: 285)
                                        : null,
                                    // height: (bHeight - 60) * 0.6,

                                    // decoration: BoxDecoration(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              topRight: Radius.circular(30),
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30),
                                              ),
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 0, 10, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      getAvatarImage(
                                                          widget
                                                              .amityPost
                                                              .postedUser!
                                                              .avatarUrl,
                                                          radius: 25),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        flex: 12,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              widget
                                                                  .amityPost
                                                                  .postedUser!
                                                                  .displayName!,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              DateFormat
                                                                      .yMMMMEEEEd()
                                                                  .format(vm
                                                                      .amityPost
                                                                      .createdAt!),
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyText1!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          11),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      // Image.asset(
                                                      //   'assets/Icons/ic_share.png',
                                                      //   scale: 3,
                                                      // ),
                                                      // SizedBox(width: 10),
                                                      // Icon(
                                                      //   Icons.bookmark_outline,
                                                      //   size: 17,
                                                      //   color: Colors.grey,
                                                      // ),
                                                      // SizedBox(width: 10),
                                                      // FaIcon(
                                                      //   Icons.repeat_rounded,
                                                      //   size: 17,
                                                      //   color: Colors.grey,
                                                      // ),
                                                      // SizedBox(width: 10),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .chat_bubble_outline,
                                                            color: Colors.grey,
                                                            size: 18,
                                                          ),
                                                          const SizedBox(
                                                              width: 8.5),
                                                          Text(
                                                            snapshot.data!
                                                                .commentCount
                                                                .toString(),
                                                            style: const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12,
                                                                letterSpacing:
                                                                    0.5),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 10),
                                                      snapshot
                                                              .data!
                                                              .myReactions!
                                                              .isNotEmpty
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                Provider.of<PostVM>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .removePostReaction(
                                                                        widget
                                                                            .amityPost);
                                                              },
                                                              child: Icon(
                                                                Icons
                                                                    .thumb_up_alt,
                                                                size: 17,
                                                                color: Provider.of<
                                                                            AmityUIConfiguration>(
                                                                        context)
                                                                    .primaryColor,
                                                              ),
                                                            )
                                                          : GestureDetector(
                                                              onTap: () {
                                                                log(widget
                                                                    .amityPost
                                                                    .myReactions!
                                                                    .toString());
                                                                Provider.of<PostVM>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .addPostReaction(
                                                                        widget
                                                                            .amityPost);
                                                              },
                                                              child: const Icon(
                                                                Icons
                                                                    .thumb_up_off_alt,
                                                                size: 17,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        snapshot
                                                            .data!.reactionCount
                                                            .toString(),
                                                        style: theme.textTheme
                                                            .bodyText1!
                                                            .copyWith(
                                                                color:
                                                                    Colors.grey,
                                                                letterSpacing:
                                                                    1),
                                                      ),
                                                      const SizedBox(width: 10),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 10, 0, 9),
                                                  child: postData.text == "" ||
                                                          postData.text == null
                                                      ? const SizedBox()
                                                      : Text(
                                                          postData.text ?? "",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: theme.textTheme
                                                              .headline6!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 18),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        CommentComponent(
                                            postId: widget.amityPost.postId!,
                                            theme: theme),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 0.8,
                                spreadRadius: 0.5,
                              ),
                            ]),
                        height: 60,
                        child: ListTile(
                          leading: getAvatarImage(
                              widget.amityPost.postedUser!.avatarUrl),
                          title: TextField(
                            controller: _commentTextEditController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Write your message",
                              hintStyle: TextStyle(fontSize: 14),
                            ),
                          ),
                          trailing: GestureDetector(
                              onTap: () async {
                                HapticFeedback.heavyImpact();
                                await Provider.of<PostVM>(context,
                                        listen: false)
                                    .createComment(snapshot.data!.postId!,
                                        _commentTextEditController.text);

                                _commentTextEditController.clear();
                              },
                              child: Icon(Icons.send,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .primaryColor)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    });
  }
}

class CommentComponent extends StatefulWidget {
  const CommentComponent({
    Key? key,
    required this.postId,
    required this.theme,
  }) : super(key: key);

  final String postId;
  final ThemeData theme;

  @override
  State<CommentComponent> createState() => _CommentComponentState();
}

class _CommentComponentState extends State<CommentComponent> {
  @override
  void initState() {
    Provider.of<PostVM>(context, listen: false)
        .listenForComments(widget.postId);
    super.initState();
  }

  bool isLiked(AsyncSnapshot<AmityComment> snapshot) {
    var comments = snapshot.data!;
    if (comments.myReactions != null) {
      return comments.myReactions!.isNotEmpty;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostVM>(builder: (context, vm, _) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: vm.amityComments.length,
        itemBuilder: (context, index) {
          return StreamBuilder<AmityComment>(
              key: Key(vm.amityComments[index].commentId!),
              stream: vm.amityComments[index].listen,
              initialData: vm.amityComments[index],
              builder: (context, snapshot) {
                var comments = snapshot.data!;
                var commentData = snapshot.data!.data as CommentTextData;

                return Container(
                  color: Colors.white,
                  child: ListTile(
                    leading:
                        getAvatarImage(vm.amityComments[index].user!.avatarUrl),
                    title: RichText(
                      text: TextSpan(
                        style: widget.theme.textTheme.bodyText1!
                            .copyWith(fontSize: 17),
                        children: [
                          TextSpan(
                            text: comments.user!.displayName!,
                            style: widget.theme.textTheme.headline6!
                                .copyWith(fontSize: 14),
                          ),
                          TextSpan(
                              text:
                                  '   ${DateFormat.yMMMMEEEEd().format(comments.createdAt!)}',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      commentData.text!,
                      style: widget.theme.textTheme.subtitle2!.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    trailing: isLiked(snapshot)
                        ? GestureDetector(
                            onTap: () {
                              vm.removeCommentReaction(comments);
                            },
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              vm.addCommentReaction(comments);
                            },
                            child: const Icon(Icons.favorite_border)),
                  ),
                );
              });
        },
      );
    });
  }
}
