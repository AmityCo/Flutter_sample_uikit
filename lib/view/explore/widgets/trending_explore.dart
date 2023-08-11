import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../../../components/custom_avatar_community.dart';
import '../../../constans/app_text_style.dart';

class TrendingExplore extends StatelessWidget {
  const TrendingExplore({
    super.key,
    required this.data,
    this.onPressedCommunity,
  });
  final List<AmityCommunity> data;
  final ValueChanged<AmityCommunity>? onPressedCommunity;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Today’s trending',
                style: AppTextStyle.header1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ],
          ),
          ...List.generate(data.length, (index) {
            final community = data[index];
            String subTitle = '';
            if (community.categories != null &&
                community.categories!.isNotEmpty) {
              subTitle = community.categories?[0]?.name ?? '';
            }
            final subtitleTextStyle =
                AppTextStyle.body1.copyWith(color: const Color(0xff636878));
            return GestureDetector(
              onTap: (){
                if(onPressedCommunity != null){
                  onPressedCommunity!(community);
                }
              },
              child: Container(
                height: 56,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    CustomAvatarCommunity(
                      url: community.avatarImage?.fileUrl,
                      radius: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyle.header2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff1054DE),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              community.displayName ?? '',
                              style: AppTextStyle.header2.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  subTitle,
                                  style: subtitleTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ' • ${community.membersCount} members',
                                style: subtitleTextStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
