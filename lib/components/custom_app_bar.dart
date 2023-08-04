import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/configuration_viewmodel.dart';

class CustomAppBar extends AppBar {
  final BuildContext context;
  final String? titleText;
  final bool disableLeading;

  CustomAppBar({
    super.key,
    required this.context,
    this.titleText,
    this.disableLeading = true,
    super.leading,
    super.automaticallyImplyLeading = true,
    super.title,
    super.actions,
    super.flexibleSpace,
    super.bottom,
    super.elevation,
    super.scrolledUnderElevation,
    super.notificationPredicate = defaultScrollNotificationPredicate,
    super.shadowColor,
    super.surfaceTintColor,
    super.shape,
    super.backgroundColor,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary = true,
    super.centerTitle,
    super.excludeHeaderSemantics = false,
    super.titleSpacing,
    super.toolbarOpacity = 1.0,
    super.bottomOpacity = 1.0,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
    super.forceMaterialTransparency = false,
    super.clipBehavior,
  });

  @override
  Color? get backgroundColor =>
      context.watch<AmityUIConfiguration>().appbarConfig.backgroundColor;

  @override
  Widget? get title => (super.title == null && titleText != null)
      ? Text(
          titleText!,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w500,
                color: context
                    .watch<AmityUIConfiguration>()
                    .appbarConfig
                    .textColor,
              ),
        )
      : super.title;

  @override
  Widget? get leading => !disableLeading ? super.leading ??
      IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: context
                .watch<AmityUIConfiguration>()
                .appbarConfig
                .iconBackColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ):null;
}
