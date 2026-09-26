import 'package:flutter/material.dart';
import 'package:booking_appointments/core/theme/dark_theme.dart' as dark_theme;
import 'package:booking_appointments/core/theme/light_theme.dart'
    as light_theme;

///* AppTheme — facade exposing the app's light and dark ThemeData instances.
///* Import and reference AppTheme.lightTheme / AppTheme.darkTheme everywhere.
///* Never import light_theme.dart or dark_theme.dart directly in app.dart.

abstract class AppTheme {
  static ThemeData get lightTheme => light_theme.lightTheme;
  static ThemeData get darkTheme => dark_theme.darkTheme;
}
