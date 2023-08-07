import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/add_members.dart';
import '../../components/alert_dialog.dart';
import '../../components/custom_selecter_box.dart';
import '../../components/cutom_text_filed.dart';
import '../../components/loading_dialog.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../social/category_list_create_community.dart';
import 'widgets/button_create_community.dart';
import 'widgets/image_create_community.dart';
import 'widgets/radio_create_community.dart';

class CreateCommunityView extends StatefulWidget {
  const CreateCommunityView({super.key, this.community});

  final AmityCommunity? community;
  @override
  State<CreateCommunityView> createState() => _CreateCommunityViewState();
}

class _CreateCommunityViewState extends State<CreateCommunityView> {
  CommunityType communityType = CommunityType.public;
  ImageProvider? imageFile;
  File? selectImage;

  String communityName = '';
  String about = '';
  List<AmityUser> selectedUsers = [];
  bool isLoadMembers = false;
  AmityCommunityCategory? selectedCategory;

  final loadingDialog = LoadingDialog();

  @override
  void initState() {
    if (widget.community != null) {
      // Set name group
      communityName = widget.community!.displayName ?? '';

      // Set description group
      about = widget.community!.description ?? '';

      // Set category group
      selectedCategory = widget.community!.categories != null
          ? widget.community!.categories![0]
          : null;

      // Set type group
      communityType = widget.community!.isPublic!
          ? CommunityType.public
          : CommunityType.private;

      // Set image
      final imageUrl = widget.community!.avatarImage?.fileUrl;
      if (imageUrl != null) {
        imageFile = NetworkImage('$imageUrl?size=medium');
      }

      updateMembers(widget.community!.communityId!);
    }
    super.initState();
  }

  @override
  void dispose() {
    loadingDialog.close();
    super.dispose();
  }

  Future<void> updateMembers(String communityId) async {
    isLoadMembers = true;
    final communityMember = await AmitySocialClient.newCommunityRepository()
        .membership(communityId)
        .getMembers()
        .query();
    selectedUsers = [];
    for (final member in communityMember) {
      if (member.user != null) {
        selectedUsers.add(member.user!);
      }
    }
    isLoadMembers = false;
    updateScreen();
  }

  void onChangedRadio(CommunityType? type) {
    if (type == null) {
      return;
    }
    setState(() {
      communityType = type;
    });
  }

  void _showImagePicker() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      File file = File(pickedImage.path);
      imageFile = FileImage(file);
      selectImage = file;
      updateScreen();
    }
  }

  void onPreesedButton(File? imageFile) {
    loadingDialog.open(context);
    if (imageFile == null) {
      if (widget.community == null) {
        createCommunity();
      } else {
        updateCommunity();
      }
      return;
    }

    // Upload image
    AmityCoreClient.newFileRepository()
        .uploadImage(imageFile)
        .stream
        .listen((amityUploadResult) {
      amityUploadResult.when(
        progress: (uploadInfo, cancelToken) {},
        complete: (file) {
          // Check if the upload result is complete
          // Then create an image post
          debugPrint("upload image complete");

          if (widget.community == null) {
            createCommunity(image: file as AmityImage);
          } else {
            updateCommunity(image: file as AmityImage);
          }
        },
        error: (error) {
          debugPrint(error.toString());
        },
        cancel: () {},
      );
    });
  }

  Future<void> createCommunity({AmityImage? image}) async {
    final create = AmitySocialClient.newCommunityRepository()
        .createCommunity(communityName);

    if (image != null) {
      create.avatar(image);
    }
    List<String> userIds = [];
    for (final s in selectedUsers) {
      if (s.userId != null) {
        userIds.add(s.userId!);
      }
    }
    create
        .description(about)
        .isPublic(communityType == CommunityType.public)
        .categoryIds([selectedCategory!.categoryId!])
        .userIds(userIds)
        .create()
        .then((AmityCommunity community) async {
          debugPrint("Successfully create community $community");

          _close(title: "Success!", message: "Successfully created community!");
        })
        .onError((error, stackTrace) async {
          debugPrint("Error creating a community $error");

          _close(
            title: "Error!",
            message: "Unable to create community, please try again.",
          );
        });
  }

  Future<void> updateCommunity({AmityImage? image}) async {
    final update = AmitySocialClient.newCommunityRepository()
        .updateCommunity(widget.community!.communityId!);

    if (image != null) {
      update.avatar(image);
    }
    List<String> userIds = [];
    for (final s in selectedUsers) {
      if (s.userId != null) {
        userIds.add(s.userId!);
      }
    }
    update
        .description(about)
        .isPublic(communityType == CommunityType.public)
        .categoryIds([selectedCategory!.categoryId!])
        .userIds(userIds)
        .update()
        .then((AmityCommunity community) async {
          debugPrint("Successfully updated community $community");
          _close(
            title: "Success!",
            message: "Successfully updated community!",
          );
        })
        .onError((error, stackTrace) async {
          debugPrint("Error updated a community $error");
          loadingDialog.close();
          _close(
            title: "Error!",
            message: "Unable to updated community, please try again.",
          );
        });
  }

  Future<void> _close({required String title, required String message}) async {
    loadingDialog.close();

    await Future.delayed(Duration.zero);

    await AmityDialog().showAlertErrorDialog(title: title, message: message);

    await Future.delayed(Duration.zero);

    if (mounted) {
      Navigator.pop(context, title.contains('Error'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        titleText:
            widget.community != null ? 'Edit Community' : 'Create Community',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageCreateCommunity(
              image: imageFile,
              onPressed: _showImagePicker,
            ),
            const SizedBox(height: 20),
            CutomTextFiled(
              title: 'Community name',
              hintText: 'Name your community',
              initialValue: communityName,
              isRequired: true,
              maxlength: 30,
              onChanged: (v) {
                communityName = v;
                updateScreen();
              },
            ),
            CutomTextFiled(
              title: 'About',
              hintText: 'Enter description',
              initialValue: about,
              maxlength: 180,
              maxLines: 4,
              onChanged: (v) {
                about = v;
                updateScreen();
              },
            ),
            CustomSelecterBox(
              title: 'Category',
              hintText: 'Select category',
              value: selectedCategory?.name,
              isRequired: true,
              onPressed: navigateToCategoryList,
            ),
            RadioCreateCommunity(
              current: communityType,
              onChanged: onChangedRadio,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            if (!isLoadMembers)
              AddMembers(
                title: 'Add members',
                isRequired: true,
                initital: selectedUsers,
                onChanged: (v) {
                  selectedUsers = v;
                  updateScreen();
                },
              ),
            const Divider(),
            const SizedBox(height: 10),
            ButtonCreateCommunity(
              title: widget.community != null
                  ? 'Edit community'
                  : 'Create community',
              iconData: widget.community != null ? Icons.edit : Icons.add,
              onPressed: isRequiredPass()
                  ? () {
                      onPreesedButton(selectImage);
                    }
                  : null,
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  bool isRequiredPass() {
    if (selectedCategory != null &&
        communityName.isNotEmpty &&
        selectedUsers.isNotEmpty) {
      return true;
    }
    return false;
  }

  void updateScreen() {
    if (mounted) {
      setState(() {});
    }
  }
}
