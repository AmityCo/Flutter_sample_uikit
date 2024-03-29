import 'dart:developer';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class LocalVideoPlayer extends StatefulWidget {
  final File file;
  const LocalVideoPlayer({Key? key, required this.file}) : super(key: key);

  @override
  State<LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.file(widget.file);
    await videoPlayerController.initialize();
    ChewieController controller = ChewieController(
      showControlsOnInitialize: true,
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ],
      looping: true,
    );

    controller.setVolume(0.0);

    setState(() {
      chewieController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 250,
        color: const Color.fromRGBO(0, 0, 0, 1),
        child: Center(
          child: chewieController != null &&
                  chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(
                  controller: chewieController!,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      'Loading',
                      style: AppTextStyle.header2
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

class MyVideoPlayer2 extends StatefulWidget {
  final String url;
  final AmityPost post;
  final bool isInFeed;
  final bool isEnableVideoTools;
  final VideoData? videoData;
  const MyVideoPlayer2({
    Key? key,
    required this.url,
    required this.isInFeed,
    required this.isEnableVideoTools,
    required this.post,
    this.videoData,
  }) : super(key: key);

  @override
  State<MyVideoPlayer2> createState() => _MyVideoPlayer2State();
}

class _MyVideoPlayer2State extends State<MyVideoPlayer2> {
  String? thumbnailURL;
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    VideoData? vData;
    if (widget.post.data is VideoData) {
      var postData = widget.post.data as VideoData;
      vData = postData;
    } else if (widget.videoData != null) {
      vData = widget.videoData;
    }

    if (vData != null) {
      if (vData.thumbnail != null) {
        thumbnailURL = vData.thumbnail!.fileUrl;
        log(thumbnailURL.toString());
      }
    }

    if (!widget.isInFeed) {
      initializePlayer();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (!widget.isInFeed) {
      videoPlayerController.dispose();
    }
    if (!widget.isInFeed) {
      if (chewieController != null) {
        chewieController!.dispose();
      }
    }

    super.dispose();
  }

  Future<void> initializePlayer() async {
    var videoUrl = "";
    final videoData = widget.post.data as VideoData;

    await videoData.getVideo(AmityVideoQuality.HIGH).then((AmityVideo video) {
      if (mounted) {
        setState(() {
          videoUrl = video.fileUrl ?? '';
          log(">>>>>>>>>>>>>>>>>>>>>>>>$videoUrl");
        });
      }
    });
    final videoUri = Uri.parse(videoUrl);
    videoPlayerController = VideoPlayerController.networkUrl(videoUri);
    await videoPlayerController.initialize();

    var chewieProgressColors = ChewieProgressColors(
        // backgroundColor: Theme.of(context).primaryColor,
        // bufferedColor: Theme.of(context).primaryColor
        // ignore: use_build_context_synchronously
        handleColor: Theme.of(context).primaryColor,
        // ignore: use_build_context_synchronously
        playedColor: Theme.of(context).primaryColor);

    ChewieController controller = ChewieController(
      showControlsOnInitialize: false,
      materialProgressColors: chewieProgressColors,
      cupertinoProgressColors: chewieProgressColors,
      showControls: widget.isInFeed ? false : true,
      videoPlayerController: videoPlayerController,
      autoPlay: widget.isInFeed ? false : true,
      allowPlaybackSpeedChanging: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ],
      looping: true,
    );

    if (widget.isInFeed) {
      controller.setVolume(0.0);
    } else {
      controller.setVolume(50);
    }

    setState(() {
      chewieController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.isInFeed ? 10 : 0),
              child: Container(
                height: 250,
                color: const Color.fromRGBO(0, 0, 0, 1),
                child: Center(
                    child: !widget.isInFeed
                        ? chewieController != null &&
                                chewieController!
                                    .videoPlayerController.value.isInitialized
                            ? GestureDetector(
                                onDoubleTap: (() {
                                  chewieController!.enterFullScreen();
                                }),
                                child: Chewie(
                                  controller: chewieController!,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // CircularProgressIndicator(
                                  //   color: Theme.of(context).primaryColor,
                                  // )
                                ],
                              )
                        : CachedNetworkImage(
                            imageBuilder: (context, imageProvider) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Row(
                                  children: [
                                    Expanded(
                                      child: Image(
                                        image: imageProvider,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                            imageUrl: thumbnailURL ?? "",
                            fit: BoxFit.fill,
                            placeholder: (context, url) => const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //  CircularProgressIndicator()
                              ],
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )),
              ),
            ),
            widget.isInFeed
                ? CircleAvatar(
                    backgroundColor: Theme.of(context).highlightColor,
                    child: Icon(
                      Icons.play_arrow,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
