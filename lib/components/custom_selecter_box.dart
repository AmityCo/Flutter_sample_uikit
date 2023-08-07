import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constans/app_assets.dart';
import 'header_filed.dart';

class CustomSelecterBox extends StatelessWidget {
  const CustomSelecterBox({
    super.key,
    required this.title,
    this.isRequired = false,
    this.hintText,
    this.value, 
    this.onPressed,
  });
  final String title;
  final String? hintText;
  final String? value;
  final bool isRequired;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    String text = (value != null && value!.isNotEmpty)
        ? value!
        : (hintText != null)
            ? hintText!
            : '';
    Color color =
        (value != null && value!.isNotEmpty) ? Colors.black : Colors.grey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        child: Column(
          children: [
            HeaderFiled(
              title: title,
              isRequired: isRequired,
            ),
            GestureDetector(
              onTap: onPressed,
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        text,
                        style: AppTextStyle.header1.copyWith(
                          color: color,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      AppAssets.iconArrowRigth,
                      package: AppAssets.package,
                      theme: const SvgTheme(currentColor: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
          ],
        ),
      ),
    );
  }
}
