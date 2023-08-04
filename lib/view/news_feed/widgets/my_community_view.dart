import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constans/app_assets.dart';
import '../../../constans/app_text_style.dart';

class MyCommunityView extends StatelessWidget {
  const MyCommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 17),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'My Community',
                  style: AppTextStyle.header1,
                ),
              ),
              SvgPicture.asset(
                AppAssets.iconArrowRigth,
                package: AppAssets.package,
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),

        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(10, (index) {
                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: SizedBox(
                    width: 64,
                    height: 62,
                    child: Column(
                      children: [
                        ClipOval(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Row(
                          children: [
                            Text(
                              'Earth Sa...',
                              style: AppTextStyle.body1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const Divider()
      ],
    );
  }
}
