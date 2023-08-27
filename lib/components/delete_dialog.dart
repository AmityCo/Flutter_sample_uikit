import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constans/app_text_style.dart';
import '../viewmodel/community_viewmodel.dart';

class DeleteDialog {
  bool isOpenDialog = false;
  BuildContext? contextDialog;

  Future<void> open({
    required BuildContext context,
    VoidCallback? onPressedCancel,
    VoidCallback? onPressedDelete,
    required String title,
  }) async {
    if (isOpenDialog) {
      return;
    }
    return await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) {
        contextDialog = context;
        isOpenDialog = true;
        return _CustomWidget(
          title: title,
          onPressedCancel: onPressedCancel,
          onPressedDelete: onPressedDelete,
          close: () {
            _close();
          },
        );
      },
    );
  }

  void close() {
    _close();
  }

  void _close() async {
    if (contextDialog != null) {
      isOpenDialog = false;
      Navigator.pop(contextDialog!);
    }
  }
}

class _CustomWidget extends StatefulWidget {
  const _CustomWidget({
    required this.close,
    this.onPressedCancel,
    this.onPressedDelete, 
    required this.title,
  });

  final Function() close;
  final VoidCallback? onPressedCancel;
  final VoidCallback? onPressedDelete;
  final String title;

  @override
  State<_CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<_CustomWidget> {
  @override
  void initState() {
    setup();
    super.initState();
  }

  Future<void> setup() async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      context.read<CommunityVM>().initAmityMyCommunityList();
    }
  }

  void close() {
    widget.close();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        close();
        return Future.value(true);
      },
      child: GestureDetector(
        onTap: () => close(),
        child: Scaffold(
          backgroundColor: Colors.black54,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Card(
                  title: widget.title,
                  onPressedCancel: widget.onPressedCancel,
                  onPressedDelete: widget.onPressedDelete,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    this.onPressedCancel,
    this.onPressedDelete, 
    required this.title,
  });
  final String title;
  final VoidCallback? onPressedCancel;
  final VoidCallback? onPressedDelete;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
         Flexible(
            child: Text(
              title,
              style: AppTextStyle.header1,
            ),
          ),
          const SizedBox(height: 15),
          const Flexible(
            child: Text(
              'Are you sure you want to delete it? This cannot be undone and your data cannot be restored.',
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPressedCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context
                        .watch<AmityUIConfiguration>()
                        .cancelButtonConfig
                        .backgroundColor,
                  ),
                  child: Text(
                    'CANCEL',
                    style: AppTextStyle.header2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context
                          .watch<AmityUIConfiguration>()
                          .cancelButtonConfig
                          .textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPressedDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context
                        .watch<AmityUIConfiguration>()
                        .deleteButtonConfig
                        .backgroundColor,
                  ),
                  child: Text(
                    'DELETE',
                    style: AppTextStyle.header2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context
                          .watch<AmityUIConfiguration>()
                          .deleteButtonConfig
                          .textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
