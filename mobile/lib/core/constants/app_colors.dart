import 'package:flutter/material.dart';

class AppColors {
  // Primary cognitive palette
  static const Color primary = Color(0xFF6366F1); // Indigo-Violet
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Cognitive accents
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFF22D3EE);
  static const Color rose = Color(0xFFEC4899);
  static const Color violet = Color(0xFFA855F7);

  // Backgrounds & Surfaces (Obsidian OLED)
  static const Color background = Color(0xFF090C15);
  static const Color surface = Color(0xFF111625);
  static const Color surfaceLight = Color(0xFF1B2338);
  static const Color surfaceElevated = Color(0xFF242E47);
  static const Color border = Color(0xFF263352);

  // Typography
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Status indicators
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Platform branding
  static const Color youtube = Color(0xFFFF3333);
  static const Color twitter = Color(0xFF38BDF8);
  static const Color instagram = Color(0xFFE4405F);
  static const Color spotify = Color(0xFF10B981);
  static const Color reddit = Color(0xFFFF5722);
  static const Color github = Color(0xFFE2E8F0);
  static const Color webpage = Color(0xFF6366F1);

  // Cognitive Gradients
  static const LinearGradient aiSynthesisGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x336366F1),
      Color(0x1A06B6D4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardBorderGradient = LinearGradient(
    colors: [
      Color(0x4D818CF8),
      Color(0x1A22D3EE),
      Color(0x0DFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return youtube;
      case 'twitter':
      case 'x':
        return twitter;
      case 'instagram':
        return instagram;
      case 'spotify':
        return spotify;
      case 'reddit':
        return reddit;
      case 'github':
        return github;
      default:
        return webpage;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return success;
      case 'processing':
        return cyan;
      case 'pending':
        return warning;
      case 'failed':
        return error;
      default:
        return textMuted;
    }
  }
}
