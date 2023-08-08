import 'package:flutter/material.dart';

import '../constans/app_assets.dart';
import 'custom_avatar.dart';

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
      leading: CustomAvatar(
        url: url,
        radius: 20,
        imagePlaceholder: const AssetImage(
          AppAssets.accountGroup,
          package: AppAssets.package,
        ),
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
