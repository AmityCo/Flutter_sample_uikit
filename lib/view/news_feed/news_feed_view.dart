import 'package:flutter/material.dart';
import '../social/home_following_screen.dart';
import 'widgets/my_community_view.dart';


class NewsfeedView extends StatelessWidget {
  const NewsfeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        MyCommunityHorizontalView(),
        Expanded(
          child: GlobalFeedScreen(),
        ),
      ],
    );
  }
}