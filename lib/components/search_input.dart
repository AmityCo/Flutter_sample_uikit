import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:amity_uikit_beta_service/utils/de_bounce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/configuration_viewmodel.dart';

class SearchInput extends StatefulWidget {
  const SearchInput({
    super.key,
    this.controller,
    this.onChanged,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final debounce = Debounce(duration: const Duration(milliseconds: 300));

  @override
  void dispose() {
    debounce.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.watch<AmityUIConfiguration>();
    return Container(
      width: double.infinity,
      height: 40.0,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFFEBECEF)),
          ),
          TextFormField(
            controller: widget.controller,
            textCapitalization: TextCapitalization.sentences,
            cursorColor: appColors.secondaryColor,
            style: AppTextStyle.header1.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
            decoration: InputDecoration(
              prefixIconColor: const Color(0xFF898E9E),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              hintText: 'Search',
              hintStyle: AppTextStyle.header1.copyWith(
                color: const Color(0xFF898E9E),
              ),
              contentPadding: EdgeInsets.zero,
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: appColors.secondaryColor, width: 2.0),
              ),
            ),
            onChanged: (String? value) {
              if (value == null) {
                return;
              }
              if (widget.onChanged != null) {
                debounce.run(() {
                  widget.onChanged!(value);
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
