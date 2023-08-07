import 'dart:developer';

import 'package:amity_uikit_beta_service/view/explore/explore_view.dart';
import 'package:amity_uikit_beta_service/view/news_feed/news_feed_view.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_app_bar.dart';
import '../../constans/app_text_style.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../social/search_communities.dart';

part './widgets/bottom_app_bar_community_view.dart';

class CommunityView extends StatelessWidget {
  const CommunityView({super.key, this.isShowAppbar = true});
  final bool isShowAppbar;
  @override
  Widget build(BuildContext context) {
    final appColors = context.watch<AmityUIConfiguration>();
    final appbarConfig = appColors.appbarConfig;
    return Consumer<CommunityViewModel>(
      builder: (_, vm, __) {
        return Scaffold(
          appBar: CustomAppBar(
            context: context,
            titleText: 'Community',
            centerTitle: false,
            actions: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchCommunitiesScreen(),
                  ),
                ),
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
              title: BottomAppBarCommunityView(
                names: vm.items,
                onChanged: vm.selectTab,
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
