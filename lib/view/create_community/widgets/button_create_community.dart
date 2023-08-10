import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constans/app_text_style.dart';
import '../../../viewmodel/configuration_viewmodel.dart';

class ButtonCreateCommunity extends StatelessWidget {
  const ButtonCreateCommunity({
    super.key,
    required this.title,
    this.onPressed,
    required this.iconData,
  });
  final String title;
  final IconData iconData;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: context
                .watch<AmityUIConfiguration>()
                .buttonConfig
                .backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: SizedBox(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  size: 30,
                  color: context
                      .watch<AmityUIConfiguration>()
                      .buttonConfig
                      .textColor,
                ),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: AppTextStyle.header1.copyWith(
                    color: context
                        .watch<AmityUIConfiguration>()
                        .buttonConfig
                        .textColor,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
