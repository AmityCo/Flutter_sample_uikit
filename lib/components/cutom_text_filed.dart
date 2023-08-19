import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'header_filed.dart';

class CutomTextFiled extends StatefulWidget {
  const CutomTextFiled({
    super.key,
    required this.title,
    this.isRequired = false,
    this.maxlength,
    this.onChanged,
    this.hintText,
    this.maxLines = 1, 
    this.initialValue,
  });
  final String title;
  final String? hintText;
  final bool isRequired;
  final int? maxlength;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final String? initialValue;

  @override
  State<CutomTextFiled> createState() => _CutomTextFiledState();
}

class _CutomTextFiledState extends State<CutomTextFiled> {
  final controller = TextEditingController();

  @override
  void initState() {
    if(widget.initialValue != null){
      controller.text  = widget.initialValue!;
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          HeaderFiled(
            title: widget.title,
            isRequired: widget.isRequired,
            currentLength: controller.text.length,
            maxlength: widget.maxlength,
          ),
          TextFormField(
            textCapitalization:TextCapitalization.sentences,
            controller: controller,
            minLines: 1,
            maxLines: widget.maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hintText,
            ),
            inputFormatters: [
              if(widget.maxlength != null)
                LengthLimitingTextInputFormatter(widget.maxlength),
            ],
            onChanged: (String? v) {
              if (v != null) {
                if (widget.onChanged != null) {
                  widget.onChanged!(v);
                }
              }
              updateScreen();
            },
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          )
        ],
      ),
    );
  }

  void updateScreen() {
    if (mounted) {
      setState(() {});
    }
  }
}
