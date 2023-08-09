import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:amity_uikit_beta_service/view/social/user_follow_screen.dart';
import 'package:amity_uikit_beta_service/viewmodel/follower_following_viewmodel.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/amity_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/user_feed_viewmodel.dart';
import '../social/home_following_screen.dart';
import 'edit_profile.dart';

class UserProfileScreen extends StatefulWidget {
  final AmityUser amityUser;
  final bool? isEnableAppbar;
  const UserProfileScreen({
    Key? key,
    required this.amityUser,
    this.isEnableAppbar = true,
  }) : super(key: key);
  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int _selectedIndex = 0;
  List<String> moreActions = ['Logout'];

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
      vsync: this,
    );
    tabController!.addListener(() {
      setState(() {
        _selectedIndex = tabController!.index;
      });
    });
    Provider.of<UserFeedVM>(context, listen: false)
        .initUserFeed(widget.amityUser);
    Provider.of<UserFeedVM>(context, listen: false)
        .initUserGalleryFeed(widget.amityUser);
  }

  AmityUser getAmityUser() {
    if (widget.amityUser.userId == AmityCoreClient.getCurrentUser().userId) {
      return Provider.of<AmityVM>(context).currentamityUser!;
    } else {
      return widget.amityUser;
    }
  }

  Future<void> moreActionPressed(String name) async {
    if (name == moreActions[0]) {
      bool isCurrentUser =
          AmityCoreClient.getCurrentUser().userId == widget.amityUser.userId;
      if (!isCurrentUser) {
        return;
      }
      final amity = context.read<AmityVM>();
      Future.delayed(const Duration(milliseconds: 500), () {
        Future.delayed(const Duration(milliseconds: 500), () {
          amity.logout();
        });
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    bool isCurrentUser =
        AmityCoreClient.getCurrentUser().userId == widget.amityUser.userId;
    final myAppBar = CustomAppBar(
      context: context,
      actions: [
        if (isCurrentUser)
          PopupMenuButton(itemBuilder: (BuildContext context) {
            return List.generate(moreActions.length, (index) {
              return PopupMenuItem(
                onTap: () => moreActionPressed(moreActions[index]),
                child: Text(
                  moreActions[index],
                  style: AppTextStyle.body1,
                ),
              );
            });
          }),
      ],
    );
    final bheight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppBar.preferredSize.height;

    return Consumer<UserFeedVM>(builder: (context, vm, _) {
      final isPrivate =
          vm.amityMyFollowInfo.status != AmityFollowStatus.ACCEPTED &&
              vm.amityUser!.userId != AmityCoreClient.getUserId();
      return RefreshIndicator(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onRefresh: (() async {
          vm.initUserFeed(widget.amityUser);
          vm.initUserGalleryFeed(widget.amityUser);
        }),
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: widget.isEnableAppbar ?? true ? myAppBar : null,
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: vm.scrollcontroller,
            child: Column(
              children: [
                _HeaderUserProfile(
                  amityUser: widget.amityUser,
                  currentUser: getAmityUser(),
                  logout: () => moreActionPressed(moreActions[0]),
                ),
                if (context
                    .read<AmityUIConfiguration>()
                    .userProfileConfig
                    .isOpenTabView)
                  _TabUserProfile(
                    tabController: tabController,
                    height: bheight * 0.3,
                  ),
                if (isPrivate)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: bheight * 0.3,
                              child: const Center(
                                  child: Text("This account is Private")),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                if (!isPrivate)
                  vm.amityPosts.isEmpty
                      ? Container(
                          color: Colors.grey[200],
                          width: 100,
                          height: bheight - 400,
                        )
                      : _selectedIndex == 0
                          ? ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: vm.amityPosts.length,
                              itemBuilder: (context, index) {
                                return StreamBuilder<AmityPost>(
                                    stream: vm.amityPosts[index].listen.stream,
                                    initialData: vm.amityPosts[index],
                                    builder: (context, snapshot) {
                                      return PostWidget(
                                        post: snapshot.data!,
                                        theme: theme,
                                        postIndex: index,
                                        onDeleteAction: (_) {
                                          vm.listenForUserFeed(
                                              widget.amityUser.userId!);
                                        },
                                      );
                                    });
                              },
                            )
                          : vm.amityMediaPosts.isEmpty
                              ? Container(
                                  color: Colors.grey[200],
                                  width: 100,
                                  height: bheight - 400,
                                )
                              : GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                  ),
                                  itemCount: vm.amityMediaPosts
                                      .length, // Replace with your gallery items
                                  itemBuilder: (context, index) {
                                    log('checking media post list ${vm.amityMediaPosts.length}');
                                    return StreamBuilder<AmityPost>(
                                        stream: vm.amityMediaPosts[index].listen
                                            .stream,
                                        initialData: vm.amityMediaPosts[index],
                                        builder: (context, snapshot) {
                                          return GestureDetector(
                                            onTap: () {
                                              // Handle gallery item tap here
                                            },
                                            child: Image.network(
                                              'https://images.unsplash.com/photo-1598128558393-70ff21433be0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=978&q=80', //snapshot.data!.data!.fileInfo.fileUrl, // Replace with the URL of your gallery item
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        });
                                  },
                                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _HeaderUserProfile extends StatelessWidget {
  const _HeaderUserProfile({
    required this.amityUser,
    required this.currentUser,
    this.logout,
  });
  final AmityUser amityUser;
  final AmityUser currentUser;
  final VoidCallback? logout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isCurrentUser =
        AmityCoreClient.getCurrentUser().userId == amityUser.userId;
    return Consumer<UserFeedVM>(builder: (_, vm, __) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(bottom: 10, top: 15),
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ShowMemberText(
                      members: vm.amityMyFollowInfo.followerCount ?? 0,
                      title: 'Followers',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (context) => FollowerVM(),
                              child: FollowScreen(
                                key: UniqueKey(),
                                user: amityUser,
                                initialIndex: 0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: logout,
                      child: FadedScaleAnimation(
                        child: getAvatarImage(
                            isCurrentUser
                                ? Provider.of<AmityVM>(
                                    context,
                                  ).currentamityUser?.avatarUrl
                                : amityUser.avatarUrl,
                            radius: 50),
                      ),
                    ),
                    _ShowMemberText(
                      members: vm.amityMyFollowInfo.followingCount ?? 0,
                      title: 'Following',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (context) => FollowerVM(),
                              child: FollowScreen(
                                key: UniqueKey(),
                                user: amityUser,
                                initialIndex: 1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 10),
                child: Text(
                  currentUser.displayName ?? "",
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Text(
                  currentUser.description ?? "",
                  style: theme.textTheme.titleSmall!.copyWith(
                    color: theme.hintColor,
                    fontSize: 12,
                  ),
                ),
              ),
              isCurrentUser
                  ? context
                          .read<AmityUIConfiguration>()
                          .userProfileConfig
                          .isOpenEditProfile
                      ? Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                        user: vm.amityUser!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      style: BorderStyle.solid,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: context
                                            .watch<AmityUIConfiguration>()
                                            .buttonConfig
                                            .backgroundColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Edit Profile",
                                        style: AppTextStyle.body1.copyWith(
                                          color: context
                                              .watch<AmityUIConfiguration>()
                                              .buttonConfig
                                              .textColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: vm.amityMyFollowInfo.id == null
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Provider.of<AmityUIConfiguration>(
                                                      context)
                                                  .primaryColor,
                                          style: BorderStyle.solid,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    child: Text(
                                      "",
                                      textAlign: TextAlign.center,
                                      style:
                                          theme.textTheme.titleSmall!.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : FadeAnimation(
                                    child: StreamBuilder<AmityUserFollowInfo>(
                                        stream:
                                            vm.amityMyFollowInfo.listen.stream,
                                        initialData: vm.amityMyFollowInfo,
                                        builder: (context, snapshot) {
                                          return GestureDetector(
                                            onTap: () {
                                              vm.followButtonAction(amityUser,
                                                  snapshot.data!.status);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          getFollowingStatusTextColor(
                                                              context,
                                                              snapshot.data!
                                                                  .status),
                                                      style: BorderStyle.solid,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color:
                                                      getFollowingStatusColor(
                                                          context,
                                                          snapshot
                                                              .data!.status)),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 10, 10, 10),
                                              child: Text(
                                                getFollowingStatusString(
                                                    snapshot.data!.status),
                                                textAlign: TextAlign.center,
                                                style: theme
                                                    .textTheme.titleSmall!
                                                    .copyWith(
                                                  color:
                                                      getFollowingStatusTextColor(
                                                          context,
                                                          snapshot
                                                              .data!.status),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      );
    });
  }

  String getFollowingStatusString(AmityFollowStatus amityFollowStatus) {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      return "Follow";
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      return "Pending";
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      return "Following";
    } else {
      return "Miss Type";
    }
  }

  Color getFollowingStatusColor(
      BuildContext context, AmityFollowStatus amityFollowStatus) {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      return Provider.of<AmityUIConfiguration>(context).primaryColor;
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      return Colors.grey;
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  Color getFollowingStatusTextColor(
      BuildContext context, AmityFollowStatus amityFollowStatus) {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      return Colors.white;
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      return Colors.white;
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      return Provider.of<AmityUIConfiguration>(context).primaryColor;
    } else {
      return Colors.red;
    }
  }
}

class _TabUserProfile extends StatelessWidget {
  const _TabUserProfile({
    this.tabController,
    required this.height,
  });
  final TabController? tabController;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        indicatorColor: Provider.of<AmityUIConfiguration>(context).primaryColor,
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        labelColor: context.watch<AmityUIConfiguration>().primaryColor,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: "Feed"),
          Tab(text: "Gallery"),
        ],
      ),
    );
  }
}

class _ShowMemberText extends StatelessWidget {
  const _ShowMemberText({
    required this.members,
    required this.title,
    this.onTap,
  });
  final int members;
  final String title;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            members.toString(),
            style: AppTextStyle.display1,
          ),
          Text(
            title,
            style: AppTextStyle.body1.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
