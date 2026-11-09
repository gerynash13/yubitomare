import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors and text styles from the Stitch "warm paper" design system.
class T {
  T._();

  // Paper
  static const paper = Color(0xFFFFF8F6);
  static const paperLow = Color(0xFFFFF1EC);
  static const paperMid = Color(0xFFFFE9E2);
  static const paperHigh = Color(0xFFFEE2D9);

  // Ink
  static const ink = Color(0xFF261813);
  static const inkSoft = Color(0xFF5B403B);
  static const line = Color(0xFFE4BEB7);

  // Accents
  static const vermilion = Color(0xFFB41F09);
  static const vermilionBright = Color(0xFFD83922);
  static const persimmon = Color(0xFFFFA944);
  static const persimmonDeep = Color(0xFF895100);
  static const blush = Color(0xFFF2828F);

  // Night (focus mode)
  static const night = Color(0xFF3D2D27);

  // Fonts: Dela Gothic One for shouts, Yusei Magic for handwriting, Zen Maru Gothic for text.
  static TextStyle shout(double size, {Color color = ink, double height = 1.25}) =>
      GoogleFonts.delaGothicOne(fontSize: size, color: color, height: height);

  static TextStyle note(double size, {Color color = ink, double height = 1.4}) =>
      GoogleFonts.yuseiMagic(fontSize: size, color: color, height: height);

  static TextStyle body(
    double size, {
    Color color = ink,
    FontWeight weight = FontWeight.w500,
    double height = 1.5,
  }) =>
      GoogleFonts.zenMaruGothic(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
      );
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: T.vermilion,
      onPrimary: Colors.white,
      secondary: T.persimmon,
      onSecondary: T.ink,
      surface: T.paper,
      onSurface: T.ink,
    ),
    scaffoldBackgroundColor: T.paper,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: GoogleFonts.zenMaruGothic().fontFamily,
      bodyColor: T.ink,
      displayColor: T.ink,
    ),
  );
}