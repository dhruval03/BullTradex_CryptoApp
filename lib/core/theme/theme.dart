import 'package:bulltradex/core/theme/colors.dart';
import 'package:flutter/material.dart';

class AppTheme{
  // ligh theme 
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF3F3F5),
    primaryColor: AppColors.lightPrimary,
    textTheme: TextTheme(bodyLarge: TextStyle(color: AppColors.lightText)),
  );

  // dark theme 
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkPrimary,
    textTheme: TextTheme(bodyLarge: TextStyle(color: AppColors.darkText)),
  );
}