import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import 'all_category_list.dart';
import 'community_type_list.dart';

class CommunityTabbar extends StatelessWidget {
  const CommunityTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: TabBar(
          physics: const BouncingScrollPhysics(),
          isScrollable: true,
          indicatorColor:
              Provider.of<AmityUIConfiguration>(context).primaryColor,
          labelColor: Provider.of<AmityUIConfiguration>(context).primaryColor,
          unselectedLabelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "Recommended"),
            Tab(text: "Trending"),
            Tab(text: "Joined"),
            Tab(text: "Categories"),
          ],
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            CommunityList(CommunityListType.recommend),
            CommunityList(CommunityListType.trending),
            CommunityList(CommunityListType.my),
            AllCategoryList()
          ],
        ),
      ),
    );
  }
}
