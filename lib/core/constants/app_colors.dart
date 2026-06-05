import 'package:flutter/material.dart';

class AppColors {
  // Main Background (Premium Beige/Cream)
  static const Color background = Color(0xFFFCF9F3); 
  static const Color scaffoldBg = Color(0xFFFCF9F3);
  
  // Cards & Side Navigation
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F4EC); // Muted beige for sections/inputs
  static const Color sidebarBg = Color(0xFFFFFFFF);
  
  // Primary Accent (Vibrant Mint Emerald)
  static const Color primary = Color(0xFF13B26F); 
  static const Color primaryDark = Color(0xFF0F8C58);
  static const Color primaryLight = Color(0xFF3ED88F);
  
  // Text
  static const Color textHeading = Color(0xFF2D312E); // Very dark green-tinted charcoal
  static const Color textBody = Color(0xFF4A4D4A); // Muted dark for paragraph text
  static const Color textMuted = Color(0xFF9EA39F); // Subtle gray for subtext
  static const Color textInverse = Color(0xFFFFFFFF); 
  
  // Status Dots/Bars
  static const Color statusSuccess = Color(0xFF34A853);
  static const Color statusPending = Color(0xFFFBBC04);
  static const Color statusDanger = Color(0xFFEA4335);
  
  // Dashboard Status Specifics
  static const Color statusProgressBg = Color(0xFFE8F0FE);
  static const Color statusProgressText = Color(0xFF1967D2);
  
  // Borders
  static const Color border = Color(0xFFE8E4DB); // Warm border

  // --- Glassmorphism Gradients ---
  static const Color glassGradientStartLight = Color(0xFF13B26F); // Primary Green
  static const Color glassGradientMidLight = Color(0xFF0F8C58);   // Darker Green
  static const Color glassGradientEndLight = Color(0xFF0A192F);   // Deep Blue
  
  static const Color glassGradientStartDark = Color(0xFF1A334E);  // Lighter Navy/Blue
  static const Color glassGradientMidDark = Color(0xFF0A192F);    // Deep Blue
  static const Color glassGradientEndDark = Color(0xFF050B14);    // Deepest Dark Space

  // --- Dark Mode Palette (Navy-Charcoal from Screenshot) ---
  static const Color darkBackground = Color(0xFF1A1F2E);
  static const Color darkScaffoldBg = Color(0xFF131827);
  static const Color darkCardBg = Color(0xFF1E2538);
  static const Color darkSurfaceVariant = Color(0xFF252D42);
  static const Color darkSurfacePrimary = darkSurfaceVariant;
  static const Color darkSidebarBg = Color(0xFF161B2B);
  
  static const Color darkTextHeading = Color(0xFFF0F2F5);
  static const Color darkTextBody = Color(0xFFCDD2DC);
  static const Color darkTextMuted = Color(0xFF7A8399);
  static const Color darkBorder = Color(0xFF2A3346);
}
