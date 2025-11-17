import 'package:flutter/material.dart';
import 'theme_config.dart';

/// Design Tokens centralizados para RantiPay
/// Basado en el análisis del home.svg y buenas prácticas de diseño
class RantiDesignTokens {
  // =============================================
  // SISTEMA DE ESPACIADO (BASE 8px)
  // =============================================

  /// Unidad base de espaciado
  static const double baseUnit = 8.0;

  /// Espaciados estándar
  static const double spaceXS = baseUnit * 0.5; // 4px
  static const double spaceS = baseUnit * 1; // 8px
  static const double spaceM = baseUnit * 2; // 16px
  static const double spaceL = baseUnit * 3; // 24px
  static const double spaceXL = baseUnit * 4; // 32px
  static const double spaceXXL = baseUnit * 6; // 48px

  static const double borderWidthThin = 1.0;

  /// Espaciados responsivos dinámicos
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final deviceType = RantiThemeConfig.getDeviceType(context);
    switch (deviceType) {
      case 'mobile':
        return baseSpacing;
      case 'tablet':
        return baseSpacing * 1.2;
      case 'desktop':
        return baseSpacing * 1.4;
      default:
        return baseSpacing;
    }
  }

  // =============================================
  // SISTEMA DE BORDES Y RADIOS
  // =============================================

  /// Radios de borde estándar
  static const double radiusNone = 0.0;
  static const double radiusXS = 2.0;
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 999.0;

  /// Borderradius responsivo
  static double getResponsiveRadius(BuildContext context, double baseRadius) {
    final deviceType = RantiThemeConfig.getDeviceType(context);
    switch (deviceType) {
      case 'mobile':
        return baseRadius;
      case 'tablet':
        return baseRadius * 1.1;
      case 'desktop':
        return baseRadius * 1.2;
      default:
        return baseRadius;
    }
  }

  // =============================================
  // SISTEMA DE SOMBRAS Y ELEVACIÓN
  // =============================================

  /// Niveles de elevación
  static const List<BoxShadow> elevationNone = [];

  static const List<BoxShadow> elevationXS = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevationS = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevationM = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevationL = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevationXL = [
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 16),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Sombra para modo TikTok (negro intenso)
  static const List<BoxShadow> tiktokShadow = [
    BoxShadow(
      color: Color(0x80000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // =============================================
  // SISTEMA TIPOGRÁFICO
  // =============================================

  /// Escalas de tamaño de fuente
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;
  static const double fontSizeDisplay = 32.0;
  static const double fontSizeHero = 48.0;

  /// Pesos de fuente
  static const FontWeight weightThin = FontWeight.w100;
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;
  static const FontWeight weightBlack = FontWeight.w900;

  /// Altura de línea proporcional
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;

  /// Tamaño de fuente responsivo
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    final deviceType = RantiThemeConfig.getDeviceType(context);
    switch (deviceType) {
      case 'mobile':
        return baseFontSize;
      case 'tablet':
        return baseFontSize * 1.1;
      case 'desktop':
        return baseFontSize * 1.2;
      default:
        return baseFontSize;
    }
  }

  // =============================================
  // SISTEMA DE ICONOS
  // =============================================

  /// Tamaños de iconos estándar
  static const double iconSizeXS = 12.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 48.0;
  static const double iconSizeHero = 64.0;

  /// Tamaño de icono responsivo
  static double getResponsiveIconSize(
      BuildContext context, double baseIconSize) {
    final deviceType = RantiThemeConfig.getDeviceType(context);
    switch (deviceType) {
      case 'mobile':
        return baseIconSize;
      case 'tablet':
        return baseIconSize * 1.15;
      case 'desktop':
        return baseIconSize * 1.25;
      default:
        return baseIconSize;
    }
  }

  // =============================================
  // ANIMACIONES Y TRANSICIONES
  // =============================================

  /// Duraciones de animación
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationSlower = Duration(milliseconds: 600);
  static const Duration durationSlowest = Duration(milliseconds: 800);

  /// Curvas de animación
  static const Curve curveFastOut = Curves.fastOutSlowIn;
  static const Curve curveEase = Curves.ease;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveTiktok = Curves.easeOutCubic;

  // =============================================
  // LAYOUT Y CONTENEDORES
  // =============================================

  /// Anchos máximos de contenido
  static const double maxWidthMobile = 480.0;
  static const double maxWidthTablet = 768.0;
  static const double maxWidthDesktop = 1200.0;
  static const double maxWidthWide = 1440.0;

  /// Obtiene el ancho máximo para el dispositivo actual
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = RantiThemeConfig.getDeviceType(context);
    switch (deviceType) {
      case 'mobile':
        return maxWidthMobile;
      case 'tablet':
        return maxWidthTablet;
      case 'desktop':
        return maxWidthDesktop;
      default:
        return maxWidthWide;
    }
  }

  // =============================================
  // CONFIGURACIÓN ESPECÍFICA TIKTOK
  // =============================================

  /// Aspectos de video TikTok
  static const double tiktokAspectRatio = 9.0 / 16.0;
  static const double tiktokControlsOpacity = 0.8;
  static const double tiktokOverlayOpacity = 0.6;

  /// Posicionamiento de controles TikTok
  static const EdgeInsets tiktokControlsPadding = EdgeInsets.symmetric(
    horizontal: spaceM,
    vertical: spaceL,
  );

  /// Tamaños específicos para TikTok
  static const double tiktokActionButtonSize = 48.0;
  static const double tiktokProfileSize = 52.0;
  static const double tiktokLikeIconSize = 32.0;
}
