import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_avatar.dart';
import 'package:amity_uikit_beta_service/view/explore/explore_view.dart';
import 'package:amity_uikit_beta_service/view/news_feed/news_feed_view.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_app_bar.dart';
import '../../constans/app_text_style.dart';
import '../../viewmodel/amity_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/feed_viewmodel.dart';
import '../social/search_communities.dart';
import '../user/user_profile.dart';

part './widgets/bottom_app_bar_community_view.dart';

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      context.read<CommunityViewModel>().selectTab(0);
    }
  }

  Future<void> navigaatorToUserProfile(AmityUser user) async {
    await showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => UserProfileScreen(
        amityUser: user,
      ),
    );
    onRefresh();
  }

  void onRefresh(){
    Provider.of<FeedVM>(context, listen: false).initAmityGlobalfeed();
    context.read<CommunityVM>().initAmityMyCommunityList();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.watch<AmityUIConfiguration>();
    final appbarConfig = appColors.appbarConfig;
    return Consumer2<CommunityViewModel, AmityVM>(
      builder: (_, vm, amityVM, __) {
        return Scaffold(
          appBar: CustomAppBar(
            context: context,
            titleText: 'Community',
            centerTitle: false,
            enableLeading: false,
            actions: [
              GestureDetector(
                onTap: () {
                  if (amityVM.currentamityUser != null) {
                    navigaatorToUserProfile(amityVM.currentamityUser!);
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomAvatar(
                      radius: 15,
                      url: amityVM.currentamityUser?.avatarUrl,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await showDialog(
                    context: context,
                    useSafeArea: false,
                    builder: (context) => const SearchCommunitiesScreen(),
                  );
                  onRefresh();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Icon(
                    Icons.search,
                    color: appbarConfig.iconBackColor,
                  ),
                ),
              ),
            ],
            bottom: CustomAppBar(
              context: context,
              centerTitle: false,
              toolbarHeight: 48,
              enableLeading: false,
              title: BottomAppBarCommunityView(
                names: vm.items,
                onChanged: vm.selectTab,
                controller: vm.state.controller,
              ),
            ),
          ),
          body: selectWidget(context, vm.state.currentIndex),
        );
      },
    );
  }

  Widget selectWidget(BuildContext context, int index) {
    switch (index) {
      case 1:
        return const ExploreView();
      default:
        return const NewsfeedView();
    }
  }
}
