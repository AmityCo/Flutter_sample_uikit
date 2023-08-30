import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/alert_dialog.dart';
import '../../components/search_input.dart';
import '../../components/show_community_horizontal.dart';

class SearchCommunitiesScreen extends StatefulWidget {
  const SearchCommunitiesScreen({Key? key}) : super(key: key);

  @override
  createState() => _SearchCommunitiesScreenState();
}

class _SearchCommunitiesScreenState extends State<SearchCommunitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<AmityCommunity> _communities = [];
  String? _pageToken;
  bool _isLoading = false;
  String? _error;
  final _scrollController = ScrollController();
  String searchKeyword = '';

  final _amityCommunities = <AmityCommunity>[];
  late PagingController<AmityCommunity> _communityController;

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    _scrollController.addListener(loadnextpage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    getAllCommunitiesPublic();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        _searchCommunities(_searchController.text);
      }
    }
  }

  void getAllCommunitiesPublic() {
    _communityController = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommunityRepository()
          .getCommunities()
          .filter(AmityCommunityFilter.ALL)
          .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          if (_communityController.error == null) {
            //handle results, we suggest to clear the previous items
            //and add with the latest _controller.loadedItems
            _amityCommunities.clear();
            final data = filterData(_communityController.loadedItems);
            _amityCommunities.addAll(data);
            //update widgets
            setState(() {});
          } else {
            //error on pagination controller
            await AmityDialog().showAlertErrorDialog(
                title: "Error!",
                message: _communityController.error.toString());
            //update widgets
          }
        },
      );
    _communityController.fetchNextPage();
  }

  void loadnextpage() {
    if ((_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) &&
        _communityController.hasMoreItems) {
      if (searchKeyword.isEmpty) {
        _communityController.fetchNextPage();
      }
    }
  }

  void _searchCommunities(String keyword) async {
    setState(() {
      searchKeyword = keyword;
    });
    if (keyword.isEmpty || keyword == '') {
      setState(() {
        _communities.clear();
      });
      return;
    }
    try {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
        setState(() {
          _isLoading = true;
          _error = null;
        });
        final response = await AmitySocialClient.newCommunityRepository()
            .getCommunities()
            .withKeyword(keyword)
            .getPagingData(token: _pageToken, limit: 20);

        setState(() {
          final data = filterData(response.data);
          _communities = data;
          _pageToken = response.token;
          _isLoading = false;
        });
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Error fetching communities. Please try again.';
      });
      debugPrint(_error);
    }
  }

  List<AmityCommunity> filterData(List<AmityCommunity> items) {
    final fiflter =
        context.read<AmityUIConfiguration>().searchCommunitiesFilter;
    switch (fiflter) {
      case SearchCommunitiesFilter.private:
        return items.where((element) => !(element.isPublic ?? false)).toList();
      case SearchCommunitiesFilter.public:
        return items.where((element) => (element.isPublic ?? false)).toList();
      case SearchCommunitiesFilter.all:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        titleText: 'Search Communities',
        bottom: CustomAppBar(
          context: context,
          centerTitle: false,
          toolbarHeight: 48,
          enableLeading: false,
          title: SearchInput(
            controller: _searchController,
            onChanged: _searchCommunities,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: searchKeyword.isNotEmpty
                  ? _communities.length
                  : _amityCommunities.length,
              itemBuilder: (context, index) {
                final community = searchKeyword.isNotEmpty
                    ? _communities[index]
                    : _amityCommunities[index];

                return ShowCommunityHorizontal(
                  community: community,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
