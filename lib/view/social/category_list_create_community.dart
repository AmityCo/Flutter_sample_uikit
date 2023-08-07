import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';

class CategoryListForCreateCommunity extends StatefulWidget {
  final String? selectedCategoryId;

  const CategoryListForCreateCommunity({Key? key, this.selectedCategoryId})
      : super(key: key);

  @override
  State<CategoryListForCreateCommunity> createState() =>
      _CategoryListForCreateCommunityState();
}

class _CategoryListForCreateCommunityState
    extends State<CategoryListForCreateCommunity> {
  final _categories = <AmityCommunityCategory>[];
  final _scrollController = ScrollController();
  bool _isLoading = true;
  String? _pageToken;
  String? _error;

  @override
  void initState() {
    super.initState();
    getCategories(AmityCommunityCategorySortOption.NAME);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void getCategories(
      AmityCommunityCategorySortOption amityCommunityCategorySortOption) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await AmitySocialClient.newCommunityRepository()
          .getCategories()
          .sortBy(amityCommunityCategorySortOption)
          .includeDeleted(false)
          .getPagingData(token: _pageToken, limit: 20);

      setState(() {
        _pageToken = result.token;
        _categories.addAll(result.data);
        _isLoading = false;
      });
    } catch (error) {
      debugPrint("query categories error $error");
      setState(() {
        _isLoading = false;
        _error = 'Error fetching categories. Please try again.';
      });
      log(_error ?? '');
      // Handle error
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        getCategories(AmityCommunityCategorySortOption.NAME);
      }
    }
  }

  void _onCategoryTap(AmityCommunityCategory category) {
    Navigator.pop(context, category);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
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
                  _categories.clear();
                  _pageToken = null;
                  getCategories(AmityCommunityCategorySortOption.NAME);
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final bool isSelected =
                        category.categoryId == widget.selectedCategoryId;
                    final urlAvatar = category.avatar?.getUrl(AmityImageSize.SMALL) ;
                    return GestureDetector(
                      onTap: () => _onCategoryTap(category),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.withOpacity(0.5),
                              foregroundImage: urlAvatar != null ? NetworkImage(
                                urlAvatar,
                              ):null,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      category.name ?? 'displayname not found',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                  ],
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
              if (_isLoading && _categories.isEmpty)
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
