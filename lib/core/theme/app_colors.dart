import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F9);

  static const Color primary = Color(0xFF491F53);
  static const Color secondary = Color(0xFF00B1AC);
  static const Color accent = Color(0xFF00B1AC); 
  
  static const Color success = Color(0xFF00B1AC);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textMuted = Color(0xFF64748B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFFEDF2F7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
