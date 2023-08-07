import 'package:flutter/material.dart';

import '../constans/app_assets.dart';

class CustomAvatar extends StatelessWidget {
  const CustomAvatar({
    super.key,
    this.url,
    this.backgroundColor = Colors.grey,
    this.radius = 15,
  });
  final String? url;
  final Color backgroundColor;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return url != null
        ? CircleAvatar(
            backgroundColor: backgroundColor.withOpacity(0.5),
            radius: radius,
            foregroundImage: NetworkImage(url!),
          )
        : CircleAvatar(
            backgroundColor: backgroundColor.withOpacity(0.5),
            radius: radius,
            foregroundImage: const AssetImage(
              AppAssets.userPlaceholder,
              package: AppAssets.package,
            ),
          );
  }
}
// AssetImage(
//               AppAssets.userPlaceholder,
//               package: AppAssets.package,
//             )