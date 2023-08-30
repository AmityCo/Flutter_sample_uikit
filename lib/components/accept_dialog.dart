import 'package:amity_uikit_beta_service/constans/app_string.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constans/app_text_style.dart';
import '../viewmodel/community_viewmodel.dart';

class AcceptDialog {
  bool isOpenDialog = false;
  BuildContext? contextDialog;

  Future<void> open({
    required BuildContext context,
    VoidCallback? onPressedCancel,
    VoidCallback? onPressedAccept,
    required ButtonConfig acceptButtonConfig,
    ButtonConfig? cancelButtonConfig,
    required String title,
    required String message,
    String? acceptText,
    String? cancelText,
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
          message: message,
          onPressedCancel: onPressedCancel,
          onPressedAccept: onPressedAccept,
          acceptButtonConfig: acceptButtonConfig,
          cancelButtonConfig: cancelButtonConfig,
          acceptText: acceptText,
          cancelText: cancelText,
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
    if (contextDialog != null && isOpenDialog) {
      isOpenDialog = false;
      Navigator.pop(contextDialog!);
    }
  }
}

class _CustomWidget extends StatefulWidget {
  const _CustomWidget({
    required this.close,
    this.onPressedCancel,
    this.onPressedAccept,
    required this.title,
    required this.acceptButtonConfig,
    this.cancelButtonConfig,
    required this.message,
    this.acceptText,
    this.cancelText,
  });

  final Function() close;

  final String title;
  final String message;
  final String? acceptText;
  final String? cancelText;
  final VoidCallback? onPressedCancel;
  final VoidCallback? onPressedAccept;
  final ButtonConfig acceptButtonConfig;
  final ButtonConfig? cancelButtonConfig;

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
                Center(
                  child: _Card(
                    title: widget.title,
                    message: widget.message,
                    onPressedCancel: widget.onPressedCancel,
                    onPressedAccept: widget.onPressedAccept,
                    acceptButtonConfig: widget.acceptButtonConfig,
                    cancelButtonConfig: widget.cancelButtonConfig,
                    acceptText: widget.acceptText,
                    cancelText: widget.cancelText,
                  ),
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
    this.onPressedAccept,
    required this.title,
    required this.acceptButtonConfig,
    this.cancelButtonConfig,
    required this.message,
    this.acceptText,
    this.cancelText,
  });
  final String title;
  final String message;
  final String? acceptText;
  final String? cancelText;
  final VoidCallback? onPressedCancel;
  final VoidCallback? onPressedAccept;
  final ButtonConfig acceptButtonConfig;
  final ButtonConfig? cancelButtonConfig;

  @override
  Widget build(BuildContext context) {
    final cancelConfig = cancelButtonConfig ??
        context.watch<AmityUIConfiguration>().cancelButtonConfig;
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
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
          Flexible(
            child: Text(
              message,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (){
                    if(onPressedCancel!=null){
                       onPressedCancel!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cancelConfig.backgroundColor,
                  ),
                  child: Text(
                    cancelText ?? AppString.cancelButton,
                    style: AppTextStyle.header2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cancelConfig.textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: (){
                    if(onPressedAccept!=null){
                       onPressedAccept!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: acceptButtonConfig.backgroundColor,
                  ),
                  child: Text(
                    acceptText ?? AppString.acceptButton,
                    style: AppTextStyle.header2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: acceptButtonConfig.textColor,
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
