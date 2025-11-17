import 'package:flutter/material.dart';
import 'package:rantipay_app/core/rantipay_theme/ranti_colors.dart';

class RantiTypography {
  // Font Families (matching Shappi theme)
  static String primaryFont = 'SF Pro Text';
  static String displayFont = 'SF Pro Display';
  static String monoFont = 'SF Mono';

  // Font Sizes (matching Shappi theme)
  static const double sizeXXL = 32.0; // Display Large
  static const double sizeXL = 24.0; // Headlines
  static const double sizeL = 20.0; // Section Titles
  static const double sizeM = 16.0; // Body Text
  static const double sizeS = 14.0; // Secondary Text
  static const double sizeXS = 12.0; // Labels
  static const double sizeXXS = 11.0; // Micro Text

  // Font Weights (matching Shappi theme)
  static const FontWeight weightBlack = FontWeight.w900;
  static const FontWeight weightBold =
      FontWeight.w600; // Shappi uses w600 for bold
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightRegular = FontWeight.w400;

  // Letter Spacing (matching Shappi theme)
  static const double spacingTight = -0.5;
  static const double spacingNormal = -0.3;
  static const double spacingWide = -0.2;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.8;
}

class RantiTextStyles {
  // Dynamic Text Styles (Theme-aware with SF Pro fonts)
  static TextStyle displayLarge(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: RantiTypography.sizeXXL,
        fontWeight: RantiTypography.weightBold,
        color: RantiColors.getTextPrimary(context),
        letterSpacing: RantiTypography.spacingTight,
      );

  static TextStyle headline(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: RantiTypography.sizeXL,
        fontWeight: RantiTypography.weightBold,
        color: RantiColors.getTextPrimary(context),
        letterSpacing: RantiTypography.spacingTight,
      );

  static TextStyle title(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: RantiTypography.sizeL,
        fontWeight: RantiTypography.weightSemiBold,
        color: RantiColors.getTextPrimary(context),
        letterSpacing: RantiTypography.spacingTight,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeM,
        fontWeight: RantiTypography.weightRegular,
        color: RantiColors.getTextPrimary(context),
        letterSpacing: RantiTypography.spacingNormal,
      );

  static TextStyle bodyExtraSmall(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeM,
        fontWeight: RantiTypography.weightRegular,
        color: RantiColors.getTextPrimary(context),
        letterSpacing: RantiTypography.spacingNormal,
      );

  static TextStyle bodyMediumM(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeM,
        fontWeight: RantiTypography.weightRegular,
        color: RantiColors.getTextPrimary(context),
        letterSpacing: RantiTypography.spacingNormal,
      );

  static TextStyle bodySmallS(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeS,
        fontWeight: RantiTypography.weightRegular,
        color: RantiColors.getTextPrimary(context),
        letterSpacing: RantiTypography.spacingWide,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeS,
        fontWeight: RantiTypography.weightRegular,
        color: RantiColors.getTextSecondary(context),
        letterSpacing: RantiTypography.spacingWide,
      );

  static TextStyle label(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeXS,
        fontWeight: RantiTypography.weightMedium,
        color: RantiColors.getTextPrimary(context),
        letterSpacing: RantiTypography.spacingWide,
      );

  static TextStyle micro(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeXXS,
        fontWeight: RantiTypography.weightMedium,
        color: RantiColors.getTextSecondary(context),
        letterSpacing: RantiTypography.spacingWide,
      );

  // Special Styles
  static TextStyle price(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: RantiTypography.sizeXL,
        fontWeight: RantiTypography.weightBold,
        color: RantiColors.getTextPrimary(context),
        letterSpacing: RantiTypography.spacingTight,
      );

  static TextStyle button(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeM,
        fontWeight: RantiTypography.weightMedium,
        color: RantiColors.white,
        letterSpacing: RantiTypography.spacingWide,
      );

  // Static styles for backward compatibility (default to dark theme)
  static TextStyle get displayLargeStatic => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: RantiTypography.sizeXXL,
        fontWeight: RantiTypography.weightBold,
        color: RantiColors.textPrimary,
        letterSpacing: RantiTypography.spacingTight,
      );

  static TextStyle get headlineStatic => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: RantiTypography.sizeXL,
        fontWeight: RantiTypography.weightBold,
        color: RantiColors.textPrimary,
        letterSpacing: RantiTypography.spacingTight,
      );

  // Modern styles for new dashboard
  static TextStyle get h1 => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: 32.0,
        fontWeight: RantiTypography.weightBold,
        letterSpacing: RantiTypography.spacingTight,
      );

  static TextStyle get h2 => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: 24.0,
        fontWeight: RantiTypography.weightBold,
        letterSpacing: RantiTypography.spacingTight,
      );

  static TextStyle get h3 => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: 20.0,
        fontWeight: RantiTypography.weightSemiBold,
        letterSpacing: RantiTypography.spacingNormal,
      );

  static TextStyle get h4 => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: 18.0,
        fontWeight: RantiTypography.weightSemiBold,
        letterSpacing: RantiTypography.spacingNormal,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: 18.0,
        fontWeight: RantiTypography.weightRegular,
        letterSpacing: RantiTypography.spacingNormal,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: 16.0,
        fontWeight: RantiTypography.weightRegular,
        letterSpacing: RantiTypography.spacingNormal,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: 14.0,
        fontWeight: RantiTypography.weightRegular,
        letterSpacing: RantiTypography.spacingWide,
      );

  static TextStyle get labelLarge => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: 14.0,
        fontWeight: RantiTypography.weightMedium,
        letterSpacing: RantiTypography.spacingWide,
      );

  static TextStyle get titleStatic => TextStyle(
        fontFamily: RantiTypography.displayFont,
        fontSize: RantiTypography.sizeL,
        fontWeight: RantiTypography.weightSemiBold,
        color: RantiColors.textPrimary,
        letterSpacing: RantiTypography.spacingTight,
      );

  static TextStyle get bodyStatic => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeM,
        fontWeight: RantiTypography.weightRegular,
        color: RantiColors.textPrimary,
        letterSpacing: RantiTypography.spacingNormal,
      );

  static TextStyle get captionStatic => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeS,
        fontWeight: RantiTypography.weightRegular,
        color: RantiColors.textSecondary,
        letterSpacing: RantiTypography.spacingWide,
      );

  static TextStyle get labelStatic => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeXS,
        fontWeight: RantiTypography.weightMedium,
        color: RantiColors.textTertiary,
        letterSpacing: RantiTypography.spacingWide,
      );

  // subtitle - Between title and body, for section headers
  static TextStyle subtitle(BuildContext context) => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeM +
            2, // 18px, between title (20px) and body (16px)
        fontWeight: RantiTypography.weightSemiBold,
        color: RantiColors.getTextPrimary(context),
        letterSpacing: RantiTypography.spacingNormal,
        height: RantiTypography.lineHeightNormal,
      );

  // Static subtitle for backward compatibility
  static TextStyle get subtitleStatic => TextStyle(
        fontFamily: RantiTypography.primaryFont,
        fontSize: RantiTypography.sizeM + 2, // 18px
        fontWeight: RantiTypography.weightSemiBold,
        color: RantiColors.textPrimary,
        letterSpacing: RantiTypography.spacingNormal,
        height: RantiTypography.lineHeightNormal,
      );
}
