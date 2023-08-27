import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:flutter/material.dart';

import '../../../components/recommended_card.dart';

class RecommendedExplore extends StatelessWidget {
  const RecommendedExplore({
    super.key,
    required this.data,
    this.onPressedCommunity,
  });
  final List<AmityCommunity> data;
  final ValueChanged<AmityCommunity>? onPressedCommunity;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xffEBECEF),
      ),
      child: Column(
        children: [
          // Header
           Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Recommended for you',
                style: AppTextStyle.header1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Card
          SizedBox(
            width: double.infinity,
            height: 194,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(data.length, (index) {
                final community = data[index];
                String subTitle = '';
                if (community.categories != null &&
                    community.categories!.isNotEmpty) {
                  subTitle = community.categories?[0]?.name ?? '';
                }
                return GestureDetector(
                  onTap: () {
                    if (onPressedCommunity != null) {
                      onPressedCommunity!(community);
                    }
                  },
                  child: RecommendedCard(
                    url: community.avatarImage?.fileUrl,
                    title: community.displayName ?? '',
                    subTitle: subTitle,
                    caption: '${community.membersCount ?? 0} ${(community.membersCount ?? 0) > 1 ?'members':'member'}',
                    description: community.description ?? '',
                    isOfficial: community.isOfficial ?? false,
                    isPublic: community.isPublic ?? true,
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
