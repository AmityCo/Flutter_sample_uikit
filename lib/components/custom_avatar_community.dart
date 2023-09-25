import 'package:flutter/material.dart';

import '../constans/app_assets.dart';
import 'custom_avatar.dart';

class CustomAvatarCommunity extends StatelessWidget {
  const CustomAvatarCommunity({
    super.key,
    this.url,
    this.backgroundColor = Colors.grey,
    this.radius = 20,
  });
  final String? url;
  final Color backgroundColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomAvatar(
      url: url,
      backgroundColor: backgroundColor,
      radius: radius,
      imagePlaceholder: const AssetImage(
        AppAssets.accountGroup,
        package: AppAssets.package,
      ),
    );
  }
}
