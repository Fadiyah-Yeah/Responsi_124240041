import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 1. Uncommit baris ini
import 'core/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ivory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sage,
        primary: AppColors.sage,
        secondary: AppColors.moss,
        surface: AppColors.ivory,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpaceNews Explorer',
      theme: base.copyWith(
        textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.ivory,
          foregroundColor: AppColors.ink,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.sand),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.sand),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.sage, width: 1.5),
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}