import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Class quản lý toàn bộ các kiểu chữ (TextStyle) trong ứng dụng.
/// Sử dụng hệ thống Semantic Typography để đảm bảo tính đồng nhất.
class AppTextStyles {
  // Font family chính cho dự án
  static String get fontFamily => GoogleFonts.outfit().fontFamily!;

  // --- DISPLAY (Dùng cho các tiêu đề cực lớn, số liệu thống kê nổi bật) ---

  static TextStyle displayLarge = GoogleFonts.outfit(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: AppColors.textHeading,
  );

  static TextStyle displayMedium = GoogleFonts.outfit(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: AppColors.textHeading,
  );

  static TextStyle displaySmall = GoogleFonts.outfit(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.textHeading,
  );

  // --- HEADLINE (Dùng cho các tiêu đề trang, mục lớn) ---

  static TextStyle headlineLarge = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textHeading,
  );

  static TextStyle headlineMedium = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeading,
  );

  static TextStyle headlineSmall = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeading,
  );

  // --- TITLE (Dùng cho tiêu đề các card, modal, mục nhỏ) ---

  static TextStyle titleLarge = GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeading,
  );

  static TextStyle titleMedium = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.textHeading,
  );

  static TextStyle titleSmall = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textHeading,
  );

  // --- BODY (Dùng cho nội dung văn bản chính) ---

  static TextStyle bodyLarge = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textBody,
  );

  static TextStyle bodyMedium = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textBody,
  );

  static TextStyle bodySmall = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textBody,
  );

  // --- LABEL (Dùng cho nút bấm, caption, tag, nội dung phụ) ---

  static TextStyle labelLarge = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textBody,
  );

  static TextStyle labelMedium = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );

  static TextStyle labelSmall = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );

  // Các kiểu cũ để tránh lỗi compile ngay lập tức (sẽ được thay thế từng bước)
  static TextStyle get heading1 => headlineLarge;
  static TextStyle get heading2 => headlineSmall;
  static TextStyle get heading3 => titleLarge;
  static TextStyle get bodyText => bodyMedium;
  static TextStyle get subtitle => titleSmall;
  static TextStyle get label => labelMedium;
  static TextStyle get statValue => displaySmall;
  static TextStyle get buttonText => labelLarge;
}
