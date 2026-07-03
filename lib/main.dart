import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/strings.dart';
import 'core/theme/app_colors.dart';
import 'features/dashboard/presentation/developer_disclaimer_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          bodyLarge: GoogleFonts.outfit(color: AppColors.textPrimary),
          bodyMedium: GoogleFonts.outfit(color: AppColors.textSecondary),
        ),
        useMaterial3: true,
      ),
      home: const DeveloperDisclaimerScreen(),
    );
  }
}
