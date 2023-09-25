import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constans/app_assets.dart';
import 'custom_avatar_community.dart';

class RecommendedCard extends StatelessWidget {
  const RecommendedCard({
    super.key,
    this.url,
    required this.title,
    required this.description,
    required this.subTitle,
    required this.caption,
    this.isOfficial = false,
    this.isPublic = true,
  });
  final String? url;
  final String title;
  final String subTitle;
  final String caption;
  final String description;
  final bool isOfficial;
  final bool isPublic;
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
        borderRadius: BorderRadius.circular(16),
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
            isOfficial: isOfficial,
            isPublic: isPublic,
          ),
          if (subTitle.isNotEmpty)
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
    this.isOfficial = false,
    this.isPublic = true,
  });
  final int flex;
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final bool isOfficial;
  final bool isPublic;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isPublic)
          const Icon(
            Icons.lock_outlined,
            color: Colors.black,
            size: 12,
          ),
        Flexible(
          flex: flex,
          child: Text(
            text,
            style: style,
            overflow: TextOverflow.ellipsis,
            maxLines: maxLines,
          ),
        ),
        if (isOfficial)
          SvgPicture.asset(
            AppAssets.verified,
            width: 20,
            height: 20,
            package: AppAssets.package,
          ),
      ],
    );
  }
}
