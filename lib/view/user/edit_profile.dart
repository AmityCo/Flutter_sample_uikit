import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/amity_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/custom_image_picker.dart';
import '../../viewmodel/user_feed_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _displayNameController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();
  @override
  void initState() {
    Provider.of<ImagePickerVM>(context, listen: false).init();
    Provider.of<UserFeedVM>(context, listen: false)
        .getUser(AmityCoreClient.getCurrentUser());

    _displayNameController.text =
        AmityCoreClient.getCurrentUser().displayName ?? "";
    _descriptionController.text =
        AmityCoreClient.getCurrentUser().description ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final myAppBar = AppBar(
      title: Text(
        "My Profile",
        style: theme.textTheme.headline6,
      ),
      backgroundColor: Colors.white,
      leading: IconButton(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chevron_left),
      ),
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () async {
            //edit profile
            if (Provider.of<ImagePickerVM>(context, listen: false).amityImage !=
                null) {
              await Provider.of<UserFeedVM>(context, listen: false)
                  .editCurrentUserInfo(
                      displayName: _displayNameController.text,
                      description: _descriptionController.text,
                      avatarFileID:
                          Provider.of<ImagePickerVM>(context, listen: false)
                              .amityImage!
                              .fileId);

              // ignore: use_build_context_synchronously
              Provider.of<AmityVM>(context, listen: false)
                  .refreshCurrentUserData();
            } else {
              await Provider.of<UserFeedVM>(context, listen: false)
                  .editCurrentUserInfo(
                displayName: _displayNameController.text,
                description: _descriptionController.text,
              );
            }
          },
          child: Text(
            "Edit",
            style: theme.textTheme.button!.copyWith(
                color: Provider.of<AmityUIConfiguration>(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
    final bheight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppBar.preferredSize.height;
    return Consumer<UserFeedVM>(builder: (context, vm, _) {
      return Scaffold(
        appBar: myAppBar,
        body: FadedSlideAnimation(
          beginOffset: const Offset(0, 0.3),
          endOffset: const Offset(0, 0),
          slideCurve: Curves.linearToEaseOut,
          child: Container(
            color: Colors.white,
            height: bheight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        FadedScaleAnimation(
                          child: GestureDetector(
                            onTap: () {
                              Provider.of<ImagePickerVM>(context, listen: false)
                                  .showBottomSheet(context);
                            },
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: Provider.of<ImagePickerVM>(
                                              context,
                                              listen: true)
                                          .amityImage !=
                                      null
                                  ? NetworkImage(Provider.of<ImagePickerVM>(
                                          context,
                                          listen: false)
                                      .amityImage!
                                      .fileUrl)
                                  : getImageProvider(
                                      Provider.of<AmityVM>(
                                        context,
                                      ).currentamityUser?.avatarUrl,
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 7,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .primaryColor,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                        alignment: Alignment.centerLeft,
                        color: Colors.grey[200],
                        width: double.infinity,
                        child: Text(
                          "Profile Info",
                          style: theme.textTheme.headline6!.copyWith(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: TextField(
                          enabled: false,
                          controller:
                              TextEditingController(text: vm.amityUser!.userId),
                          decoration: const InputDecoration(
                            labelText: "User Id",
                            labelStyle: TextStyle(height: 1),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey[200],
                        thickness: 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: TextField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: "Display Name",
                            alignLabelWithHint: false,
                            border: InputBorder.none,
                            labelStyle: TextStyle(height: 1),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey[200],
                        thickness: 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: "Description",
                            alignLabelWithHint: false,
                            border: InputBorder.none,
                            labelStyle: TextStyle(height: 1),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey[200],
                        thickness: 3,
                      ),

                      // Container(
                      //   color: Colors.white,
                      //   width: double.infinity,
                      //   padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      //   child: TextField(
                      //     controller:
                      //         TextEditingController(text: '+1 9876543210'),
                      //     decoration: InputDecoration(
                      //       labelText: S.of(context).phoneNumber,
                      //       labelStyle: TextStyle(height: 1),
                      //       border: InputBorder.none,
                      //     ),
                      //   ),
                      // ),
                      // Divider(
                      //   color: ApplicationColors.lightGrey,
                      //   thickness: 3,
                      // ),
                      // Container(
                      //   color: Colors.white,
                      //   width: double.infinity,
                      //   padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      //   child: TextField(
                      //     controller: TextEditingController(
                      //         text: S.of(context).samanthasmithmailcom),
                      //     decoration: InputDecoration(
                      //       labelText: S.of(context).emailAddress,
                      //       labelStyle: TextStyle(height: 1),
                      //       border: InputBorder.none,
                      //     ),
                      //   ),
                      // ),
                      // Divider(
                      //   color: ApplicationColors.lightGrey,
                      //   thickness: 3,
                      // ),
                      // Container(
                      //   color: Colors.white,
                      //   width: double.infinity,
                      //   padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      //   child: TextField(
                      //     controller:
                      //         TextEditingController(text: S.of(context).female),
                      //     decoration: InputDecoration(
                      //       labelText: S.of(context).gender,
                      //       labelStyle: TextStyle(height: 1),
                      //       border: InputBorder.none,
                      //     ),
                      //   ),
                      // ),
                      // Divider(
                      //   color: ApplicationColors.lightGrey,
                      //   thickness: 3,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
