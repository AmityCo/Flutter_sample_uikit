import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/social/community_list_by_category_id.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/category_viewmodel.dart';

class AllCategoryList extends StatefulWidget {
  const AllCategoryList({super.key});
  @override
  AllCategoryListState createState() => AllCategoryListState();
}

class AllCategoryListState extends State<AllCategoryList> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<CategoryVM>(context, listen: false).initAllCategoryList();
    });
    super.initState();
  }

  List<AmityCommunityCategory> getList() {
    return Provider.of<CategoryVM>(context, listen: false).getAllCategories();
  }

  int getLength() {
    return Provider.of<CategoryVM>(context, listen: false)
        .getAllCategories()
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        AppBar().preferredSize.height;

    final theme = Theme.of(context);
    return Consumer<CategoryVM>(builder: (context, vm, _) {
        return Column(
          children: [
            Expanded(
              child: Container(
                height: bHeight,
                color: Colors.grey[200],
                child: FadedSlideAnimation(
                  // ignore: sort_child_properties_last
                  child: getLength() < 1
                      ? const Center()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: getLength(),
                          itemBuilder: (context, index) {
                            return CategoryWidget(
                              category: getList()[index],
                              theme: theme,
                            );
                          },
                        ),
                  beginOffset: const Offset(0, 0.3),
                  endOffset: const Offset(0, 0),
                  slideCurve: Curves.linearToEaseOut,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    Key? key,
    required this.category,
    required this.theme,
  }) : super(key: key);

  final AmityCommunityCategory category;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Builder(builder: (context) {
            return CommunityListByCategoryIdScreen(
              selectedCategoryId: category.categoryId,
            );
          }),
        ));
      },
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: FadeAnimation(
                    child: (category.avatar?.fileUrl != null)
                        ? CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                (NetworkImage(category.avatar!.fileUrl)))
                        : const SizedBox(
                            width: 40,
                            height: 40,
                          )
                    // TODO: fix asset not found
                    // : const CircleAvatar(
                    //     backgroundImage:
                    //     AssetImage(
                    //         "/assets/images/user_placeholder.png")),
                    ),
                title: Text(
                  category.name ?? "Category",
                  style: theme.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
