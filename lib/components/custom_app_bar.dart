import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/configuration_viewmodel.dart';

AppBar customAppBar(BuildContext context,{String title = ''}){
  final theme = Theme.of(context);
  return AppBar(
      backgroundColor:
          context.watch<AmityUIConfiguration>().appbarConfig.backgroundColor,
      elevation: 0,
      title: Text(
        title,
        style: theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w500,
          color: context.watch<AmityUIConfiguration>().appbarConfig.textColor,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color:
              context.watch<AmityUIConfiguration>().appbarConfig.iconBackColor,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
}