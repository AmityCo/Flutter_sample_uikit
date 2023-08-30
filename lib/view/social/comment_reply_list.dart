import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/components/accept_dialog.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../constans/app_string.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/post_viewmodel.dart';
import '../../viewmodel/user_feed_viewmodel.dart';
import '../post_detail/widgets/text_input_comment.dart';
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
                      TextInputComment(
                        controller: _commentTextEditController,
                        onPressedSend: () async {
                          HapticFeedback.heavyImpact();
                          await Provider.of<PostVM>(context, listen: false)
                              .createReplyComment(
                                  widget.postId,
                                  widget.commentId,
                                  _commentTextEditController.text);

                          _commentTextEditController.clear();
                        },
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
  final deleteDialog = AcceptDialog();
  @override
  void initState() {
    Provider.of<PostVM>(context, listen: false)
        .listenForReplyComments(widget.postId, widget.commentId);
    super.initState();
  }

  @override
  void dispose() {
    deleteDialog.close();
    super.dispose();
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
                                ? _IconButton(
                                    onPressed: () {
                                      vm.removeCommentReaction(comments);
                                    },
                                    icon: Icons.favorite,
                                    colorIcon: Colors.red,
                                  )
                                : _IconButton(
                                    onPressed: () {
                                      vm.addCommentReaction(comments);
                                    },
                                    icon: Icons.favorite_border,
                                  ),
                            if (snapshot.data?.userId ==
                                AmityCoreClient.getCurrentUser().userId)
                              _IconButton(
                                onPressed: () {
                                  navigateToEditComment(snapshot.data!);
                                },
                                icon: Icons.edit_outlined,
                              ),
                            if (snapshot.data?.userId ==
                                AmityCoreClient.getCurrentUser().userId)
                              _IconButton(
                                onPressed: () {
                                  deleteDialog.open(
                                      context: context,
                                      title: 'Delete Reply Comment',
                                      message: AppString.messageConfrimDelete,
                                      acceptText: AppString.deleteButton,
                                      acceptButtonConfig: context
                                          .read<AmityUIConfiguration>()
                                          .deleteButtonConfig,
                                      onPressedCancel: () {
                                        deleteDialog.close();
                                      },
                                      onPressedAccept: () {
                                        if (snapshot.data != null) {
                                          vm.deleteReplyComment(snapshot.data!);
                                        }
                                        deleteDialog.close();
                                      });
                                },
                                icon: Icons.delete,
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

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    this.onPressed,
    this.colorIcon = Colors.grey,
  });

  final IconData icon;
  final Color colorIcon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 30,
        height: 25,
        margin: const EdgeInsets.only(right: 5),
        child: Center(
          child: Icon(
            icon,
            color: colorIcon,
            size: 25,
          ),
        ),
      ),
    );
  }
}
