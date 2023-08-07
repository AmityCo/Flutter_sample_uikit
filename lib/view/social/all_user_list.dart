import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllUserListScreen extends StatefulWidget {
  final List<AmityUser>? selectedUsers;

  const AllUserListScreen({Key? key, this.selectedUsers}) : super(key: key);

  @override
  State<AllUserListScreen> createState() => _AllUserListScreenState();
}

class _AllUserListScreenState extends State<AllUserListScreen> {
  final _amityUsers = <AmityUser>[];
  final _scrollController = ScrollController();
  List<AmityUser> _selectedUsers = [];
  bool _isLoading = true;
  String? _error;
  String? _pageToken;
  bool get _isMultipleSelect => _selectedUsers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedUsers = widget.selectedUsers ?? [];
    getUsers(AmityUserSortOption.DISPLAY);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void getUsers(AmityUserSortOption amityUserSortOption) async {
    if (_pageToken == null) {
      setState(() {
        _amityUsers.clear();
      });
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await AmityCoreClient.newUserRepository()
          .getUsers()
          .sortBy(amityUserSortOption)
          .getPagingData(token: _pageToken, limit: 20);

      setState(() {
        _pageToken = users.token;
        _amityUsers.addAll(users.data);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Error fetching users. Please try again.';
      });
      log(_error ?? '');
      // Handle error
    }
  }

  void _toggleUserSelection(AmityUser? user) {
    if (user?.userId != null) {

      int idx = _selectedUsers.indexWhere(
        (element) => element.userId == user?.userId,
      );

      if (idx != -1) {
         _selectedUsers.removeAt(idx);
        
      } else {
        _selectedUsers.add(user!);
      }
      setState(() {
      });
    }
  }

  void _onDoneButtonPressed() {
    Navigator.pop(context, _selectedUsers);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        getUsers(AmityUserSortOption.DISPLAY);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
        actions: [
          if (_isMultipleSelect)
            TextButton(
              onPressed: _onDoneButtonPressed,
              child: Text(
                'Done',
                style: TextStyle(
                  color: context
                      .watch<AmityUIConfiguration>()
                      .appbarConfig
                      .iconBackColor,
                ),
              ),
            ),
        ],
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
                  _amityUsers.clear();
                  _pageToken = null;
                  getUsers(AmityUserSortOption.DISPLAY);
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _amityUsers.length,
                  itemBuilder: (context, index) {
                    final user = _amityUsers[index];
                    final bool isSelected = _selectedUsers.any(
                        (selectedUser) => selectedUser.userId == user.userId);
                    return GestureDetector(
                      onTap: () => _toggleUserSelection(user),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.withOpacity(0.5),
                              foregroundImage: user.avatarUrl != null
                                    ? NetworkImage(
                                user.avatarUrl!,
                              ):null,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      user.displayName ??
                                          'displayname not found',
                                      style: AppTextStyle.header2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: Theme.of(context).primaryColor,
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
              if (_isLoading && _amityUsers.isEmpty)
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
