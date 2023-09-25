import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:linkify/linkify.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../components/video_player.dart';
import '../../constans/app_text_style.dart';
import '../post_detail/comments.dart';
import 'image_viewer.dart';

class AmityPostWidget extends StatefulWidget {
  final List<AmityPost> posts;
  final bool isChildrenPost;
  final bool isCornerRadiusEnabled;
  final bool haveChildrenPost;
  final bool shouldShowTextPost;

  const AmityPostWidget(
      this.posts, this.isChildrenPost, this.isCornerRadiusEnabled,
      {super.key,
      this.haveChildrenPost = false,
      this.shouldShowTextPost = true});
  @override
  AmityPostWidgetState createState() => AmityPostWidgetState();
}

class AmityPostWidgetState extends State<AmityPostWidget> {
  List<String> imageURLs = [];
  String? videoUrl;
  bool isLoading = true;
  Map<String, PreviewData> datas = {};
  @override
  void initState() {
    super.initState();
    if (!widget.isChildrenPost) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      checkPostType();
    }
  }

  Future<void> checkPostType() async {
    switch (widget.posts[0].type) {
      case AmityDataType.IMAGE:
        await getImagePost();
        break;
      case AmityDataType.VIDEO:
        await getVideoPost();
        break;
      default:
        break;
    }
  }

  Future<void> getVideoPost() async {
    // final videoData = widget.posts[0].data as VideoData;

    // await videoData.getVideo(AmityVideoQuality.HIGH).then((AmityVideo video) {
    //   if (this.mounted) {
    //     setState(() {
    //       isLoading = false;
    //       videoUrl = video.fileUrl;
    //       log(">>>>>>>>>>>>>>>>>>>>>>>>${videoUrl}");
    //     });
    //   }
    // });
  }

  Future<void> getImagePost() async {
    List<String> imageUrlList = [];

    for (var post in widget.posts) {
      final imageData = post.data as ImageData;
      if (imageData.image != null) {
        final largeImageUrl = imageData.getUrl(AmityImageSize.LARGE);
        imageUrlList.add(largeImageUrl);
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
        imageURLs = imageUrlList;
      });
    }
  }

  bool urlValidation(AmityPost post) {
    final url = extractLink(post); //urlExtraction(post);
    log("checking url validation $url");
    return AnyLinkPreview.isValidLink(url);
  }

  Future<void> _launchUrl(String url) async {
    if (!await canLaunchUrlString(url)) {
      throw 'Could not launch $url';
    } else {
      await launchUrlString(url, mode: LaunchMode.inAppWebView);
    }
  }

  String extractLink(AmityPost post) {
    final textdata = post.data as TextData;
    final text = textdata.text ?? "";
    var elements = linkify(text,
        options: const LinkifyOptions(
          humanize: false,
          defaultToHttps: true,
        ));
    for (var e in elements) {
      if (e is LinkableElement) {
        return e.url;
      }
    }
    return "";
  }

  Widget generateURLWidget(String url) {
    final style = AppTextStyle.mainStyle.copyWith(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.375,
    );

    return LinkPreview(
      enableAnimation: true,
      onPreviewDataFetched: (data) {
        setState(() {
          datas = {
            ...datas,
            url: data,
          };
        });
      },
      previewData: datas[url],
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      imageBuilder: ((imageUrl) {
        return
            // OptimizedCacheImage(
            //   imageUrl: url,
            //   fit: BoxFit.fill,
            //   placeholder: (context, url) => Container(
            //     color: Colors.grey,
            //   ),
            //   errorWidget: (context, url, error) => const Icon(Icons.error),
            // );
            Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          height: 150,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
            ),
          ),
        );
      }),
      metadataTextStyle: style.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      animationDuration: const Duration(milliseconds: 300),
      metadataTitleStyle: style.copyWith(
        fontWeight: FontWeight.w800,
      ),
      textWidget: const SizedBox(
        height: 0,
      ),
      text: url,
      width: MediaQuery.of(context).size.width,
      onLinkPressed: ((url) {
        _launchUrl(url);
      }),
      openOnPreviewImageTap: true,
      openOnPreviewTitleTap: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isChildrenPost) {
      if (widget.haveChildrenPost || !urlValidation(widget.posts[0])) {
        return TextPost(post: widget.posts[0]);
      } else {
        String url =
            extractLink(widget.posts[0]); //urlExtraction(widget.posts[0]);

        return Column(
          children: [
            // Text(url),
            widget.shouldShowTextPost
                ? TextPost(post: widget.posts[0])
                : Container(),
            generateURLWidget(url.toLowerCase())
            // AnyLinkPreview(
            //   link: url.toLowerCase(),
            //   displayDirection: UIDirection.uiDirectionVertical,
            //   // showMultimedia: false,
            //   bodyMaxLines: 5,
            //   bodyTextOverflow: TextOverflow.ellipsis,
            //   titleStyle: TextStyle(
            //     color: Colors.black,
            //     fontWeight: FontWeight.bold,
            //     fontSize: 15,
            //   ),
            //   bodyStyle: TextStyle(color: Colors.grey, fontSize: 12),
            //   errorBody: 'Error getting body',
            //   errorTitle: 'Error getting title',
            //   errorWidget: Container(
            //     color: Colors.grey[300],
            //     child: Text('Oops!'),
            //   ),
            //   // errorImage: "https://google.com/",
            //   cache: const Duration(days: 0),
            //   backgroundColor: Colors.grey[100],
            //   borderRadius: 0,
            //   removeElevation: true,
            //   boxShadow: null, //[BoxShadow(blurRadius: 3, color: Colors.grey)],
            //   onTap: () {}, // This disables tap event
            // )
          ],
        );
      }
    } else {
      switch (widget.posts[0].type) {
        case AmityDataType.IMAGE:
          return ImagePost(
              posts: widget.posts,
              imageURLs: imageURLs,
              isCornerRadiusEnabled:
                  widget.isCornerRadiusEnabled || imageURLs.length > 1
                      ? true
                      : false);
        case AmityDataType.VIDEO:
          return MyVideoPlayer2(
              post: widget.posts[0],
              url: videoUrl ?? "",
              isInFeed: widget.isCornerRadiusEnabled,
              isEnableVideoTools: false);
        default:
          return Container();
      }
    }
  }
}

class TextPost extends StatelessWidget {
  final AmityPost post;
  const TextPost({Key? key, required this.post}) : super(key: key);

  Widget buildURLWidget(String text) {
    return LinkWell(text);
  }

  @override
  Widget build(BuildContext context) {
    final textdata = post.data as TextData;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.start,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CommentScreen(
                                  amityPost: post,
                                )));
                      },
                      child: post.type == AmityDataType.TEXT
                          ? textdata.text == null
                              ? const SizedBox()
                              : textdata.text!.isEmpty
                                  ? const SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: buildURLWidget(
                                          textdata.text.toString())
                                      // Text(
                                      //   textdata.text.toString(),
                                      //   style:
                                      //       const TextStyle(fontSize: 18),
                                      // ),
                                      )
                          : Container()),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

class ImagePost extends StatelessWidget {
  final List<AmityPost> posts;
  final List<String> imageURLs;
  final bool isCornerRadiusEnabled;
  const ImagePost(
      {Key? key,
      required this.posts,
      required this.imageURLs,
      required this.isCornerRadiusEnabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 250.0,
        disableCenter: false,
        enableInfiniteScroll: imageURLs.length > 1,
        viewportFraction: imageURLs.length > 1 ? 0.9 : 1.0,
      ),
      items: imageURLs.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                _goToImageViewer(context, url);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(
                    horizontal: imageURLs.length > 1 ? 5.0 : 0.0),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(isCornerRadiusEnabled ? 10 : 0),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  void _goToImageViewer(BuildContext context, String url) {
    showDialog(
        context: context,
        useSafeArea: false,
        builder: (_) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: ImageViewer(
                imageURLs: imageURLs, 
                initialIndex: imageURLs.indexOf(url),
                ),
          );
        },
    );
  }
}
