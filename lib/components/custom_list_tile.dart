import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/configuration_viewmodel.dart';

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
      leading: FadeAnimation(
        child: (url != null)
            ? CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(url!),
              )
            : ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  color: context
                      .watch<AmityUIConfiguration>()
                      .buttonConfig
                      .backgroundColor,
                  child: iconNoImage ??
                      Icon(
                        Icons.question_answer,
                        color: context
                            .watch<AmityUIConfiguration>()
                            .buttonConfig
                            .textColor,
                      ),
                ),
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
