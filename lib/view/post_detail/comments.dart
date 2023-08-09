import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/view/social/post_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:linkwell/linkwell.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';

import '../../components/custom_faded_slide_animation.dart';
import '../../components/custom_user_avatar.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/post_viewmodel.dart';

import 'widgets/comment_component.dart';
import 'widgets/text_input_comment.dart';

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

    getPost(widget.amityPost);

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
    AmityPost parentPost =
        Provider.of<PostVM>(context, listen: false).amityPost;
    List<AmityPost> childrenPosts = parentPost.children ?? [];
    if (childrenPosts.isNotEmpty) {
      return AmityPostWidget(
        childrenPosts,
        true,
        false,
        haveChildrenPost: true,
      );
    }
    // else {
    //   TextData textData = parentPost.data as TextData;
    //   if (textData.text != null) {
    //     return  AmityPostWidget(
    //       [parentPost],
    //       false,
    //       false,
    //       haveChildrenPost: false,
    //       shouldShowTextPost: false,
    //     );
    //   } else {
    //     return Container();
    //   }
    // }
    return Container();
  }

  void getPost(AmityPost amityPost) {
    context.read<PostVM>().getPost(
          widget.amityPost.postId!,
          widget.amityPost,
        );
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
          stream: vm.amityPost.listen.stream,
          initialData: vm.amityPost,
          builder: (context, snapshot) {
            return Scaffold(
              appBar: CustomAppBar(context: context),
              body: CustomFadedSlideAnimation(
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
                                  isMediaPosts()
                                      ? SizedBox(
                                          width: double.infinity,
                                          height: (bHeight - 120) * 0.4,
                                          child: mediaPostWidgets())
                                      : Container(),
                                  Container(
                                    padding: isMediaPosts()
                                        ? const EdgeInsets.only(top: 285)
                                        : null,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        HeaderComment(
                                          amityPost: snapshot.data!,
                                          postData: postData,
                                        ),
                                        CommentComponent(
                                          postId: widget.amityPost.postId!,
                                          theme: theme,
                                        ),
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
                          await context.read<PostVM>().createComment(
                              snapshot.data!.postId!,
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

class HeaderComment extends StatelessWidget {
  const HeaderComment({super.key, required this.amityPost, this.postData});
  final AmityPost amityPost;
  final TextData? postData;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: context.watch<AmityUIConfiguration>().primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  getAvatarImage(amityPost.postedUser!.avatarUrl, radius: 25),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amityPost.postedUser!.displayName!,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat.yMMMMEEEEd().format(amityPost.createdAt!),
                          style: theme.textTheme.bodyLarge!
                              .copyWith(color: Colors.grey, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8.5),
                      Text(
                        amityPost.commentCount.toString(),
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  amityPost.myReactions!.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            Provider.of<PostVM>(context, listen: false)
                                .removePostReaction(amityPost);
                          },
                          child: Icon(
                            Icons.thumb_up_alt,
                            size: 17,
                            color: Provider.of<AmityUIConfiguration>(context)
                                .primaryColor,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            log(amityPost.myReactions!.toString());
                            Provider.of<PostVM>(context, listen: false)
                                .addPostReaction(amityPost);
                          },
                          child: const Icon(
                            Icons.thumb_up_off_alt,
                            size: 17,
                            color: Colors.grey,
                          ),
                        ),
                  const SizedBox(width: 10),
                  Text(
                    amityPost.reactionCount.toString(),
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: Colors.grey, letterSpacing: 1),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 9),
                child: postData?.text == "" || postData?.text == null
                    ? const SizedBox()
                    : LinkWell(
                        postData?.text ?? "",
                        textAlign: TextAlign.left,
                        style: theme.textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      )),
          ],
        ),
      ),
    );
  }
}