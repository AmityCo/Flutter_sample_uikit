import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_user_avatar.dart';
import 'package:amity_uikit_beta_service/viewmodel/follower_viewmodel.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/configuration_viewmodel.dart';

class FollowScreen extends StatefulWidget {
  final String userId;
  const FollowScreen({super.key, required this.userId});

  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  TabController? _tabController;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Provider.of<AmityUIConfiguration>(context)
          .messageRoomConfig
          .backgroundColor,
      body: SafeArea(
        bottom: false,
        child: DefaultTabController(
          length: 2,
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
                        "Follower",
                        style: theme.textTheme.bodyText1,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Following",
                        style: theme.textTheme.bodyText1,
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
                          userId: widget.userId,
                        ),
                        Container(
                          color: Colors.blue,
                        )
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

class AmityFollowerScreen extends StatefulWidget {
  final String userId;
  const AmityFollowerScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AmityFollowerScreen> createState() => _AmityFollowerScreenState();
}

class _AmityFollowerScreenState extends State<AmityFollowerScreen> {
  @override
  void initState() {
    Provider.of<FollowerVM>(context, listen: false)
        .getFollowerListOf(userId: widget.userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowerVM>(builder: (context, vm, _) {
      final theme = Theme.of(context);
      return FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: RefreshIndicator(
          onRefresh: () async {
            await vm.getFollowerListOf(userId: widget.userId);
          },
          child: vm.getFollowRelationships.isEmpty
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Provider.of<AmityUIConfiguration>(context)
                                .primaryColor,
                          )
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  controller: vm.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: vm.getFollowRelationships.length,
                  itemBuilder: (context, index) {
                    return StreamBuilder<AmityFollowRelationship>(
                        // key: Key(vm.getFollowRelationships[index].sourceUserId! +
                        //     vm.getFollowRelationships[index].targetUserId!),
                        stream: vm.getFollowRelationships[index].listen,
                        initialData: vm.getFollowRelationships[index],
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                getAvatarImage(vm.getFollowRelationships[index]
                                    .sourceUser!.avatarUrl),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vm.getFollowRelationships[index]
                                                .sourceUser!.displayName ??
                                            "displayname not found",
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Text(
                                        vm.getFollowRelationships[index]
                                                .sourceUser!.userId ??
                                            "displayname not found",
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                          // return Text(snapshot.data!.status.toString());
                        });
                  },
                ),
        ),
      );
    });
  }
}
