import 'package:flutter/material.dart';

class AppTextStyle {
  static TextStyle mainStyle = const TextStyle();
  static TextStyle display1 = mainStyle.copyWith(
    fontSize: 23,
    fontWeight: FontWeight.w600,
  );

  static TextStyle display2 = mainStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle header1 = mainStyle.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  static TextStyle header2 = mainStyle.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.normal,
  );

  static TextStyle body1 = mainStyle.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

}
