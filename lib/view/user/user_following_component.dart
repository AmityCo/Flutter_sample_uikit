import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_avatar_label_name.dart';
import '../../viewmodel/follower_following_viewmodel.dart';

class AmityFollowingScreen extends StatefulWidget {
  final String userId;
  final ValueChanged<AmityUser>? onPressedUser;
  const AmityFollowingScreen({
    Key? key,
    required this.userId,
    this.onPressedUser,
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
      return FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: RefreshIndicator(
          onRefresh: () async {
            await vm.getFollowingListof(userId: widget.userId);
          },
          child: ListView.builder(
            controller: vm.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: vm.getFollowingList.length,
            itemBuilder: (context, index) {
              return StreamBuilder<AmityFollowRelationship>(
                  // key: Key(vm.getFollowRelationships[index].targetUserId! +
                  //     vm.getFollowRelationships[index].targetUserId!),
                  stream: vm.getFollowingList[index].listen.stream,
                  initialData: vm.getFollowingList[index],
                  builder: (context, snapshot) {
                    final user = vm.getFollowingList[index].targetUser!;
                    return CustomAvatarLabelName(
                        url: user.avatarUrl,
                        name: user.displayName,
                        onTap: () {
                          if (widget.onPressedUser != null) {
                            widget.onPressedUser!(user);
                          }
                        });
                  });
            },
          ),
        ),
      );
    });
  }
}
