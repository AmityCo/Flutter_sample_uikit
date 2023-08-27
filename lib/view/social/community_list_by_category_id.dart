import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/components/custom_faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../components/custom_list_tile.dart';
import '../../constans/app_assets.dart';
import '../../viewmodel/community_feed_viewmodel.dart';
import 'community_feed.dart';

class CommunityListByCategoryIdScreen extends StatefulWidget {
  final AmityCommunityCategory category;
  const CommunityListByCategoryIdScreen({Key? key, required this.category})
      : super(key: key);

  @override
  State<CommunityListByCategoryIdScreen> createState() =>
      _CommunityListByCategoryIdScreenState();
}

class _CommunityListByCategoryIdScreenState
    extends State<CommunityListByCategoryIdScreen> {
  final _communities = <AmityCommunity>[];
  final _scrollController = ScrollController();
  bool _isLoading = true;
  String? _pageToken;
  String? _error;

  @override
  void initState() {
    super.initState();
    getCommunities();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void getCommunities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await AmitySocialClient.newCommunityRepository()
          .getCommunities()
          .categoryId(widget.category.categoryId!)
          .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
          .includeDeleted(false)
          .getPagingData(token: _pageToken, limit: 20);

      setState(() {
        _pageToken = result.token;
        _communities.addAll(result.data);
        _isLoading = false;
      });
    } catch (error) {
      debugPrint("query communities error $error");
      setState(() {
        _isLoading = false;
        _error = 'Error fetching communities. Please try again.';
      });
      debugPrint("query communities error $_error");
      // Handle error
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        getCommunities();
      }
    }
  }

  void _onCommunityTap(AmityCommunity community) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
              create: (context) => CommuFeedVM(),
              child: Builder(builder: (context) {
                return CommunityScreen(
                  community: community,
                );
              }),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        titleText: widget.category.name ?? '',
      ),
      body: SafeArea(
        child: CustomFadedSlideAnimation(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  _communities.clear();
                  _pageToken = null;
                  getCommunities();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _communities.length,
                  itemBuilder: (context, index) {
                    final community = _communities[index];
                    return CustomListTitle(
                      url: community.avatarImage?.fileUrl,
                      title: community.displayName ?? 'displayname not found',
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
                      onPressed: (){
                        _onCommunityTap(community);
                      },
                    );
                  },
                ),
              ),
              if (_isLoading && _communities.isEmpty)
                const Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
