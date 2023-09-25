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
    ImageProvider image = const AssetImage(
      AppAssets.account,
      package: AppAssets.package,
    );
    if (url != null) {
      image = NetworkImage(url!);
    } else if (imagePlaceholder != null) {
      image = imagePlaceholder!;
    }
    double size = radius*2;
    return FadeAnimation(
      child: ClipOval(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            image: DecorationImage(image: image, fit: BoxFit.fill),
            color: backgroundColor.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
