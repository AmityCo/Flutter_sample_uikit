import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:animation_wrappers/animations/faded_scale_animation.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../components/alert_dialog.dart';
import '../../constans/app_text_style.dart';
import 'all_user_list.dart';
import 'category_list_create_community.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({Key? key}) : super(key: key);

  @override
  CreateCommunityScreenState createState() => CreateCommunityScreenState();
}

class CreateCommunityScreenState extends State<CreateCommunityScreen> {
  double radius = 60;
  OverlayEntry? overlayEntry;
  final _displayNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool isCommunityPublic = true;
  List<String> categoryIds = [];
  List<AmityUser> selectedUsers = [];
  AmityCommunityCategory? selectedCategory;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
  }

  void updateAvatarImage(File uploadingImage) {
    setState(() {
      selectedImage = uploadingImage;
    });
  }

  void createAvatar(File uploadingImage) {
    // Upload image
    AmityCoreClient.newFileRepository()
        .uploadImage(uploadingImage)
        .stream
        .listen((amityUploadResult) {
      amityUploadResult.when(
        progress: (uploadInfo, cancelToken) {},
        complete: (file) {
          // Check if the upload result is complete
          // Then create an image post
          debugPrint("upload image complete");
          createCommunity(avatarImage: (file as AmityImage));
        },
        error: (error) {
              debugPrint(error.toString());
        },
        cancel: () {},
      );
    });
  }

  void createCommunityClicked() {
    if (selectedCategory != null &&
        _descriptionController.text.isNotEmpty &&
        _displayNameController.text.isNotEmpty) {
      if (selectedImage != null) {
        showLoadingOverlay();
        createAvatar(selectedImage!);
      } else {
        showLoadingOverlay();
        createCommunity();
      }
    } else {
      // showLoadingOverlay();
      AmityDialog().showAlertErrorDialog(
          title: "Error!", message: "Please fill in all required fields");
    }
  }

  void createCommunity({AmityImage? avatarImage}) {
    List<String> userIds = selectedUsers.map((e) => e.userId!).toList();
    if (selectedCategory != null &&
        _descriptionController.text.isNotEmpty &&
        _displayNameController.text.isNotEmpty) {
      if (avatarImage != null) {
        AmitySocialClient.newCommunityRepository()
            .createCommunity(_displayNameController.text)
            .description(_descriptionController.text)
            .avatar(avatarImage)
            .categoryIds([selectedCategory!.categoryId!])
            .isPublic(isCommunityPublic)
            .userIds(userIds)
            .create()
            .then((AmityCommunity community) {
              debugPrint("Successfully create community $community");
              hideLoadingOverlay();
              AmityDialog().showAlertErrorDialog(
                  title: "Success!",
                  message: "Successfully created community!");
            })
            .onError((error, stackTrace) {
              debugPrint("Error creating a community $error");
              hideLoadingOverlay();
              AmityDialog().showAlertErrorDialog(
                  title: "Error!",
                  message: "Unable to create community, please try again.");
            });
      } else {
        AmitySocialClient.newCommunityRepository()
            .createCommunity(_displayNameController.text)
            .description(_descriptionController.text)
            .categoryIds([selectedCategory!.categoryId!])
            .isPublic(isCommunityPublic)
            .userIds(userIds)
            .create()
            .then((AmityCommunity community) {
              debugPrint("Successfully create community $community");
              hideLoadingOverlay();
              AmityDialog().showAlertErrorDialog(
                  title: "Success!",
                  message: "Successfully created community!");
            })
            .onError((error, stackTrace) {
              debugPrint("Error creating a community $error");
              hideLoadingOverlay();
              AmityDialog().showAlertErrorDialog(
                  title: "Error!",
                  message: "Unable to create community, please try again.");
            });
      }
    }
  }

  void navigateToUserList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllUserListScreen(
          selectedUsers: selectedUsers,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        selectedUsers = result;
      });
    }
  }

  void navigateToCategoryList() async {
    debugPrint("Clicking navigate to category");
    final result = await Navigator.push<AmityCommunityCategory?>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryListForCreateCommunity(
          selectedCategoryId: selectedCategory?.categoryId,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        selectedCategory = result;
      });
    }
  }

  void _showImagePicker() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      File? imageFile = File(pickedImage.path);
      updateAvatarImage(imageFile);
    }
  }

  String _buildSelectedUserNames(List<AmityUser> users) {
    final List<String> userNames = [];
    if (users.isEmpty) {
      return "Select user";
    }
    for (final user in selectedUsers) {
      userNames.add(user.displayName ?? '');
    }
    final String truncatedNames = userNames.join(', ');
    const int maxNameLength = 30;
    if (truncatedNames.length > maxNameLength) {
      return '${truncatedNames.substring(0, maxNameLength)}...';
    }
    return truncatedNames;
  }

  void showLoadingOverlay() {
    OverlayEntry entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    overlayEntry = entry;
    Overlay.of(context).insert(overlayEntry!);
  }

  void hideLoadingOverlay() {
    if(overlayEntry != null){
      overlayEntry!.remove();
      overlayEntry = null;
    }
   
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final myAppBar = AppBar(
      title: Text(
        "Create Community",
        style: theme.textTheme.titleLarge?.copyWith(
          color: context.watch<AmityUIConfiguration>().appbarConfig.textColor,
        ),
      ),
      backgroundColor: context.watch<AmityUIConfiguration>().appbarConfig.backgroundColor,
      leading: IconButton(
        color: theme.indicatorColor,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.chevron_left, color: context.watch<AmityUIConfiguration>().appbarConfig.iconBackColor,),
      ),
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () async {
            createCommunityClicked();
          },
          child: Text(
            "Save",
            style: theme.textTheme.bodyMedium!.copyWith(
              color: context.watch<AmityUIConfiguration>().appbarConfig.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
    final bheight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppBar.preferredSize.height;
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
                            _showImagePicker();
                          },
                          child: CircleAvatar(
                            radius: radius,
                            backgroundImage: selectedImage != null
                                ? FileImage(selectedImage!)
                                    as ImageProvider<Object>?
                                : const NetworkImage(
                                    'https://images.unsplash.com/photo-1598128558393-70ff21433be0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=978&q=80',
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 7,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
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
                        "Community Info",
                        style: theme.textTheme.headlineMedium!.copyWith(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: TextField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          labelText: "Display Name",
                          alignLabelWithHint: false,
                          border: InputBorder.none,
                          labelStyle: AppTextStyle.body1.copyWith(height: 1),
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.grey[200],
                      thickness: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: "Description",
                          alignLabelWithHint: false,
                          border: InputBorder.none,
                          labelStyle: AppTextStyle.body1.copyWith(height: 1),
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.grey[200],
                      thickness: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Community Type",
                            style: theme.textTheme.headlineSmall!.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            children: [
                              Radio(
                                value: true,
                                groupValue: isCommunityPublic,
                                onChanged: (value) {
                                  setState(() {
                                    isCommunityPublic = value as bool;
                                  });
                                },
                              ),
                              const Text("Public"),
                              const SizedBox(width: 16),
                              Radio(
                                value: false,
                                groupValue: isCommunityPublic,
                                onChanged: (value) {
                                  setState(() {
                                    isCommunityPublic = value as bool;
                                  });
                                },
                              ),
                              const Text("Private"),
                            ],
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: navigateToCategoryList,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Category List",
                                      style:
                                          theme.textTheme.headlineSmall!.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      selectedCategory != null
                                          ? "${selectedCategory!.name}"
                                          : "Select Category",
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            // Column(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Row(
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         Text(
                            //           "Category",
                            //           style:
                            //               theme.textTheme.subtitle1!.copyWith(
                            //             color: Colors.grey,
                            //           ),
                            //         ),
                            //         Icon(
                            //           Icons.arrow_forward_ios,
                            //           size: 18,
                            //           color: Colors.grey,
                            //         ),
                            //       ],
                            //     ),
                            //     const SizedBox(height: 8),
                            // Text(
                            //   selectedCategory != null
                            //       ? "${selectedCategory!.name}"
                            //       : "Select Category",
                            //   style: theme.textTheme.bodyText2,
                            // ),
                            //   ],
                            // ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: navigateToUserList,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "User List",
                                      style:
                                          theme.textTheme.headlineSmall!.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _buildSelectedUserNames(selectedUsers),
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
