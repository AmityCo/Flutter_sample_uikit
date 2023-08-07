import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:flutter/material.dart';

import '../view/social/all_user_list.dart';
import 'custom_avatar.dart';
import 'header_filed.dart';

class AddMembers extends StatefulWidget {
  const AddMembers({
    super.key,
    required this.title,
    this.isRequired = false,
    this.initital,
    required this.onChanged,
  });
  final String title;
  final bool isRequired;
  final List<AmityUser>? initital;
  final ValueChanged<List<AmityUser>> onChanged;
  @override
  State<AddMembers> createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  List<AmityUser> select = [];
  final maxLength = 5;

  @override
  void initState() {
    if (widget.initital != null) {
      select = widget.initital!;
    }
    super.initState();
  }

  void openAllUser() {
    navigateToUserList();
  }

  void removeUser(int index) {
    select.removeAt(index);
    onChanged();
  }

  void onChanged() {
    widget.onChanged(select);
    updateScreen();
  }

  void navigateToUserList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllUserListScreen(
          selectedUsers: select,
        ),
      ),
    );
    if (result != null) {
      select = result;
      onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        children: [
          HeaderFiled(
            title: widget.title,
            isRequired: widget.isRequired,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 14,
              children: List.generate(
                  select.length > maxLength ? maxLength + 1 : select.length + 1,
                  (index) {
                Color colorBackground =
                    const Color(0xff636878).withOpacity(0.2);

                if (select.length > maxLength && index == maxLength) {
                  int count = select.length - maxLength;
                  if (count > 1000) {
                    count = 999;
                  }
                  return GestureDetector(
                    onTap: openAllUser,
                    child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: colorBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '+$count',
                              style: AppTextStyle.header1
                                  .copyWith(fontWeight: FontWeight.normal),
                            ),
                          ],
                        )),
                  );
                } else if (index == select.length) {
                  return GestureDetector(
                    onTap: openAllUser,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ),
                      ),
                    ),
                  );
                }

                final user = select[index];
                final imageUrl = user.avatarUrl;
                final displayName = user.displayName ?? '';
                return Container(
                  height: 40,
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 50),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: colorBackground),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomAvatar(
                        radius: 15,
                        url: imageUrl,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          displayName,
                          style: AppTextStyle.header1
                              .copyWith(fontWeight: FontWeight.normal),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => removeUser(index),
                        child: const Center(
                          child: Icon(Icons.close),
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  void updateScreen() {
    if (mounted) {
      setState(() {});
    }
  }
}
