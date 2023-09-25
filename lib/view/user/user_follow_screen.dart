import 'package:amity_sdk/amity_sdk.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../amity_uikit_beta_service.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/follower_following_viewmodel.dart';
import '../../viewmodel/user_feed_viewmodel.dart';
import 'user_follower_component.dart';
import 'user_following_component.dart';

class FollowScreen extends StatefulWidget {
  final AmityUser user;
  final int initialIndex;
  const FollowScreen({super.key, required this.user, this.initialIndex = 0});
  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  TabController? _tabController;

  void navigatorToUserProfile(AmityUser user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => UserFeedVM(),
          child: UserProfileScreen(
            amityUser: user,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            context.watch<AmityUIConfiguration>().appbarConfig.backgroundColor,
        title: Text(
          widget.user.displayName ?? "displayname is null",
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontSize: 24,
                color: context
                    .watch<AmityUIConfiguration>()
                    .appbarConfig
                    .textColor,
              ),
        ),
      ),
      backgroundColor: context
          .watch<AmityUIConfiguration>()
          .messageRoomConfig
          .backgroundColor,
      body: SafeArea(
        bottom: false,
        child: DefaultTabController(
          length: 2,
          initialIndex: widget.initialIndex,
          child: Scaffold(
            body: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor:
                      Provider.of<AmityUIConfiguration>(context).primaryColor,
                  tabs: [
                    Tab(
                      child: Text(
                        "Followers",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Following",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Consumer<FollowerVM>(builder: (context, vm, _) {
                    return TabBarView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        AmityFollowerScreen(
                          userId: widget.user.userId!,
                          onPressedUser: navigatorToUserProfile,
                        ),
                        AmityFollowingScreen(
                          userId: widget.user.userId!,
                          onPressedUser: navigatorToUserProfile,
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
