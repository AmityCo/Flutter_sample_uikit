import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/follower_following_viewmodel.dart';

class AmityFollowingScreen extends StatefulWidget {
  final String userId;
  const AmityFollowingScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AmityFollowingScreen> createState() =>
      _AmityFollowingScreenScreenState();
}

class _AmityFollowingScreenScreenState extends State<AmityFollowingScreen> {
  @override
  void initState() {
    Provider.of<FollowerVM>(context, listen: false)
        .getFollowingListof(userId: widget.userId);
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
            await vm.getFollowingListof(userId: widget.userId);
          },
          child: vm.getFollowingList.isEmpty
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
                  itemCount: vm.getFollowingList.length,
                  itemBuilder: (context, index) {
                    return StreamBuilder<AmityFollowRelationship>(
                        // key: Key(vm.getFollowRelationships[index].sourceUserId! +
                        //     vm.getFollowRelationships[index].targetUserId!),
                        stream: vm.getFollowingList[index].listen,
                        initialData: vm.getFollowingList[index],
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                getAvatarImage(vm.getFollowingList[index]
                                    .sourceUser!.avatarUrl),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vm.getFollowingList[index].sourceUser!
                                                .displayName ??
                                            "displayname not found",
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Text(
                                        vm.getFollowingList[index].sourceUser!
                                                .userId ??
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
