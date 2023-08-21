import 'package:flutter/material.dart';

import '../constans/app_text_style.dart';
import 'custom_avatar.dart';

class CustomAvatarName extends StatelessWidget {
  const CustomAvatarName(
      {super.key, this.url, this.name, this.onTapClose, this.onTap});
  final String? url;
  final String? name;
  final VoidCallback? onTap;
  final VoidCallback? onTapClose;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        width: 64,
        height: 62,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Column(
                children: [
                  CustomAvatar(
                    url: url,
                    radius: 20,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name ?? '',
                          style: AppTextStyle.body1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            if (onTapClose != null)
              Positioned(
                top: 0,
                right: 8,
                child: GestureDetector(
                  onTap: onTapClose,
                  child: ClipOval(
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(color: Colors.black26),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.8),
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
