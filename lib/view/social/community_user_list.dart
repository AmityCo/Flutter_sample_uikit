import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';

class CommunityUserListScreen extends StatefulWidget {
  final String? communityId;

  const CommunityUserListScreen({Key? key, this.communityId}) : super(key: key);

  @override
  State<CommunityUserListScreen> createState() => _CommunityUserListScreenState();
}

class _CommunityUserListScreenState extends State<CommunityUserListScreen> {
  final _communityMembers = <AmityCommunityMember>[];
  final _scrollController = ScrollController();
  bool _isLoading = true;
  String? _error;
  String? _pageToken;

  @override
  void initState() {
    super.initState();
    getCommunityMembers();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void getCommunityMembers() async {
    if (_pageToken == null) {
      setState(() {
        _communityMembers.clear();
      });
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await AmitySocialClient.newCommunityRepository()
          .membership(widget.communityId!)
          .getMembers()
          .sortBy(AmityCommunityMembershipSortOption.LAST_CREATED)
          .getPagingData(token: _pageToken, limit: 20);

      setState(() {
        _pageToken = users.token;
        _communityMembers.addAll(users.data);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Error fetching users. Please try again.';
      });
      // Handle error
    }
  }

  void _communityMemberTap(AmityCommunityMember? member) {
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        getCommunityMembers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Members'),
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
                  _communityMembers.clear();
                  _pageToken = null;
                  getCommunityMembers();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _communityMembers.length,
                  itemBuilder: (context, index) {
                    final member = _communityMembers[index];
                    return GestureDetector(
                      onTap: () => _communityMemberTap(member),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                member.user?.avatarUrl != null
                                    ? member.user!.avatarUrl!
                                    : 'https://images.unsplash.com/photo-1598128558393-70ff21433be0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=978&q=80',
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    member.user?.displayName ?? 'displayname not found',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isLoading && _communityMembers.isEmpty)
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
