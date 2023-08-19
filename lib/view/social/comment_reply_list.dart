import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/viewmodel/amity_viewmodel.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/post_viewmodel.dart';
import '../../viewmodel/user_feed_viewmodel.dart';
import '../user/user_profile.dart';
import 'edit_comment.dart';

class ReplyCommentScreen extends StatefulWidget {
  final String postId;
  final String commentId;

  const ReplyCommentScreen(
      {Key? key, required this.postId, required this.commentId})
      : super(key: key);

  @override
  ReplyCommentScreenState createState() => ReplyCommentScreenState();
}

class Comments {
  String image;
  String name;

  Comments(this.image, this.name);
}

class ReplyCommentScreenState extends State<ReplyCommentScreen> {
  final _commentTextEditController = TextEditingController();
  @override
  void initState() {
    //query comment here
    Provider.of<PostVM>(context, listen: false)
        .listenForReplyComments(widget.postId, widget.commentId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var postData =
        Provider.of<PostVM>(context, listen: false).amityPost.data as TextData;
    final theme = Theme.of(context);

    return Consumer<PostVM>(builder: (context, vm, _) {
      return StreamBuilder<AmityPost>(
          key: Key(postData.postId),
          stream: vm.amityPost.listen.stream,
          initialData: vm.amityPost,
          builder: (context, snapshot) {
            return Scaffold(
              appBar: CustomAppBar(
                context: context,
                titleText: 'Replies',
                centerTitle: false,
              ),
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
                              Stack(
                                children: [
                                  Container(
                                    padding: null,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        CommentComponent(
                                            postId: widget.postId,
                                            commentId: widget.commentId,
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
                                color: Color.fromARGB(255, 155, 120, 120),
                                blurRadius: 0.8,
                                spreadRadius: 0.5,
                              ),
                            ]),
                        height: 60,
                        child: ListTile(
                          leading: getAvatarImage(Provider.of<AmityVM>(context)
                              .currentamityUser
                              ?.avatarUrl),
                          title: TextField(
                            textCapitalization:TextCapitalization.sentences,
                            controller: _commentTextEditController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Write your reply",
                              hintStyle: TextStyle(fontSize: 14),
                            ),
                          ),
                          trailing: GestureDetector(
                              onTap: () async {
                                HapticFeedback.heavyImpact();
                                await Provider.of<PostVM>(context,
                                        listen: false)
                                    .createReplyComment(
                                        widget.postId,
                                        widget.commentId,
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
    required this.commentId,
    required this.theme,
  }) : super(key: key);

  final String postId;
  final String commentId;
  final ThemeData theme;

  @override
  State<CommentComponent> createState() => _CommentComponentState();
}

class _CommentComponentState extends State<CommentComponent> {
  @override
  void initState() {
    Provider.of<PostVM>(context, listen: false)
        .listenForReplyComments(widget.postId, widget.commentId);
    super.initState();
  }

  void navigateToEditComment(AmityComment comment) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Builder(builder: (context) {
        return EditCommentScreen(
          comment: comment,
        );
      }),
    ));
  }

  bool isLiked(AsyncSnapshot<AmityComment> snapshot) {
    var comments = snapshot.data!;
    if (comments.myReactions != null) {
      return comments.myReactions!.isNotEmpty;
    } else {
      return false;
    }
  }

  void onShowRepliesClicked(String commentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          amityUser: AmityCoreClient.getCurrentUser(),
        ),
      ),
    );
    navigatorToUserPorfile(AmityCoreClient.getCurrentUser());
  }

  void navigatorToUserPorfile(AmityUser amityUser) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          amityUser: amityUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostVM>(builder: (context, vm, _) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: vm.amityReplyComments.length,
        itemBuilder: (context, index) {
          return StreamBuilder<AmityComment>(
              key: Key(vm.amityReplyComments[index].commentId!),
              stream: vm.amityReplyComments[index].listen.stream,
              initialData: vm.amityReplyComments[index],
              builder: (context, snapshot) {
                var comments = snapshot.data!;
                var commentData = snapshot.data!.data as CommentTextData;

                return Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (context) => UserFeedVM(),
                                child: UserProfileScreen(
                                  amityUser: vm.amityReplyComments[index].user!,
                                ),
                              ),
                            ),
                          );
                        },
                        child: getAvatarImage(
                            vm.amityReplyComments[index].user?.avatarUrl)),
                    title: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (context) => UserFeedVM(),
                              child: UserProfileScreen(
                                amityUser: vm.amityReplyComments[index].user!,
                              ),
                            ),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: widget.theme.textTheme.bodyLarge!
                              .copyWith(fontSize: 17),
                          children: [
                            TextSpan(
                              text: comments.user!.displayName!,
                              style: widget.theme.textTheme.headlineMedium!
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
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: Text(
                            commentData.text!,
                            style:
                                widget.theme.textTheme.headlineSmall!.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (snapshot.data!.childrenNumber != null)
                          if (snapshot.data!.childrenNumber! > 0)
                            TextButton(
                              onPressed: () {
                                onShowRepliesClicked(snapshot.data!.commentId!);
                              },
                              child: const Text("Show replies"),
                            ),
                        Row(
                          children: [
                            isLiked(snapshot)
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
                            if (snapshot.data?.userId ==
                                AmityCoreClient.getCurrentUser().userId)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    navigateToEditComment(snapshot.data!);
                                  },
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            if (snapshot.data?.userId ==
                                AmityCoreClient.getCurrentUser().userId)
                              GestureDetector(
                                onTap: () {
                                  if (snapshot.data != null) {
                                    vm.deleteReplyComment(snapshot.data!);
                                  }
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                    // trailing: Column(
                    //   children: [
                    //     isLiked(snapshot)
                    //         ? GestureDetector(
                    //             onTap: () {
                    //               vm.removeCommentReaction(comments);
                    //             },
                    //             child: const Icon(
                    //               Icons.favorite,
                    //               color: Colors.red,
                    //             ),
                    //           )
                    //         : GestureDetector(
                    //             onTap: () {
                    //               vm.addCommentReaction(comments);
                    //             },
                    //             child: const Icon(Icons.favorite_border)),
                    //     if (snapshot.data?.userId ==
                    //         AmityCoreClient.getCurrentUser().userId)
                    //       GestureDetector(
                    //         onTap: () {
                    //           navigateToEditComment(snapshot.data!);
                    //         },
                    //         child: const Icon(
                    //           Icons.edit_outlined,
                    //           color: Colors.grey,
                    //         ),
                    //       ),
                    //     if (snapshot.data?.userId ==
                    //         AmityCoreClient.getCurrentUser().userId)
                    //       GestureDetector(
                    //         onTap: () {
                    //           if (snapshot.data != null) {
                    //             vm.deleteComment(snapshot.data!);
                    //           }
                    //         },
                    //         child: const Icon(
                    //           Icons.delete,
                    //           color: Colors.grey,
                    //         ),
                    //       ),
                    //   ],
                    // ),
                  ),
                );
              });
        },
      );
    });
  }
}
