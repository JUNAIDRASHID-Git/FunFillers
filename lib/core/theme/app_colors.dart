import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds - Pure Crisp White
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Primary Accent - Dark Slate / Charcoal (Matching reference UI dark buttons)
  static const Color primary = Color(0xFF1E293B);
  static const Color primaryLight = Color(0xFF334155);

  // Secondary Accents
  static const Color accentPink = Color(0xFFFCE8E6);
  static const Color softPink = Color(0xFFFCE8E6);
  static const Color cardPink = Color(0xFFFCE8E6);
  static const Color accentYellow = Color(0xFFFEF3D6);
  static const Color cardYellow = Color(0xFFFEF3D6);
  static const Color accentBlue = Color(0xFFE0F2FE);
  static const Color accentPurple = Color(0xFFF3E8FF);
  static const Color accentGreen = Color(0xFFDCFCE7);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color imagePlaceholder = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status & Utility Colors
  static const Color starGold = Color(0xFFF59E0B);
  static const Color discountRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color heartRed = Color(0xFFF43F5E);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
