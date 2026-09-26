import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///* AppTextStyles — centralized text style definitions.
///* All font sizes use .sp from flutter_screenutil for responsive scaling.
///* Naming pattern: {weightDescription}{fontSize} — e.g. semiBold20, regular14.

abstract class AppTextStyles {
  static TextStyle get bold24 =>
      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, height: 1.3);

  static TextStyle get semiBold20 =>
      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get semiBold18 =>
      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, height: 1.35);

  static TextStyle get bold18 =>
      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, height: 1.35);

  static TextStyle get medium16 =>
      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get medium14 =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get regular14 =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get regular12 =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get medium12 =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get bold12 =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, height: 1.4);

  static TextStyle get bold14 =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, height: 1.4);
}
