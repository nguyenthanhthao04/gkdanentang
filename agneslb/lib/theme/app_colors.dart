import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary Brand Colors
  static const Color primaryNavy = Color(0xFF021064);
  static const Color secondaryNavy = Color(0xFF1E2A78);
  static const Color brandDark = Color(0xFF131B2E);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF454651);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FAFC);
  static const Color surfaceTint = Color(0xFFF2F3FF);

  // Accent Tints
  static const Color lightBlue = Color(0xFFE2E7FF);
  static const Color softBlue = Color(0xFFEAEDFF);
  static const Color activeChipBg = Color(0xFF021064);

  // Borders & Dividers
  static const Color border = Color(0xFFCBD5E1);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderInput = Color(0xFFC6C5D3);

  // Danger & Status
  static const Color danger = Color(0xFFBA1A1A);
  static const Color dangerLight = Color(0xFFFFDAD6);
  static const Color dangerOverlay = Color(0x99FFDAD6);
  static const Color success = Color(0xFF006C4A);

  // Shadows
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow softElevation = BoxShadow(
    color: Color(0x140F172A),
    blurRadius: 15,
    offset: Offset(0, 4),
  );

  static const BoxShadow bottomBarShadow = BoxShadow(
    color: Color(0x14021064),
    blurRadius: 20,
    offset: Offset(0, -4),
  );
}

