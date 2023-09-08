import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/accept_dialog.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/constans/app_assets.dart';
import 'package:amity_uikit_beta_service/constans/app_string.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../components/custom_faded_slide_animation.dart';
import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../create_community/create_community.dart';
import '../member_list_community/member_list_community_view.dart';
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
            : Text(
                "About",
                style: AppTextStyle.header2
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 16),
              ),
        const SizedBox(
          height: 5.0,
        ),
        Text(community.description ?? ""),
      ],
    );
  }

  void onCommunityOptionTap(CommunityFeedMenuOption option) {
    Navigator.of(context).pop();
    switch (option) {
      case CommunityFeedMenuOption.edit:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditCommunityScreen(community)));
        break;
      case CommunityFeedMenuOption.members:
        navigatorToMemberList();
        break;
      default:
    }
  }

  void navigatorToMemberList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemberListCommunityView(community: community),
      ),
    );
  }

  void onPressedLeave() {
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
  }

  Widget communityInfo(CommuFeedVM vm) {
    return Column(
      children: [
        Row(
          children: [
            if (community.isOfficial ?? false)
              SvgPicture.asset(
                AppAssets.verified,
                width: 25,
                height: 25,
                package: AppAssets.package,
              ),
            Flexible(
              child: Text(
                community.displayName != null
                    ? community.displayName!
                    : "Community",
                style: AppTextStyle.header1.copyWith(
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
                                  title: const Text("Edit Community"),
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
            (community.isPublic ?? true)
                ? const Icon(Icons.public_rounded, color: Colors.black)
                : const Icon(Icons.lock, color: Colors.black),
            const SizedBox(width: 5),
            Text(community.isPublic != null
                ? (community.isPublic! ? "Public" : "Private")
                : "N/A"),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: navigatorToMemberList,
              child: Text(
                  "${community.membersCount} ${((community.membersCount ?? 0) > 1) ? 'members' : 'member'}"),
            ),
            const Spacer(),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                Provider.of<AmityUIConfiguration>(context)
                    .buttonConfig
                    .backgroundColor,
              )),
              onPressed: () {
                if (community.isJoined != null) {
                  if (community.isJoined!) {
                    final acceptDialog = AcceptDialog();
                    acceptDialog.open(
                        context: context,
                        acceptButtonConfig: context
                            .read<AmityUIConfiguration>()
                            .acceptButtonConfig,
                        title: 'Leave community',
                        message: AppString.messageConfrimLeave,
                        acceptText: AppString.leaveButton,
                        onPressedCancel: () {
                          acceptDialog.close();
                        },
                        onPressedAccept: () {
                          onPressedLeave();
                          acceptDialog.close();
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
              child: Text(
                community.isJoined != null
                    ? (community.isJoined! ? "Leave" : "Join")
                    : "N/A",
                style: AppTextStyle.header2.copyWith(
                  color: Provider.of<AmityUIConfiguration>(context)
                      .buttonConfig
                      .textColor,
                ),
              ),
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
                  : CachedNetworkImage(
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

  void onRefreshPage() {
    Provider.of<CommuFeedVM>(context, listen: false)
        .initAmityCommunityFeed(community);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CommuFeedVM>(builder: (__, vm, _) {
      return Scaffold(
        appBar: CustomAppBar(context: context),
        floatingActionButton: (community.isJoined!)
            ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context2) => CreatePostScreen2(
                        communityID: community.communityId,
                        context: context,
                      ),
                    ),
                  );
                  onRefreshPage();
                },
                backgroundColor: Provider.of<AmityUIConfiguration>(context)
                    .buttonConfig
                    .backgroundColor,
                child: Icon(
                  Icons.add,
                  color: Provider.of<AmityUIConfiguration>(context)
                      .buttonConfig
                      .textColor,
                ),
              )
            : null,
        backgroundColor: Colors.grey[200],
        body: RefreshIndicator(
          color: Provider.of<AmityUIConfiguration>(context).primaryColor,
          onRefresh: () async {
            onRefreshPage();
          },
          child: CustomFadedSlideAnimation(
            child: SafeArea(
              child: SingleChildScrollView(
                controller: vm.scrollcontroller,
                child: Column(
                  children: [
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
