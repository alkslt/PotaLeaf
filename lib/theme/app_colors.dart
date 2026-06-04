import 'package:flutter/material.dart';

/// PotaLeaf design system — High-fidelity dark glassmorphism color tokens.
class AppColors {
  AppColors._();

  // ── Premium Gradient ──
  static const List<Color> buttonGradient = [
    Color(0xFFDFF8B9),
    Color(0xFFBBF06A),
  ];

  // ── Primary Greens ──
  static const Color limeAccent = Color(0xFFC7F000);
  static const Color oliveGold = Color(0xFFD5DC69);
  static const Color forestGreen = Color(0xFF51A612);
  static const Color leafGreen = Color(0xFF7DB150);
  static const Color darkGreen = Color(0xFF4F7C24);
  static const Color deepForest = Color(0xFF425423);
  static const Color mutedOlive = Color(0xFF597238);

  // ── Supplementary Greens ──
  static const Color brightLime = Color(0xFF89F066);
  static const Color mintGreen = Color(0xFFC2F0CF);

  // ── Neutrals (Dark Theme) ──
  static const Color charcoal = Color(0xFF0F120D);
  static const Color darkGray = Color(0xFF161C13);
  static const Color mediumGray = Color(0xFF7A8C74);
  static const Color gray = Color(0xFF55604F);
  static const Color lightGray = Color(0x2B86A46A); // Translucent green border
  static const Color offWhite = Color(0xFF070B05);   // Immersive dark background base
  static const Color white = Color(0xFFFFFFFF);

  // ── Semantic ──
  static const Color background = offWhite;
  static const Color surface = Color(0x1F2A381F);     // Frosted glass panel fill
  static const Color onDark = white;
  static const Color textPrimary = white;
  static const Color textSecondary = Color(0xFFA2B399); // Soft leaf gray
  static const Color textHint = Color(0xFF5A6655);
  static const Color divider = Color(0x1A86A46A);

  // ── Disease type badges (Enhanced for Dark Theme) ──
  static const Color virusBadge = Color(0xFFFF6B6B);
  static const Color pestBadge = Color(0xFFFFB03A);
  static const Color healthyBadge = Color(0xFF66BB6A);
  static const Color fungiBadge = Color(0xFFAB47BC);
  static const Color bacteriaBadge = Color(0xFF26C6DA); // Teal-cyan for Bacteria
  static const Color nematodeBadge = Color(0xFFFF7043); // Orange-red for Nematode
  static const Color phytophthoraBadge = Color(0xFF5C6BC0); // Indigo-blue for Phytophthora
}
