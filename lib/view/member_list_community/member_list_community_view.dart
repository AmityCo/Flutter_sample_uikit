import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/components/custom_avatar.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile.dart';
import 'package:flutter/material.dart';

import '../../components/alert_dialog.dart';

class MemberListCommunityView extends StatefulWidget {
  const MemberListCommunityView({super.key, required this.community});

  final AmityCommunity community;

  @override
  State<MemberListCommunityView> createState() =>
      _MemberListCommunityViewState();
}

class _MemberListCommunityViewState extends State<MemberListCommunityView> {
  final _scrollController = ScrollController();
  final _amityCommunityMembers = <AmityCommunityMember>[];
  late PagingController<AmityCommunityMember> _communityMembersController;

  @override
  void didChangeDependencies() {
    searchCommunityMembers(widget.community.communityId ?? '');
    super.didChangeDependencies();
  }

  void searchCommunityMembers(String communityId) {
    _communityMembersController = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommunityRepository()
          .membership(communityId)
          .getMembers()
          .filter(AmityCommunityMembershipFilter.MEMBER)
          .sortBy(AmityCommunityMembershipSortOption.FIRST_CREATED)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          if (_communityMembersController.error == null) {
            //handle results, we suggest to clear the previous items
            //and add with the latest _controller.loadedItems
            _amityCommunityMembers.clear();
            _amityCommunityMembers
                .addAll(_communityMembersController.loadedItems);
            //update widgets
            updateScreen();
          } else {
            //error on pagination controller
            await AmityDialog().showAlertErrorDialog(
                title: "Error!",
                message: _communityMembersController.error.toString());
            //update widgets
          }
        },
      );
    _communityMembersController.fetchNextPage();
  }

  @override
  void initState() {
    _scrollController.addListener(loadnextpage);
    super.initState();
  }

  void loadnextpage() {
    if ((_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) &&
        _communityMembersController.hasMoreItems) {
      _communityMembersController.fetchNextPage();
    }
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
          controller: _scrollController,
          children: List.generate(_amityCommunityMembers.length, (index) {
            final user = _amityCommunityMembers[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  navigatorToUserProfile(user.user!);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      CustomAvatar(
                        url: user.user?.avatarUrl,
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          user.user?.displayName ?? '',
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void updateScreen() {
    if (mounted) {
      setState(() {});
    }
  }
}
