import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextStyle frauncesItalic({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w300,
    Color? color,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: FontStyle.italic,
      color: color,
      letterSpacing: -fontSize * 0.02,
      height: 1.0,
    );
  }

  static TextStyle frauncesRegular({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w300,
    Color? color,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -fontSize * 0.02,
      height: 1.0,
    );
  }

  static ThemeData get tema {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.fundo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaria,
        primary: AppColors.primaria,
        error: AppColors.erro,
      ),
    );

    final textTheme = GoogleFonts.atkinsonHyperlegibleTextTheme(base.textTheme).copyWith(
      bodyLarge: GoogleFonts.atkinsonHyperlegible(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textoForte,
      ),
      bodyMedium: GoogleFonts.atkinsonHyperlegible(
        fontSize: 16,
        color: AppColors.textoForte,
      ),
      titleLarge: GoogleFonts.atkinsonHyperlegible(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textoForte,
      ),
      titleMedium: GoogleFonts.atkinsonHyperlegible(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textoForte,
      ),
      labelLarge: GoogleFonts.atkinsonHyperlegible(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.superficie,
        foregroundColor: AppColors.textoForte,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.atkinsonHyperlegible(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textoForte,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaria,
          foregroundColor: AppColors.papel,
          minimumSize: const Size.fromHeight(64),
          textStyle: GoogleFonts.atkinsonHyperlegible(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaria,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: AppColors.primaria, width: 2),
          textStyle: GoogleFonts.atkinsonHyperlegible(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaria,
          textStyle: GoogleFonts.atkinsonHyperlegible(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textoForte,
        contentTextStyle: GoogleFonts.atkinsonHyperlegible(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.papel,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.superficie,
        titleTextStyle: GoogleFonts.atkinsonHyperlegible(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textoForte,
        ),
        contentTextStyle: GoogleFonts.atkinsonHyperlegible(
          fontSize: 17,
          color: AppColors.textoForte,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        labelStyle: GoogleFonts.atkinsonHyperlegible(
          fontSize: 16,
          color: AppColors.textoFraco,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.tinta, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.tinta, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.oceano, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.erro, width: 2),
        ),
      ),
    );
  }
}
