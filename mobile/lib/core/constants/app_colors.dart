import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Accent
  static const Color accent = Color(0xFFF472B6); // Pink

  // Backgrounds & Surfaces (OLED dark)
  static const Color background = Color(0xFF0F0F14);
  static const Color surface = Color(0xFF1A1A24);
  static const Color surfaceLight = Color(0xFF252532);
  static const Color surfaceElevated = Color(0xFF2E2E3E);

  // Typography
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // Status indicators
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Platform branding
  static const Color youtube = Color(0xFFFF0000);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color instagram = Color(0xFFE4405F);
  static const Color spotify = Color(0xFF1DB954);
  static const Color reddit = Color(0xFFFF4500);
  static const Color github = Color(0xFFE6EDF3);
  static const Color webpage = Color(0xFF6366F1);

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
        return info;
      case 'pending':
        return warning;
      case 'failed':
        return error;
      default:
        return textMuted;
    }
  }
}

