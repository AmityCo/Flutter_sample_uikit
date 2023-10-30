import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/components/custom_user_avatar.dart';
import 'package:amity_uikit_beta_service/components/video_player.dart';
import 'package:amity_uikit_beta_service/viewmodel/amity_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/create_post_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/media_viewmodel.dart';
import 'package:animation_wrappers/animations/fade_animation.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AmityCreatePostScreen extends StatefulWidget {
  final AmityCommunity? community;

  const AmityCreatePostScreen({
    super.key,
    this.community,
  });

  @override
  State<AmityCreatePostScreen> createState() => _AmityCreatePostScreenState();
}

class _AmityCreatePostScreenState extends State<AmityCreatePostScreen> {
  bool hasContent = true;

  @override
  void initState() {
    Provider.of<CreatePostVM>(context, listen: false).inits();
    Provider.of<MediaPickerVM>(context, listen: false).clearFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CreatePostVM>(builder: (context, vm, _) {
      return WillPopScope(
        onWillPop: () async {
          if (hasContent) {
            _showDiscardDialog();
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              widget.community != null
                  ? widget.community?.displayName ?? "Community"
                  : "My Feed",
              style: Provider.of<AmityUIConfiguration>(context).titleTextStyle,
            ),
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Colors.black,
              ),
              onPressed: () {
                if (hasContent) {
                  ConfirmationDialog().show(
                    context: context,
                    title: 'Discard Post?',
                    detailText: 'Do you want to discard your post?',
                    leftButtonText: 'Cancel',
                    rightButtonText: 'Discard',
                    onConfirm: () {
                      Navigator.of(context).pop();
                    },
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: hasContent
                    ? () async {
                        if (widget.community == null) {
                          //creat post in user Timeline
                          await vm.createPost(context,
                              callback: (isSuccess, error) {
                            if (isSuccess) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            } else {}
                          });
                        } else {
                          //create post in Community
                          await vm.createPost(context,
                              communityId: widget.community?.communityId ??
                                  "null", callback: (isSuccess, error) {
                            if (isSuccess) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            }
                          });
                        }

                        // ignore: use_build_context_synchronously
                      }
                    : null,
                child: Text(
                  "Post",
                ),
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                      color: hasContent
                          ? Provider.of<AmityUIConfiguration>(context)
                              .primaryColor
                          : Colors.grey),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: vm.textEditingController,
                            scrollPhysics: const NeverScrollableScrollPhysics(),
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Write something to post",
                            ),
                            // style: t/1heme.textTheme.bodyText1.copyWith(color: Colors.grey),
                          ),
                          (vm.amityVideo != null)
                              ? (Provider.of<MediaPickerVM>(context)
                                      .selectedFiles
                                      .isNotEmpty)
                                  ? Consumer<MediaPickerVM>(
                                      builder: (context, mediaPickerVM, _) {
                                      return LocalVideoPlayer(
                                          file: File(mediaPickerVM
                                              .selectedFiles[0].path));
                                    })
                                  : const CircularProgressIndicator()
                              : Container(),
                          Consumer<MediaPickerVM>(
                            builder: (context, mediaPickerVM, _) =>
                                _buildMediaGrid(mediaPickerVM.selectedFiles),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _iconButton(
                        Icons.camera_alt_outlined,
                        label: "Photo",
                        onTap: () {
                          // Provider.of<MediaPickerVM>(context, listen: false)
                          //     .captureImageWithCamera();
                        },
                      ),
                      _iconButton(
                        Icons.image_outlined,
                        label: "Image",
                        onTap: () async {
                          print("pick image");
                          var mediaPickerVM = Provider.of<MediaPickerVM>(
                              context,
                              listen: false);
                          await mediaPickerVM.pickMultipleImages();
                          for (var image in mediaPickerVM.selectedFiles) {
                            if (Provider.of<CreatePostVM>(context,
                                        listen: false)
                                    .getProgress(image.path) ==
                                null) {
                              print("image:${image.path}");
                              var file = File(image.path);
                              Provider.of<CreatePostVM>(context, listen: false)
                                  .uploadFile(file);
                            }
                          }
                        },
                      ),
                      _iconButton(
                        Icons.play_circle_outline,
                        label: "Video",
                        onTap: () async {
                          await Provider.of<CreatePostVM>(context,
                                  listen: false)
                              .addVideo();
                        },
                      ),
                      _iconButton(
                        Icons.attach_file_outlined,
                        label: "File",
                        onTap: () {
                          // TODO: Implement file adding logic
                        },
                      ),
                      _iconButton(
                        Icons.more_horiz,
                        label: "More",
                        onTap: () {
                          // TODO: Implement more options logic
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _iconButton(IconData icon,
      {required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[200],
          child: IconButton(
            icon: Icon(
              icon,
              size: 18,
              color: Colors.black,
            ),
            onPressed: onTap,
          ),
        ),
        // SizedBox(height: 4),
        // Text(label),
      ],
    );
  }

  Widget _buildMediaGrid(List<XFile> files) {
    if (files.isEmpty) return Container();

    Widget _backgroundImage(XFile file) {
      int rawprogress =
          Provider.of<CreatePostVM>(context).getProgress(file.path) ?? 100;
      var progress = rawprogress / 100.00;

      return Padding(
        padding:
            const EdgeInsets.all(2.0), // Padding of 2 pixels around the image
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(file.path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            progress == 1
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4.0, // adjust as needed
                        backgroundColor: Colors.black38,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
          ],
        ),
      );
    }

    switch (files.length) {
      case 1:
        return AspectRatio(
          aspectRatio: 1,
          child: _backgroundImage(files[0]),
        );

      case 2:
        return AspectRatio(
          aspectRatio: 1,
          child: Row(
            children: files
                .map((file) => Expanded(child: _backgroundImage(file)))
                .toList(),
          ),
        );

      case 3:
        return AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              Expanded(child: _backgroundImage(files[0])),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _backgroundImage(files[1])),
                    Expanded(child: _backgroundImage(files[2])),
                  ],
                ),
              ),
            ],
          ),
        );

      case 4:
        return AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              Expanded(child: _backgroundImage(files[0])),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _backgroundImage(files[1]),
                      ),
                    ),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _backgroundImage(files[2]),
                      ),
                    ),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _backgroundImage(files[3]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        return GridView.count(
          crossAxisCount: 3,
          children: files.map((file) => _backgroundImage(file)).toList(),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
        );
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discard Post?'),
        content: Text('Do you want to discard your post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pop();
            },
            child: Text('Discard'),
          ),
        ],
      ),
    );
  }
}
