import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_avatar_community.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constans/app_assets.dart';
import '../../../constans/app_text_style.dart';
import '../../../viewmodel/category_viewmodel.dart';
import '../../categories/categories_view.dart';
import '../../social/community_list_by_category_id.dart';
//CategoryVM

class CategoriesExplore extends StatefulWidget {
  const CategoriesExplore({super.key});

  @override
  State<CategoriesExplore> createState() => _CategoriesExploreState();
}

class _CategoriesExploreState extends State<CategoriesExplore> {
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

  Future<void> onPressedCategories() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Builder(builder: (context) {
        return const CategoriesView();
      }),
    ));
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
    return Consumer<CategoryVM>(
      builder: (_, vm, __) {
        final categories = vm.getAllCategories();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              GestureDetector(
                onTap: onPressedCategories,
                child: Row(
                  children: [
                     Expanded(
                      child: Text(
                        'Categories',
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

              const SizedBox(height: 13),
              // Grid
              Wrap(
                runSpacing: 16,
                children: List.generate(
                    (categories.length > 8)
                        ? 8
                        : (categories.length == 1)
                            ? 2
                            : categories.length, (index) {
                  if (categories.length == 1 && index == 1) {
                    return const SizedBox(width: 170);
                  }
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      onPressedCategory(category);
                    },
                    child: SizedBox(
                      width: 170,
                      child: Row(
                        children: [
                          CustomAvatarCommunity(
                            url: category.avatar?.fileUrl,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              category.name ?? '',
                              style: AppTextStyle.header2.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
