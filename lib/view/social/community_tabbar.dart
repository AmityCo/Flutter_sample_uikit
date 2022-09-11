import 'package:flutter/material.dart';

import '../../viewmodel/community_viewmodel.dart';
import 'community_list.dart';

class CommunityTabbar extends StatelessWidget {
  const CommunityTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TabBar(
          physics: const BouncingScrollPhysics(),
          isScrollable: true,
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "Recommend"),
            Tab(text: "Trending"),
            Tab(text: "My"),
          ],
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            CommunityList(CommunityListType.recommend),
            CommunityList(CommunityListType.trending),
            CommunityList(CommunityListType.my),
          ],
        ),
      ),
    );
  }
}
