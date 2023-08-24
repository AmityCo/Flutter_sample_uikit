import 'package:flutter/material.dart';

import '../constans/app_text_style.dart';
import 'custom_avatar.dart';

class CustomAvatarLabelName extends StatelessWidget {
  const CustomAvatarLabelName({
    super.key,
    this.url,
    this.name,
    this.onTap,
  });
  final String? url;
  final String? name;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomAvatar(
                radius: 20,
                url: url,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? '',
                      style: AppTextStyle.header2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
