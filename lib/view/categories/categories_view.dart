import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_app_bar.dart';
import '../../components/custom_faded_slide_animation.dart';
import '../../components/custom_list_tile.dart';
import '../../viewmodel/category_viewmodel.dart';
import '../social/community_list_by_category_id.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
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
    context.read<CategoryVM>().initAllCategoryList();
  }

  Future<void> onPressedCategory(AmityCommunityCategory category) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Builder(builder: (context) {
        return CommunityListByCategoryIdScreen(
          category: category,
        );
      }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        titleText: 'Categories',
      ),
      body: Consumer<CategoryVM>(builder: (_, vm, __) {
        final data = vm.getAllCategories();
        return CustomFadedSlideAnimation(
          child: ListView(
            children: List.generate(
              data.length,
              (index) {
                final category = data[index];
                return CustomListTitle(
                  title: category.name ?? "Community",
                  url: category.avatar?.fileUrl,
                  onPressed: () {
                    onPressedCategory(category);
                  },
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
