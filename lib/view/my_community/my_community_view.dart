import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_list_tile.dart';
import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../create_community/create_community.dart';
import '../social/community_feed.dart';

class MyCommunityView extends StatefulWidget {
  const MyCommunityView({super.key});

  @override
  State<MyCommunityView> createState() => _MyCommunityViewState();
}

class _MyCommunityViewState extends State<MyCommunityView> {
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
    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        titleText: 'My Community',
        actions: [
          InkWell(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateCommunityView(),
                ),
              );
              init();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.add,
                color: context
                    .watch<AmityUIConfiguration>()
                    .appbarConfig
                    .iconBackColor,
              ),
            ),
          )
        ],
      ),
      body: Consumer<CommunityVM>(builder: (_, vm, __) {
        final data = vm.getAmityMyCommunities();
        return ListView(
          children: List.generate(
            data.length,
            (index) {
              final community = data[index];
              return CustomListTitle(
                title: community.displayName ?? "Community",
                url: community.avatarImage?.fileUrl,
                subtitle: Text(
                  '${community.membersCount ?? 0} member',
                  style: AppTextStyle.body1,
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider<CommuFeedVM>(
                        create: (context) => CommuFeedVM(),
                        builder: (context, child) => CommunityScreen(
                          community: community,
                        ),
                      ),
                    ),
                  );
                  init();
                },
              );
            },
          ),
        );
      }),
    );
  }
}
