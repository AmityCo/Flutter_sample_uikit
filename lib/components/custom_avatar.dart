import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';

import '../constans/app_assets.dart';

class CustomAvatar extends StatelessWidget {
  const CustomAvatar({
    super.key,
    this.url,
    this.backgroundColor = Colors.grey,
    this.radius = 15,
    this.imagePlaceholder,
  });
  final String? url;
  final Color backgroundColor;
  final double radius;
  final ImageProvider? imagePlaceholder;
  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      child: url != null
          ? CircleAvatar(
              backgroundColor: backgroundColor.withOpacity(0.5),
              radius: radius,
              foregroundImage: NetworkImage(url!),
            )
          : CircleAvatar(
              backgroundColor: backgroundColor.withOpacity(0.5),
              radius: radius,
              foregroundImage: imagePlaceholder != null
                  ? imagePlaceholder!
                  : const AssetImage(
                      AppAssets.account,
                      package: AppAssets.package,
                    ),
            ),
    );
  }
}