import 'package:flutter/material.dart';

class AppColors{
  static const Color logoBgColor = Color(0xFF140519);

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D47A1),
      Color(0xFF1E88E5),
    ],
  );

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightPrimary = Color(0xFF0D47A1);
  static const Color lightText = Color(0xFF212121);
  static const lightAccent = Color(0xFF03A9F4); // Light blue
  static const lightCard = Color(0xFFFFFFFF); // White cards

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkPrimary = Color(0xFFBB86FC);
  static const Color darkText = Color(0xFFE0E0E0);
  static const darkAccent = Color(0xFF64B5F6); // Light blue
  static const darkCard = Color(0xFF1E1E1E); // Dark cards
}