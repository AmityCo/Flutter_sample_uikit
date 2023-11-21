import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/components/custom_avatar.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/alert_dialog.dart';
import '../../viewmodel/configuration_viewmodel.dart';

class MemberListCommunityView extends StatefulWidget {
  const MemberListCommunityView({super.key, required this.community});

  final AmityCommunity community;

  @override
  State<MemberListCommunityView> createState() =>
      _MemberListCommunityViewState();
}

class _MemberListCommunityViewState extends State<MemberListCommunityView> {
  bool _isLoading = true;
  final _scrollController = ScrollController();
  final _amityCommunityMembers = <AmityCommunityMember>[];
  late PagingController<AmityCommunityMember> _communityMembersController;

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
            setState(() {
              _isLoading = false;
            });
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
    searchCommunityMembers(widget.community.communityId ?? '');
    _scrollController.addListener(loadnextpage);
    super.initState();
  }

  void loadnextpage() {
    if ((_scrollController.position.maxScrollExtent -
                _scrollController.position.pixels) <
            100 &&
        _communityMembersController.hasMoreItems) {
      setState(() {
        _isLoading = true;
      });
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
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: renderListView(),
          ),
          _isLoading && _amityCommunityMembers.isNotEmpty
              ? Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 40.0,
                      width: 40.0,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Provider.of<AmityUIConfiguration>(context)
                              .primaryColor,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget renderListView() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: ListView(
        shrinkWrap: true,
        controller: _scrollController,
        children: List.generate(_amityCommunityMembers.length, (index) {
          final user = _amityCommunityMembers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
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
      setState(() {
        _isLoading = false;
      });
    }
  }
}
