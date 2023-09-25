import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/components/custom_avatar.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile.dart';
import 'package:flutter/material.dart';

class MemberListCommunityView extends StatefulWidget {
  const MemberListCommunityView({super.key, required this.community});
  final AmityCommunity community;
  @override
  State<MemberListCommunityView> createState() =>
      _MemberListCommunityViewState();
}

class _MemberListCommunityViewState extends State<MemberListCommunityView> {
  bool isLoadMembers = false;
  List<AmityUser> users = [];

  Future<void> updateMembers(String communityId) async {
    isLoadMembers = true;
    final communityMember = await AmitySocialClient.newCommunityRepository()
        .membership(communityId)
        .getMembers()
        .query();
    users = [];
    for (final member in communityMember) {
      if (member.user != null) {
        users.add(member.user!);
      }
    }
    isLoadMembers = false;
    updateScreen();
  }

  void navigatorToUserProfile(AmityUser user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          amityUser: user,
        ),
      ),
    );
  }

  @override
  void initState() {
    updateMembers(widget.community.communityId ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        titleText: 'Members',
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: ListView(
          children: List.generate(users.length, (index) {
            final user = users[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  navigatorToUserProfile(user);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      CustomAvatar(
                        url: user.avatarUrl,
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          user.displayName ?? '',
                          style: AppTextStyle.header1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void updateScreen() {
    if (mounted) {
      setState(() {});
    }
  }
}
