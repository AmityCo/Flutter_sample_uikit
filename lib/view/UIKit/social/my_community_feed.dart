import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_community_page.dart';
import 'package:amity_uikit_beta_service/view/social/community_feed.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCommunityPage extends StatefulWidget {
  const MyCommunityPage({super.key});

  @override
  _MyCommunityPageState createState() => _MyCommunityPageState();
}

class _MyCommunityPageState extends State<MyCommunityPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<MyCommunityVM>(context, listen: false).initMyCommunity();
      Provider.of<UserVM>(context, listen: false).clearselectedCommunityUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyCommunityVM>(builder: (context, vm, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'My Community',
            style: Provider.of<AmityUIConfiguration>(context)
                .titleTextStyle, // Adjust as needed
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.black),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CreateCommunityPage())); // Replace with your CreateCommunityPage
              },
            ),
          ],
        ),
        body: ListView.builder(
          controller: vm.scrollcontroller,
          itemCount: vm.amityCommunities.length + 1,
          itemBuilder: (context, index) {
            // If it's the first item in the list, return the search bar
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: vm.textEditingController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    hintText: 'Search',
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    fillColor: Colors.grey[3],
                    focusColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    Provider.of<MyCommunityVM>(context, listen: false)
                        .initMyCommunity(value);
                  },
                ),
              );
            }
            // Otherwise, return the community widget
            return CommunityWidget(
              community: vm.amityCommunities[index - 1],
            );
          },
        ),
      );
    });
  }
}

class CommunityWidget extends StatelessWidget {
  final AmityCommunity community;

  const CommunityWidget({required this.community});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: (community.avatarFileId != null)
            ? CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(community.avatarImage!.fileUrl!),
              )
            : Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                    color: Color(0xFFD9E5FC), shape: BoxShape.circle),
                child: const Icon(
                  Icons.group,
                  color: Colors.white,
                ),
              ),
        title: Row(
          children: [
            if (!community.isPublic!) const Icon(Icons.lock, size: 16.0),
            const SizedBox(width: 4.0),
            Text(community.displayName ?? "Community"),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CommunityScreen(
                  community:
                      community))); // Replace with your CreateCommunityPage
        },
      ),
    );
  }
}
