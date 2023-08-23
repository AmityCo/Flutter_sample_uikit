import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_avatar.dart';
import 'package:amity_uikit_beta_service/view/my_community/my_community_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constans/app_assets.dart';
import '../../../constans/app_text_style.dart';
import '../../../viewmodel/community_feed_viewmodel.dart';
import '../../../viewmodel/community_viewmodel.dart';
import '../../social/community_feed.dart';

class MyCommunityHorizontalView extends StatefulWidget {
  const MyCommunityHorizontalView({
    Key? key,
  }) : super(key: key);

  @override
  State<MyCommunityHorizontalView> createState() =>
      _MyCommunityHorizontalViewState();
}

class _MyCommunityHorizontalViewState extends State<MyCommunityHorizontalView> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    context.read<CommunityVM>().initAmityMyCommunityList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 17),
        // Header
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const MyCommunityView(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'My Communities',
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
        ),

        const SizedBox(height: 5),
        Consumer<CommunityVM>(builder: (_, vm, __) {
          final communities = vm.getAmityMyCommunities();

          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 17,
                ),
                child: Row(
                  children: List.generate(communities.length, (index) {
                    final community = communities[index];
                    return MyCommunityHorizontalItem(
                      community: community,
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) =>
                              ChangeNotifierProvider<CommuFeedVM>(
                            create: (context) => CommuFeedVM(),
                            builder: (context, child) => CommunityScreen(
                              community: community,
                            ),
                          ),
                        );
                        init();
                      },
                    );
                  }),
                ),
              ),
            ),
          );
        }),
        const Divider()
      ],
    );
  }
}

class MyCommunityHorizontalItem extends StatelessWidget {
  const MyCommunityHorizontalItem({
    super.key,
    required this.community,
    this.onTap,
  });
  final AmityCommunity community;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: SizedBox(
          width: 64,
          height: 62,
          child: Column(
            children: [
              CustomAvatar(
                url: community.avatarImage?.fileUrl,
                radius: 20,
                imagePlaceholder: const AssetImage(
                  AppAssets.accountGroup,
                  package: AppAssets.package,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      community.displayName ?? 'Community',
                      style: AppTextStyle.body1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
