import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:flutter/material.dart';

import 'custom_avatar_community.dart';

class RecommendedCard extends StatelessWidget {
  const RecommendedCard({
    super.key,
    this.url,
    required this.title,
    required this.description,
    required this.subTitle,
    required this.caption,
  });
  final String? url;
  final String title;
  final String subTitle;
  final String caption;
  final String description;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      height: 194,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAvatarCommunity(
            url: url,
          ),
          const SizedBox(height: 8),
          RecommendedText(
            text: title,
            style: AppTextStyle.header2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          RecommendedText(
            text: subTitle,
            style: AppTextStyle.body1,
          ),
          RecommendedText(
            text: caption,
            style: AppTextStyle.body1.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          RecommendedText(
            text: description,
            style: AppTextStyle.body1,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class RecommendedText extends StatelessWidget {
  const RecommendedText({
    super.key,
    required this.text,
    this.style,
    this.flex = 1,
    this.maxLines,
  });
  final int flex;
  final String text;
  final TextStyle? style;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: flex,
          child: Text(
            text,
            style: style,
            overflow: TextOverflow.ellipsis,
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }
}
