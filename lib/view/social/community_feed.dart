import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import 'create_post_screen.dart';
import 'edit_community.dart';
import 'home_following_screen.dart';

class CommunityScreen extends StatefulWidget {
  final AmityCommunity community;
  final bool isFromFeed;

  const CommunityScreen(
      {Key? key, required this.community, this.isFromFeed = false})
      : super(key: key);

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    Provider.of<CommuFeedVM>(context, listen: false)
        .initAmityCommunityFeed(widget.community.communityId!);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getAvatarImage(String? url) {
    if (url != null) {
      return NetworkImage(url);
    } else {
      return const AssetImage("assets/images/user_placeholder.png");
    }
  }

  Widget communityDescription(CommuFeedVM vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.community.description == null
            ? Container()
            : const Text(
                "About",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
        const SizedBox(
          height: 5.0,
        ),
        Text(widget.community.description ?? ""),
      ],
    );
  }

  void onCommunityOptionTap(CommunityFeedMenuOption option) {
    switch (option) {
      case CommunityFeedMenuOption.edit:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditCommunityScreen(widget.community)));
        break;
      case CommunityFeedMenuOption.members:
        break;
      default:
    }
  }

  Widget communityInfo(CommuFeedVM vm) {
    return Column(
      children: [
        Row(
          children: [
            Text(
                widget.community.displayName != null
                    ? widget.community.displayName!
                    : "Community",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            IconButton(
                onPressed: () {
                  if (vm.isCurrentUserIsAdmin) {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: Text(
                                    "Edit Community:${AmityCoreClient.getCurrentUser().roles}"),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  onCommunityOptionTap(
                                      CommunityFeedMenuOption.edit);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.people_alt_rounded),
                                title: const Text('Members'),
                                onTap: () {
                                  onCommunityOptionTap(
                                      CommunityFeedMenuOption.members);
                                },
                              ),
                              const ListTile(
                                title: Text(''),
                              ),
                            ],
                          );
                          // return SizedBox(
                          //   height: 200,
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: const <Widget>[],
                          //   ),
                          // );
                        });
                  }
                },
                icon: Icon(Icons.more_horiz_rounded,
                    color: vm.isCurrentUserIsAdmin
                        ? Colors.black
                        : Colors.grey[200]))
          ],
        ),
        Row(
          children: [
            const Icon(Icons.public_rounded, color: Colors.black),
            const SizedBox(
              width: 5,
            ),
            Text(widget.community.isPublic != null
                ? (widget.community.isPublic! ? "Public" : "Private")
                : "N/A"),
            const SizedBox(
              width: 20,
            ),
            Text("${widget.community.membersCount} members"),
            const Spacer(),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                Provider.of<AmityUIConfiguration>(context).primaryColor,
              )),
              onPressed: () {
                if (widget.community.isJoined != null) {
                  if (widget.community.isJoined!) {
                    AmitySocialClient.newCommunityRepository()
                        .leaveCommunity(widget.community.communityId!)
                        .then((value) {
                      setState(() {
                        widget.community.isJoined =
                            !(widget.community.isJoined!);
                      });
                    }).onError((error, stackTrace) {
                      //handle error
                      log(error.toString());
                    });
                  } else {
                    AmitySocialClient.newCommunityRepository()
                        .joinCommunity(widget.community.communityId!)
                        .then((value) {
                      setState(() {
                        widget.community.isJoined =
                            !(widget.community.isJoined!);
                      });
                    }).onError((error, stackTrace) {
                      log(error.toString());
                    });
                  }
                }
              },
              child: Text(widget.community.isJoined != null
                  ? (widget.community.isJoined! ? "Leave" : "Join")
                  : "N/A"),
            )
          ],
        )
      ],
    );
  }

  Widget communityDetailSection(CommuFeedVM vm) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: widget.community.avatarImage?.fileUrl == null ||
                      widget.community.avatarImage?.fileUrl == ""
                  ? const SizedBox()
                  : OptimizedCacheImage(
                      height: 400,
                      imageUrl:
                          "${widget.community.avatarImage!.fileUrl}?size=full",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 400,
                        color: Colors.grey,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              communityInfo(vm),
              const Divider(),
              communityDescription(vm)
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final myAppBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chevron_left),
      ),
      elevation: 0,
    );
    final theme = Theme.of(context);
    //final mediaQuery = MediaQuery.of(context);
    //final bHeight = mediaQuery.size.height - mediaQuery.padding.top;

    return Consumer<CommuFeedVM>(builder: (__, vm, _) {
      return Scaffold(
        appBar: myAppBar,
        floatingActionButton: (widget.community.isJoined!)
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context2) => CreatePostScreen2(
                            communityID: widget.community.communityId,
                            context: context,
                          )));
                },
                backgroundColor:
                    Provider.of<AmityUIConfiguration>(context).primaryColor,
                child: const Icon(Icons.add),
              )
            : null,
        backgroundColor: Colors.grey[200],
        body: RefreshIndicator(
          color: Provider.of<AmityUIConfiguration>(context).primaryColor,
          onRefresh: () async {
            Provider.of<CommuFeedVM>(context, listen: false)
                .initAmityCommunityFeed(widget.community.communityId!);
          },
          child: FadedSlideAnimation(
            beginOffset: const Offset(0, 0.3),
            endOffset: const Offset(0, 0),
            slideCurve: Curves.linearToEaseOut,
            child: SafeArea(
              child: SingleChildScrollView(
                controller: vm.scrollcontroller,
                child: Column(
                  children: [
                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: IconButton(
                    //     onPressed: () {
                    //       Navigator.of(context).pop();
                    //     },
                    //     icon: const Icon(Icons.chevron_left,
                    //         color: Colors.black, size: 35),
                    //   ),
                    // ),
                    SizedBox(
                        width: double.infinity,
                        // height: (bHeight - 120) * 0.4,
                        child: communityDetailSection(vm)),
                    FadedSlideAnimation(
                      beginOffset: const Offset(0, 0.3),
                      endOffset: const Offset(0, 0),
                      slideCurve: Curves.linearToEaseOut,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: vm.getCommunityPosts().length,
                        itemBuilder: (context, index) {
                          return StreamBuilder<AmityPost>(
                              key: Key(vm.getCommunityPosts()[index].postId!),
                              stream: vm.getCommunityPosts()[index].listen,
                              initialData: vm.getCommunityPosts()[index],
                              builder: (context, snapshot) {
                                return PostWidget(
                                  post: snapshot.data!,
                                  theme: theme,
                                  postIndex: index,
                                  isCommunity: true,
                                );
                              });
                        },
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
