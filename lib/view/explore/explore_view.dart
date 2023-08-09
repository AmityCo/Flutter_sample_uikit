import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../social/community_feed.dart';
import 'widgets/categories_explore.dart';
import 'widgets/recommended_explore.dart';
import 'widgets/trending_explore.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    context.read<CommunityVM>().initAmityRecommendCommunityList();
    context.read<CommunityVM>().initAmityTrendingCommunityList();
  }

  Future<void> navigationToCommunity(AmityCommunity community) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<CommuFeedVM>(
          create: (context) => CommuFeedVM(),
          builder: (context, child) => CommunityScreen(
            community: community,
          ),
        ),
      ),
    );
    init();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFadedSlideAnimation(
      child: Consumer<CommunityVM>(
        builder: (_, vm, __) {
          final recommend = vm.getAmityRecommendCommunities();
          final trending = vm.getAmityTrendingCommunities();
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                RecommendedExplore(
                  data: recommend,
                  onPressedCommunity: navigationToCommunity,
                ),
                TrendingExplore(
                  data: trending,
                  onPressedCommunity: navigationToCommunity,
                ),
                const CategoriesExplore(),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
