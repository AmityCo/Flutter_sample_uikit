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
  });
  final String title;
  final String? url;
  final Icon? iconNoImage;
  final VoidCallback? onPressed;
  final Widget? subtitle;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: CustomAvatarCommunity(
        url: url
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle,
    );
  }
}
