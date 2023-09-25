import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_avatar_label_name.dart';
import '../../viewmodel/follower_following_viewmodel.dart';

class AmityFollowerScreen extends StatefulWidget {
  final String userId;
  final ValueChanged<AmityUser>? onPressedUser;
  const AmityFollowerScreen({
    Key? key,
    required this.userId,
    this.onPressedUser,
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
      return FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: RefreshIndicator(
          onRefresh: () async {
            await vm.getFollowerListOf(userId: widget.userId);
          },
          child: vm.getFollowerList.isEmpty
              ? const SizedBox()
              : ListView.builder(
                  controller: vm.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: vm.getFollowerList.length,
                  itemBuilder: (context, index) {
                    return StreamBuilder<AmityFollowRelationship>(
                        stream: vm.getFollowerList[index].listen.stream,
                        initialData: vm.getFollowerList[index],
                        builder: (context, snapshot) {
                          final user = vm.getFollowerList[index].sourceUser!;
                          return CustomAvatarLabelName(
                            url: user.avatarUrl,
                            name: user.displayName,
                            onTap: () {
                              if (widget.onPressedUser != null) {
                                widget.onPressedUser!(user);
                              }
                            },
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
