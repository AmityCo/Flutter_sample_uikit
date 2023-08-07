import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:flutter/material.dart';

class HeaderFiled extends StatelessWidget {
  const HeaderFiled({
    super.key,
    required this.title,
    required this.isRequired,
    this.currentLength,
    this.maxlength,
  });
  final String title;
  final bool isRequired;
  final int? currentLength;
  final int? maxlength;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              text: title,
              style: AppTextStyle.header1.copyWith(color: Colors.black),
              children: <TextSpan>[
                if (isRequired)
                  TextSpan(
                    text: '*',
                    style: AppTextStyle.header1.copyWith(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
        if (maxlength != null && currentLength != null)
          Text(
            '$currentLength/$maxlength',
            style: AppTextStyle.body1.copyWith(
              color: (currentLength! >= maxlength!) ? Colors.red : Colors.grey,
              fontWeight: FontWeight.normal,
            ),
          )
      ],
    );
  }
}
