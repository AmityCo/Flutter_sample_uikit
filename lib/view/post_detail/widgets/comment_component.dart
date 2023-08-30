import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/custom_user_avatar.dart';
import '../../../components/accept_dialog.dart';
import '../../../constans/app_string.dart';
import '../../../constans/app_text_style.dart';
import '../../../viewmodel/post_viewmodel.dart';
import '../../../viewmodel/user_feed_viewmodel.dart';
import '../../social/comment_reply_list.dart';
import '../../social/edit_comment.dart';
import '../../user/user_profile.dart';

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
  final deleteDialog = AcceptDialog();

  @override
  void initState() {
    getData();
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

  Future<void> onShowRepliesClicked(String postId, String commentId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReplyCommentScreen(
          postId: postId,
          commentId: commentId,
        ),
      ),
    );
    if (mounted) {
      getData();
    }
  }

  void getData() {
    Provider.of<PostVM>(context, listen: false)
        .listenForComments(widget.postId);
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
              stream: vm.amityComments[index].listen.stream,
              initialData: vm.amityComments[index],
              builder: (context, snapshot) {
                var comments = snapshot.data!;
                var commentData = snapshot.data!.data as CommentTextData;

                return Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                  create: (context) => UserFeedVM(),
                                  child: UserProfileScreen(
                                    amityUser: vm.amityComments[index].user!,
                                  ))));
                        },
                        child: getAvatarImage(
                            vm.amityComments[index].user!.avatarUrl)),
                    title: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (context) => UserFeedVM(),
                              child: UserProfileScreen(
                                amityUser: vm.amityComments[index].user!,
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
                                style: AppTextStyle.body1.copyWith(
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
                          padding:
                              const EdgeInsets.only(top: 8.0, bottom: 12.0),
                          child: Text(
                            commentData.text!,
                            style:
                                widget.theme.textTheme.headlineSmall!.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (snapshot.data!.childrenNumber! > 0)
                          GestureDetector(
                            onTap: () {
                              onShowRepliesClicked(
                                  widget.postId, snapshot.data!.commentId!);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 25),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Show replies",
                                      style: AppTextStyle.body1.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                            if (snapshot.data!.childrenNumber! == 0)
                              _IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ReplyCommentScreen(
                                        postId: widget.postId,
                                        commentId: snapshot.data!.commentId!,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icons.reply,
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
                                      title: 'Delete Comment',
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
                                          vm.deleteComment(snapshot.data!);
                                        }
                                        deleteDialog.close();
                                      });
                                },
                                icon: Icons.delete,
                              ),
                          ],
                        ),
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
