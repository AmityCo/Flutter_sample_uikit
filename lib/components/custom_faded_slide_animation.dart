import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';

class CustomFadedSlideAnimation extends StatelessWidget {
  const CustomFadedSlideAnimation({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return FadedSlideAnimation(
      beginOffset: const Offset(0, 0.3),
      endOffset: const Offset(0, 0),
      slideCurve: Curves.linearToEaseOut,
      child: child,
    );
  }
}
