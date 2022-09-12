import 'package:amity_sdk/amity_sdk.dart';
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

  const UserProfileScreen({Key? key, required this.amityUser})
      : super(key: key);
  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    Provider.of<UserFeedVM>(context, listen: false)
        .initUserFeed(widget.amityUser);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final myAppBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chevron_left),
      ),
      elevation: 0,
    );
    final bheight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppBar.preferredSize.height;
    return Consumer<UserFeedVM>(builder: (context, vm, _) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: myAppBar,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: vm.scrollController,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                height: bheight * 0.4,
                child: LayoutBuilder(
                  builder: (context, constraints) => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    vm.amityMyFollowInfo.followerCount
                                        .toString(),
                                    style: theme.textTheme.headline6),
                                Text(
                                  'Followers',
                                  style: theme.textTheme.subtitle2!.copyWith(
                                    color: theme.hintColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            FadedScaleAnimation(
                                child: getAvatarImage(
                                    Provider.of<AmityVM>(
                                      context,
                                    ).currentamityUser?.avatarUrl,
                                    radius: 50)),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    vm.amityMyFollowInfo.followingCount
                                        .toString(),
                                    style: theme.textTheme.headline6),
                                Text(
                                  "Following",
                                  style: theme.textTheme.subtitle2!.copyWith(
                                    color: theme.hintColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        vm.amityUser!.displayName!,
                        style: theme.textTheme.headline6,
                      ),
                      Text(
                        "",
                        style: theme.textTheme.subtitle2!.copyWith(
                          color: theme.hintColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AmityCoreClient.getCurrentUser().userId !=
                                  widget.amityUser.userId
                              ? GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: constraints.maxWidth * 0.35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Provider.of<
                                                        AmityUIConfiguration>(
                                                    context)
                                                .primaryColor,
                                            style: BorderStyle.solid,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white),
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    child: Text(
                                      "Messages",
                                      style:
                                          theme.textTheme.subtitle2!.copyWith(
                                        color:
                                            Provider.of<AmityUIConfiguration>(
                                                    context)
                                                .primaryColor,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ProfileScreen()));
                                  },
                                  child: Container(
                                    width: constraints.maxWidth * 0.35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Provider.of<
                                                        AmityUIConfiguration>(
                                                    context)
                                                .primaryColor,
                                            style: BorderStyle.solid,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white),
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    child: Text(
                                      "Edit",
                                      style:
                                          theme.textTheme.subtitle2!.copyWith(
                                        color:
                                            Provider.of<AmityUIConfiguration>(
                                                    context)
                                                .primaryColor,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: constraints.maxWidth * 0.35,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Provider.of<AmityUIConfiguration>(
                                            context)
                                        .primaryColor,
                                    style: BorderStyle.solid,
                                    width: 1),
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .primaryColor,
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Text(
                                'Follow Now',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.subtitle2!.copyWith(
                                  color: theme.scaffoldBackgroundColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor:
                            Provider.of<AmityUIConfiguration>(context)
                                .primaryColor,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Posts",
                              style: theme.textTheme.bodyText1,
                            ),
                          ),
                          Text(
                            "Story",
                            style: theme.textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // TabBarView(
              //   controller: _tabController,
              //   children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: vm.amityPosts.length,
                itemBuilder: (context, index) {
                  // var post = vm.amityPosts[index];
                  return StreamBuilder<AmityPost>(
                      stream: vm.amityPosts[index].listen,
                      initialData: vm.amityPosts[index],
                      builder: (context, snapshot) {
                        return PostWidget(
                          post: snapshot.data!,
                          theme: theme,
                          postIndex: index,
                        );
                      });
                },
              )

              //   Container(),
              // ],
              // ),
            ],
          ),
        ),
      );
    });
  }
}
