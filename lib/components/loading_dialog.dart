import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingDialog {
  bool isOpenDialog = false;
  BuildContext? _mContext;
  void open(BuildContext context) {
    if (!isOpenDialog) {
      isOpenDialog = true;
      showDialog(
        context: context,
        builder: (mContext) {
          _mContext = mContext;
          return Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(
                color: context.watch<AmityUIConfiguration>().secondaryColor,
              ),
            ),
          );
        },
      );
    }
  }

  void close() {
    if (isOpenDialog) {
      isOpenDialog = false;
      if (_mContext != null) {
        Navigator.pop(_mContext!);
      }
    }
  }
}
