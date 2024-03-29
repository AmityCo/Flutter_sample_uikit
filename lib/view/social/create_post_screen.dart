import 'package:amity_uikit_beta_service/viewmodel/amity_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/feed_viewmodel.dart';
import 'package:animation_wrappers/animation_wrappers.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../components/custom_app_bar.dart';
import '../../components/custom_user_avatar.dart';
import '../../components/video_player.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/create_post_viewmodel.dart';

class CreatePostScreen2 extends StatefulWidget {
  final String? communityID;
  final BuildContext? context;
  const CreatePostScreen2({Key? key, this.communityID, this.context})
      : super(key: key);
  @override
  CreatePostScreen2State createState() => CreatePostScreen2State();
}

class CreatePostScreen2State extends State<CreatePostScreen2> {
  final focusNode = FocusNode(debugLabel: 'Post-Screen');

  Future<void> focuskeyborad() async {
    await Future.delayed(Duration.zero);
    focusNode.requestFocus();
  }

  @override
  void initState() {
    Provider.of<CreatePostVM>(context, listen: false).inits();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CreatePostVM>(builder: (context, vm, m) {
      return CupertinoScaffold(
        body: Scaffold(
          appBar: CustomAppBar(context: context, titleText: 'Create Post'),
          body: SafeArea(
            child: FadedSlideAnimation(
              beginOffset: const Offset(0, 0.3),
              endOffset: const Offset(0, 0),
              slideCurve: Curves.linearToEaseOut,
              child: Container(
                // height: bheight,
                color: Colors.white,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: getAvatarImage(Provider.of<AmityVM>(context)
                            .currentamityUser
                            ?.avatarUrl)),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              cursorColor: context
                                  .watch<AmityUIConfiguration>()
                                  .secondaryColor,
                              textCapitalization: TextCapitalization.sentences,
                              autofocus: true,
                              focusNode: focusNode,
                              controller: vm.textEditingController,
                              scrollPhysics:
                                  const NeverScrollableScrollPhysics(),
                              maxLines: null,
                              onTapOutside: (_) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Write something to post",
                              ),
                              // style: t/1heme.textTheme.bodyText1.copyWith(color: Colors.grey),
                            ),
                            (vm.amityVideo != null)
                                ? (vm.amityVideo!.isComplete)
                                    ? LocalVideoPlayer(
                                        file: vm.amityVideo!.file!,
                                      )
                                    : const CircularProgressIndicator()
                                : Container(),
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 150,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10),
                              itemCount: vm.amityImages.length,
                              itemBuilder: (_, i) {
                                return (vm.amityImages[i].isComplete)
                                    ? FadeAnimation(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              "${vm.amityImages[i].data!.fileUrl}?size=medium",
                                              fit: BoxFit.cover,
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  vm.deleteImageAt(index: i);
                                                },
                                                child: Icon(
                                                  Icons.cancel,
                                                  color: Colors.grey.shade100,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : FadeAnimation(
                                        child: Container(
                                          color: theme.highlightColor,
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                      );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await vm.addVideo();
                            focuskeyborad();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.fromLTRB(5, 0, 10, 5),
                            child: FaIcon(
                              FontAwesomeIcons.video,
                              color: vm.isNotSelectedImageYet()
                                  ? Provider.of<AmityUIConfiguration>(context)
                                      .primaryColor
                                  : theme.disabledColor,
                              size: 20,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await vm.addFiles();
                            focuskeyborad();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.fromLTRB(5, 0, 10, 5),
                            child: Icon(
                              Icons.photo,
                              color: vm.isNotSelectVideoYet()
                                  ? Provider.of<AmityUIConfiguration>(context)
                                      .primaryColor
                                  : theme.disabledColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await vm.addFileFromCamera();
                            focuskeyborad();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.fromLTRB(5, 0, 10, 5),
                            child: Icon(
                              Icons.camera_alt,
                              color: vm.isNotSelectVideoYet()
                                  ? Provider.of<AmityUIConfiguration>(context)
                                      .primaryColor
                                  : theme.disabledColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    vm.isloading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .primaryColor,
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () async {
                              if (vm.isUploading) {
                                return;
                              }
                              await vm.createPost(
                                context: widget.context,
                                communityId: widget.communityID,
                              );
                              if (widget.context == null &&
                                  widget.communityID == null &&
                                  vm.lastPost != null) {
                                // ignore: use_build_context_synchronously
                                context
                                    .read<FeedVM>()
                                    .addPostToFeed(vm.lastPost!);
                              }
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 15),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              decoration: BoxDecoration(
                                color: !vm.isUploading
                                    ? context
                                        .watch<AmityUIConfiguration>()
                                        .buttonConfig
                                        .backgroundColor
                                    : theme.disabledColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Submit Post",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: context
                                      .watch<AmityUIConfiguration>()
                                      .buttonConfig
                                      .textColor,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
