import 'package:amity_uikit_beta_service/components/custom_avatar_community.dart';
import 'package:flutter/material.dart';

class CustomListTitle extends StatelessWidget {
  const CustomListTitle({
    super.key,
    required this.title,
    this.url,
    this.iconNoImage,
    this.onPressed,
    this.subtitle,
    this.leading,
    this.trailing,
  });
  final String title;
  final String? url;
  final Icon? iconNoImage;
  final VoidCallback? onPressed;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: CustomAvatarCommunity(url: url),
      title: Row(
        children: [
          if (leading != null) leading!,
          Flexible(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
      subtitle: subtitle,
    );
  }
}
