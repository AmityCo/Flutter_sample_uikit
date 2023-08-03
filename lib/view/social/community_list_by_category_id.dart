import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/community_feed_viewmodel.dart';
import 'community_feed.dart';

class CommunityListByCategoryIdScreen extends StatefulWidget {
  final String? selectedCategoryId;
  const CommunityListByCategoryIdScreen({Key? key, this.selectedCategoryId}) : super(key: key);

  @override
  State<CommunityListByCategoryIdScreen> createState() => _CommunityListByCategoryIdScreenState();
}

class _CommunityListByCategoryIdScreenState extends State<CommunityListByCategoryIdScreen> {
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
          .categoryId(widget.selectedCategoryId!)
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
      ),
      body: SafeArea(
        child: FadedSlideAnimation(
          beginOffset: const Offset(0, 0.3),
          endOffset: const Offset(0, 0),
          slideCurve: Curves.linearToEaseOut,
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
                    return GestureDetector(
                      onTap: () => _onCommunityTap(community),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                community.avatarImage?.fileUrl ??
                                    'https://images.unsplash.com/photo-1598128558393-70ff21433be0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=978&q=80',
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  community.displayName ??
                                      'displayname not found',
                                  style: theme.textTheme.bodyLarge!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
