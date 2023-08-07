import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../create_community/create_community.dart';
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
  late AmityCommunity community;
  @override
  void initState() {
    community = widget.community;
    Provider.of<CommuFeedVM>(context, listen: false)
        .initAmityCommunityFeed(community);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadData() {
    AmitySocialClient.newCommunityRepository()
        .getCommunity(community.communityId!)
        .then((value) {
      setState(() {
        community = value;
      });
    }).onError((error, stackTrace) {
      //handle error
    });
  }

  Widget communityDescription(CommuFeedVM vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        community.description == null
            ? Container()
            : const Text(
                "About",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
        const SizedBox(
          height: 5.0,
        ),
        Text(community.description ?? ""),
      ],
    );
  }

  void onCommunityOptionTap(CommunityFeedMenuOption option) {
    switch (option) {
      case CommunityFeedMenuOption.edit:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditCommunityScreen(community)));
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
            Flexible(
              child: Text(
                community.displayName != null
                    ? community.displayName!
                    : "Community",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (vm.isCurrentUserIsAdmin) const SizedBox(width: 5),
            if (vm.isCurrentUserIsAdmin)
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
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    final result =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CreateCommunityView(
                                          community: community,
                                        ),
                                      ),
                                    );
                                    if (result != null && !result) {
                                      loadData();
                                    }
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
            Text(community.isPublic != null
                ? (community.isPublic! ? "Public" : "Private")
                : "N/A"),
            const SizedBox(
              width: 20,
            ),
            Text("${community.membersCount} members"),
            const Spacer(),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                Provider.of<AmityUIConfiguration>(context).primaryColor,
              )),
              onPressed: () {
                if (community.isJoined != null) {
                  if (community.isJoined!) {
                    AmitySocialClient.newCommunityRepository()
                        .leaveCommunity(community.communityId!)
                        .then((value) {
                      setState(() {
                        community.isJoined = !(community.isJoined!);
                      });
                    }).onError((error, stackTrace) {
                      //handle error
                      log('ERROR CommunityScreen leaveCommunity:$error');
                    });
                  } else {
                    AmitySocialClient.newCommunityRepository()
                        .joinCommunity(community.communityId!)
                        .then((value) {
                      setState(() {
                        community.isJoined = !(community.isJoined!);
                      });
                    }).onError((error, stackTrace) {
                      log('ERROR CommunityScreen joinCommunity:$error');
                    });
                  }
                }
              },
              child: Text(community.isJoined != null
                  ? (community.isJoined! ? "Leave" : "Join")
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
              child: community.avatarImage?.fileUrl == null ||
                      community.avatarImage?.fileUrl == ""
                  ? const SizedBox()
                  : OptimizedCacheImage(
                      height: 400,
                      imageUrl: "${community.avatarImage!.fileUrl}?size=full",
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
    final theme = Theme.of(context);

    return Consumer<CommuFeedVM>(builder: (__, vm, _) {
      return Scaffold(
        appBar: CustomAppBar(context: context),
        floatingActionButton: (community.isJoined!)
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context2) => CreatePostScreen2(
                            communityID: community.communityId,
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
                .initAmityCommunityFeed(community);
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
                              stream:
                                  vm.getCommunityPosts()[index].listen.stream,
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
