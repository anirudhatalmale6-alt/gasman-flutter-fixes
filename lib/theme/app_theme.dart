import 'package:flutter/material.dart';

class AppColors {
  static const teal = Color(0xFF2D7A78);
  static const amber = Color(0xFFF4A300);
  static const bg = Color(0xFFF6F7F8);

  static const Color kTeal = Color(0xFF008080);
  static const Color kAmber = Color(0xFFFFB000);
  static const Color kDark = Color(0xFF0B2E2E);
  static  const Color kLightBg = Color(0xFFF9F9F9);

  static const Color kChartVatSales = Color(0xFF0B7285);  // dark teal-ish
  static const Color kChartVatPurchases = Color(0xFFFAA307);

  static const primary = Color(0xFF2563EB); // blue
  static const background = Color(0xFFF8FAFC);
  static const card = Colors.white;

  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);

  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);



}

const TextStyle kSectionTitleStyle =
TextStyle(fontSize: 16, fontWeight: FontWeight.w600);


ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    primary: AppColors.teal,
    secondary: AppColors.amber,
  ),
  scaffoldBackgroundColor: AppColors.bg,
  appBarTheme: const AppBarTheme(backgroundColor: AppColors.teal, foregroundColor: Colors.white, centerTitle: true),
  cardTheme: /*CardTheme(color: const Color(0xFFE3EFEE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0)*/CardThemeData(
    color: const Color(0xFFE3EFEE),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    elevation: 0
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14))),
  inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
);
