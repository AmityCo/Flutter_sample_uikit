import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_member_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_feed_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberManagementPage extends StatefulWidget {
  final String communityId;

  const MemberManagementPage({Key? key, required this.communityId})
      : super(key: key);

  @override
  State<MemberManagementPage> createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends State<MemberManagementPage> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<MemberManagementVM>(context, listen: false).initMember(
        communityId: widget.communityId,
      );
      Provider.of<MemberManagementVM>(context, listen: false).initModerators(
        communityId: widget.communityId,
      );
      Provider.of<MemberManagementVM>(context, listen: false)
          .checkCurrentUserRole(widget.communityId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: const Text("Community", style: TextStyle(color: Colors.black)),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(
                48.0), // Provide a height for the AppBar's bottom
            child: Row(
              children: [
                TabBar(
                  isScrollable: true, // Ensure that the TabBar is scrollable

                  labelColor: Color(0xFF1054DE), // #1054DE color
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF1054DE),
                  labelStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Text',
                  ),
                  tabs: [
                    Tab(text: "Members"),
                    Tab(text: "Moderators"),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            MemberList(), // You need to create a MemberList widget
            ModeratorList(), // You need to create a ModeratorList widget
          ],
        ),
      ),
    );
  }
}
// Import statements remain the same

class MemberList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MemberManagementVM>(
      builder: (context, viewModel, child) {
        return ListView.builder(
          controller: viewModel.scrollController,
          itemCount: viewModel.userList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                        create: (context) => UserFeedVM(),
                        child: UserProfileScreen(
                          amityUser: viewModel.userList[index].user!,
                        ))));
              },
              leading: CircleAvatar(
                backgroundColor: Color(0xFFD9E5FC),
                backgroundImage: viewModel.userList[index].user?.avatarUrl ==
                        null
                    ? null
                    : NetworkImage(viewModel.userList[index].user!.avatarUrl!),
                child: viewModel.userList[index].user?.avatarUrl != null
                    ? null
                    : const Icon(Icons.person, size: 20, color: Colors.white),
              ),
              title: Text(
                viewModel.userList[index].user?.displayName ?? '',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.black,
                ),
                onPressed: () {
                  _showOptionsBottomSheet(
                      context, viewModel.userList[index], viewModel,
                      showDemoteButton: false);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class ModeratorList extends StatelessWidget {
  const ModeratorList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberManagementVM>(
      builder: (context, viewModel, child) {
        return ListView.builder(
          itemCount: viewModel.moderatorList.length,
          controller: viewModel.scrollControllerForModerator,
          itemBuilder: (context, index) {
            final moderator = viewModel.moderatorList[index];
            return ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                        create: (context) => UserFeedVM(),
                        child: UserProfileScreen(
                          amityUser: moderator.user!,
                        ))));
              },
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFD9E5FC),
                backgroundImage: moderator.user?.avatarUrl == null
                    ? null
                    : NetworkImage(moderator.user!.avatarUrl!),
                child: moderator.user?.avatarUrl != null
                    ? null
                    : const Icon(Icons.person,
                        size: 20,
                        color: Colors
                            .white), // Adjust to use the correct attribute for avatar URL
              ),
              title: Text(
                moderator.user?.displayName ?? '',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                ),
                onPressed: () {
                  _showOptionsBottomSheet(context, moderator, viewModel);
                },
              ),
            );
          },
        );
      },
    );
  }
}

void _showOptionsBottomSheet(BuildContext context, AmityCommunityMember member,
    MemberManagementVM viewModel,
    {bool showDemoteButton = true}) {
  bool isModerator = viewModel.currentUserRoles.contains('community-moderator');

  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Wrap(
            children: isModerator
                ? [
                    showDemoteButton
                        ? ListTile(
                            title: Text(
                              member.roles!.contains('community-moderator')
                                  ? 'Dismiss moderator'
                                  : 'Promote to moderator',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              if (member.roles!
                                  .contains('community-moderator')) {
                                await viewModel.demoteFromModerator(
                                    viewModel.communityId, [member.userId!]);
                              } else {
                                await viewModel.promoteToModerator(
                                    viewModel.communityId, [member.userId!]);
                              }
                              await viewModel.initModerators(
                                  communityId: viewModel.communityId);
                              await viewModel.initMember(
                                communityId: viewModel.communityId,
                              );
                            },
                          )
                        : SizedBox(),
                    ListTile(
                      title: const Text(
                        'Report',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        viewModel.reportUser(member.user!);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text(
                        'Remove from community',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        viewModel.removeMembers(
                            viewModel.communityId, [member.userId!]);
                        Navigator.pop(context);
                      },
                    ),
                  ]
                : [
                    ListTile(
                      title: const Text('Report'),
                      onTap: () {
                        viewModel.reportUser(member.user!);
                        Navigator.pop(context);
                      },
                    ),
                  ],
          ),
        );
      });
}
