import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/custom_user_avatar.dart';
import '../../../constans/app_text_style.dart';
import '../../../viewmodel/amity_viewmodel.dart';
import '../../../viewmodel/configuration_viewmodel.dart';

class TextInputComment extends StatelessWidget {
  const TextInputComment(
      {super.key, required this.controller, this.onPressedSend});
  final TextEditingController controller;
  final VoidCallback? onPressedSend;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 0.8,
          spreadRadius: 0.5,
        ),
      ]),
      constraints: const BoxConstraints(minHeight: 60, maxHeight: 120),
      child: ListTile(
        leading: getAvatarImage(
          context.watch<AmityVM>().currentamityUser?.avatarUrl,
        ),
        title: TextFormField(
          cursorColor: context.watch<AmityUIConfiguration>().secondaryColor,
          textCapitalization: TextCapitalization.sentences,
          controller: controller,
          maxLines: null,
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Write your message",
            hintStyle: AppTextStyle.body1.copyWith(fontSize: 14),
          ),
        ),
        trailing: GestureDetector(
          onTap: onPressedSend,
          child: Icon(
            Icons.send,
            color: context.watch<AmityUIConfiguration>().primaryColor,
          ),
        ),
      ),
    );
  }
}
