import 'package:amity_uikit_beta_service/components/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../components/custom_faded_slide_animation.dart';
import '../../components/show_community_horizontal.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../create_community/create_community.dart';

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
    return CupertinoScaffold(
      body: Scaffold(
        appBar: CustomAppBar(
          context: context,
          titleText: 'My Communities',
          actions: [
            if (context
                .watch<AmityUIConfiguration>()
                .appbarConfig
                .isOpenAddCommunity)
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
          return CustomFadedSlideAnimation(
            child: ListView(
              children: List.generate(
                data.length,
                (index) {
                  final community = data[index];
                  return ShowCommunityHorizontal(
                    community: community,
                    onComebackScreen: (){
                      init();
                    },
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
