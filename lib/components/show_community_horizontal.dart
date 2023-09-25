import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../constans/app_assets.dart';
import '../constans/app_text_style.dart';
import '../view/social/community_feed.dart';
import '../viewmodel/community_feed_viewmodel.dart';
import 'custom_list_tile.dart';

class ShowCommunityHorizontal extends StatelessWidget {
  const ShowCommunityHorizontal({
    super.key,
    required this.community,
    this.onComebackScreen,
  });
  final AmityCommunity community;
  final VoidCallback? onComebackScreen;
  @override
  Widget build(BuildContext context) {
    return CustomListTitle(
      title: community.displayName ?? "Community",
      url: community.avatarImage?.fileUrl,
      leading: !(community.isPublic ?? true)
          ? const Icon(
              Icons.lock_outlined,
              color: Colors.black,
              size: 12,
            )
          : null,
      trailing: (community.isOfficial ?? false)
          ? SvgPicture.asset(
              AppAssets.verified,
              width: 20,
              height: 20,
              package: AppAssets.package,
            )
          : null,
      subtitle: Text(
        '${community.membersCount} ${((community.membersCount ?? 0) > 1) ? 'members' : 'member'}',
        style: AppTextStyle.body1.copyWith(
          height: 1,
        ),
      ),
      onPressed: () async {
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
        if(onComebackScreen != null){
          onComebackScreen!();
        }
      },
    );
  }
}
