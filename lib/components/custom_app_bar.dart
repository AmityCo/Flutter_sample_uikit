import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/configuration_viewmodel.dart';

class CustomAppBar extends AppBar {
  final BuildContext context;
  final String? titleText;
  final bool enableLeading;
  final VoidCallback? onTapCloseActionLeading;
  CustomAppBar({
    super.key,
    required this.context,
    this.titleText,
    this.enableLeading = true,
    this.onTapCloseActionLeading,
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
          style: AppTextStyle.display2.copyWith(
            fontWeight: FontWeight.w500,
            color: context.watch<AmityUIConfiguration>().appbarConfig.textColor,
          ),
        )
      : super.title;

  @override
  Widget? get leading => !enableLeading ? super.leading : _getLeading();

  @override
  bool get automaticallyImplyLeading =>
      enableLeading ? super.automaticallyImplyLeading : enableLeading;

  Widget _getLeading() {
    return GestureDetector(
      child: Icon(
        Icons.chevron_left,
        color: context.read<AmityUIConfiguration>().appbarConfig.iconBackColor,
        size: 35,
      ),
      onTap: () {
        if(onTapCloseActionLeading != null){
          onTapCloseActionLeading!();
        }
        Navigator.of(context).pop();
      },
    );
  }
}
