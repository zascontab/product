// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'theme_config.dart';

/// Sistema de colores dinámico y escalable para RantiPay
/// Soporta múltiples esquemas de color, modos de tema y personalización de marca
class RantiColors {
  // Base Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Accent Colors (Consistent across themes)
  static const Color primary = Color(0xFF000000); // Negro
  static const Color primaryDark = Color(0xFF000000); // Negro
  static const Color primaryLight = Color(0xFFFFFFFF); // Blanco

  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF1744);
  static const Color warning = Color(0xFFFFD700);
  static const Color info = Color(0xFF2196F3);
  static const Color danger = Color(0xFFFF1744);
  static const Color gray = Color(0xFF9E9E9E);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceLight = Color(0xFF2A2A2A);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkBorderLight = Color(0xFF555555);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF999999);
  static const Color darkTextTertiary = Color(0xFF666666);

  // Light Theme Colors
  static const Color lightBackground =
      Color(0xF1F1F1F1); // Color agradable para modo claro (era F5F5F5)
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightBorderLight = Color(0xFFBDBDBD);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextTertiary = Color(0xFF999999);

  // Shimmer & Loading Colors (Uber-style) - Usamos F1F1F1 para ambos modos
  static const Color shimmerBase = Color(0xFFF1F1F1);
  static const Color shimmerHighlight = Color(0xFFE0E0E0);
  static const Color darkShimmerBase = Color(0xFFF1F1F1);
  static const Color darkShimmerHighlight = Color(0xFFE0E0E0);

  static const Color cardLight = Color(0xFFF4F1EA);
  static const Color cardDark = Color(0xFF2A2A2A);

  // Dynamic Colors (Changes based on theme)
  /// Obtiene color de fondo basado en el modo de tema actual
  static Color getBackground(BuildContext context) {
    switch (RantiThemeConfig.currentThemeMode) {
      case RantiThemeConfig.tiktok:
        return tiktokBackground;
      case RantiThemeConfig.highContrast:
        return highContrastBackground;
      case RantiThemeConfig.sepia:
        return sepiaBackground;
      case RantiThemeConfig.uber:
        return uberWhite; // Fondo blanco limpio de Uber
      case RantiThemeConfig.light:
        return lightBackground;
      case 'system':
        // Detectar tema del sistema automáticamente
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? darkBackground : lightBackground;
      default:
        return darkBackground;
    }
  }

  /// Obtiene color de superficie basado en el modo de tema actual
  static Color getSurface(BuildContext context) {
    switch (RantiThemeConfig.currentThemeMode) {
      case RantiThemeConfig.tiktok:
        return tiktokSurface;
      case RantiThemeConfig.highContrast:
        return highContrastSurface;
      case RantiThemeConfig.sepia:
        return sepiaSurface;
      case RantiThemeConfig.uber:
        return uberGray100; // Superficie sutil de Uber (F6F6F6)
      case RantiThemeConfig.light:
        return lightSurface;
      case 'system':
        // Detectar tema del sistema automáticamente
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? darkSurface : lightSurface;
      default:
        return darkSurface;
    }
  }

  static Color getSurfaceLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceLight
        : lightSurfaceLight;
  }

  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }

  static Color getBorderLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderLight
        : lightBorderLight;
  }

  /// Obtiene color de texto primario basado en el modo de tema actual
  static Color getTextPrimary(BuildContext context) {
    switch (RantiThemeConfig.currentThemeMode) {
      case RantiThemeConfig.tiktok:
        return tiktokText;
      case RantiThemeConfig.highContrast:
        return highContrastText;
      case RantiThemeConfig.sepia:
        return sepiaText;
      case RantiThemeConfig.uber:
        return uberBlack; // Negro puro de Uber para texto principal
      case RantiThemeConfig.light:
        return lightTextPrimary;
      case 'system':
        // Detectar tema del sistema automáticamente
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark
            ? darkTextPrimary
            : lightTextPrimary;
      default:
        return darkTextPrimary;
    }
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  static Color getTextTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextTertiary
        : lightTextTertiary;
  }

  // get icon color for dark mode or light mode
  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  // get text on surface color for dark mode or light mode
  static Color getTextOnSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextTertiary
        : lightTextTertiary;
  }

  // get text on primary color (always white for good contrast)
  static Color getTextOnPrimary(BuildContext context) {
    return white; // Always white for contrast on primary color
  }

  static Color getSuccess(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? success : success;
  }

  static Color getWarning(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? warning : warning;
  }

  static Color getInfo(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? info : info;
  }

  /// Obtiene el color de fondo para inputs de forma dinámica
  static Color getInputFillColor(BuildContext context) {
    switch (RantiThemeConfig.currentThemeMode) {
      case RantiThemeConfig.tiktok:
        return tiktokSurface;
      case RantiThemeConfig.highContrast:
        return highContrastSurface;
      case RantiThemeConfig.sepia:
        return sepiaSurface;
      case RantiThemeConfig.uber:
        return uberGray100; // Color suave de Uber para inputs
      case RantiThemeConfig.light:
        return lightSurface; // F1F1F1 - color claro y agradable
      case 'system':
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? darkSurface : lightSurface;
      default:
        return darkSurface;
    }
  }

  // Dynamic Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static LinearGradient getSurfaceGradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [getSurface(context), getSurfaceLight(context)],
    );
  }

  static Color getOnSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextTertiary
        : lightTextTertiary;
  }

  static Color getDisabled(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderLight
        : lightBorderLight;
  }

  /// Obtiene color primario del esquema actual
  static Color getPrimary(BuildContext context) {
    switch (RantiThemeConfig.currentThemeMode) {
      case RantiThemeConfig.tiktok:
        return tiktokAction;
      case RantiThemeConfig.highContrast:
        return highContrastBorder; // Amarillo brillante para alto contraste
      case RantiThemeConfig.sepia:
        return sepiaTextSecondary; // Color sepia
      case RantiThemeConfig.uber:
        return uberBlack; // Negro de Uber para elementos principales
      case RantiThemeConfig.light:
        // En modo claro, usar negro para mantener consistencia
        return lightTextPrimary;
      case 'system':
        // Detectar tema del sistema automáticamente
        final brightness = MediaQuery.of(context).platformBrightness;
        if (brightness == Brightness.dark) {
          return getTextPrimary(context); // En modo oscuro, blanco
        } else {
          // En modo claro, usar negro para mantener consistencia
          return lightTextPrimary;
        }
      default:
        return getTextPrimary(context); // Modo oscuro por defecto
    }
  }

  static Color getGrey(BuildContext context) {
    return getTextSecondary(context);
  }

  /// Obtiene color primario oscuro del esquema actual
  static Color getPrimaryDark(BuildContext context) {
    final scheme = getCurrentColorScheme();
    return scheme['primaryDark'] ?? primaryDark;
  }

  /// Obtiene color primario claro del esquema actual
  static Color getPrimaryLight(BuildContext context) {
    final scheme = getCurrentColorScheme();
    return scheme['primaryLight'] ?? primaryLight;
  }

  /// Obtiene color secundario del esquema actual
  static Color getSecondary(BuildContext context) {
    final scheme = getCurrentColorScheme();
    return scheme['secondary'] ?? primary;
  }

  /// Obtiene color de acento del esquema actual
  static Color getAccent(BuildContext context) {
    final scheme = getCurrentColorScheme();
    return scheme['accent'] ?? primaryLight;
  }

  static Color getError(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? error : error;
  }

  /// Obtiene color base de shimmer (Uber-style)
  static Color getShimmerBase(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkShimmerBase
        : shimmerBase;
  }

  /// Obtiene color highlight de shimmer (Uber-style)
  static Color getShimmerHighlight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkShimmerHighlight
        : shimmerHighlight;
  }

  /// Obtiene color highlight de shimmer (Uber-style)
  static Color getCard(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardDark
        : highContrastSurface;
  }

  /// Obtiene color de overlay para promociones (dinámico)
  static Color getPromotionOverlay(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary.withValues(alpha: 0.7)
        : lightTextPrimary.withValues(alpha: 0.6);
  }

  /// Obtiene color para badges de promoción (dinámico según esquema)
  static Color getPromotionBadge(BuildContext context) {
    final scheme = getCurrentColorScheme();
    return scheme['accent'] ??
        success; // Usa accent del esquema o verde por defecto
  }

  /// Obtiene color de texto para promociones (siempre contraste)
  static Color getPromotionText(BuildContext context) {
    return white; // Siempre blanco para contraste sobre overlay oscuro
  }

  // =============================================
  // ESQUEMAS DE COLOR MÚLTIPLES
  // =============================================

  /// Colores del esquema azul (predeterminado)
  static const Map<String, Color> blueScheme = {
    'primary': Color(0xFF2196F3),
    'primaryDark': Color(0xFF1976D2),
    'primaryLight': Color(0xFF21CBF3),
    'secondary': Color(0xFF03DAC6),
    'accent': Color(0xFF64B5F6),
  };

  /// Colores del esquema verde
  static const Map<String, Color> greenScheme = {
    'primary': Color(0xFF4CAF50),
    'primaryDark': Color(0xFF388E3C),
    'primaryLight': Color(0xFF81C784),
    'secondary': Color(0xFF8BC34A),
    'accent': Color(0xFFCDDC39),
  };

  /// Colores del esquema púrpura
  static const Map<String, Color> purpleScheme = {
    'primary': Color(0xFF9C27B0),
    'primaryDark': Color(0xFF7B1FA2),
    'primaryLight': Color(0xFFBA68C8),
    'secondary': Color(0xFF673AB7),
    'accent': Color(0xFFE1BEE7),
  };

  /// Obtiene el esquema de colores actual
  static Map<String, Color> getCurrentColorScheme() {
    switch (RantiThemeConfig.currentColorScheme) {
      case RantiThemeConfig.greenScheme:
        return greenScheme;
      case RantiThemeConfig.purpleScheme:
        return purpleScheme;
      case RantiThemeConfig.customScheme:
        return _getCustomColorScheme();
      default:
        return blueScheme;
    }
  }

  /// Obtiene esquema personalizado de la configuración de marca
  static Map<String, Color> _getCustomColorScheme() {
    final brandConfig = RantiThemeConfig.brandConfig;
    return {
      'primary': _colorFromHex(brandConfig['primaryColor'] ?? '#2196F3'),
      'primaryDark': _darkenColor(
          _colorFromHex(brandConfig['primaryColor'] ?? '#2196F3'), 0.2),
      'primaryLight': _lightenColor(
          _colorFromHex(brandConfig['primaryColor'] ?? '#2196F3'), 0.2),
      'secondary': _colorFromHex(brandConfig['secondaryColor'] ?? '#21CBF3'),
      'accent': _lightenColor(
          _colorFromHex(brandConfig['primaryColor'] ?? '#2196F3'), 0.4),
    };
  }

  /// Convierte string hex a Color
  static Color _colorFromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  /// Oscurece un color
  static Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Aclara un color
  static Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  // =============================================
  // COLORES MODO TIKTOK (MONOCROMÁTICO)
  // =============================================

  /// Colores específicos para modo TikTok
  static const Color tiktokBackground = Color(0xFF000000);
  static const Color tiktokSurface = Color(0xFF1A1A1A);
  static const Color tiktokText = Color(0xFFFFFFFF);
  static const Color tiktokTextSecondary = Color(0xFF808080);
  static const Color tiktokOverlay = Color(0x80000000);
  static const Color tiktokAction = Color(0xFFFFFFFF);

  // =============================================
  // COLORES MODO ALTO CONTRASTE
  // =============================================

  /// Colores para modo de alto contraste (accesibilidad)
  static const Color highContrastBackground = Color(0xFF000000);
  static const Color highContrastSurface = Color(0xFFFFFFFF);
  static const Color highContrastText = Color(0xFFFFFFFF);
  static const Color highContrastTextOnSurface = Color(0xFF000000);
  static const Color highContrastBorder =
      Color(0xFFFFFF00); // Amarillo brillante

  // =============================================
  // COLORES MODO SEPIA
  // =============================================

  /// Colores para modo sepia (lectura cómoda)
  static const Color sepiaBackground = Color(0xFFF4F1EA);
  static const Color sepiaSurface = Color(0xFFEDE6D3);
  static const Color sepiaText = Color(0xFF3E3529);
  static const Color sepiaTextSecondary = Color(0xFF6B5E47);
  static const Color sepiaBorder = Color(0xFFD4C4A8);

  // =============================================
  // COLORES TEMA UBER (AUTÉNTICO)
  // =============================================

  /// Colores oficiales de Uber para tema auténtico
  static const Color uberBlack = Color(0xFF000000); // Negro principal de Uber
  static const Color uberWhite = Color(0xFFFFFFFF); // Blanco puro
  static const Color uberGray100 = Color(0xFFF6F6F6); // Fondo muy claro
  static const Color uberGray200 = Color(0xFFEEEEEE); // Separadores
  static const Color uberGray300 = Color(0xFFE2E2E2); // Bordes suaves
  static const Color uberGray400 = Color(0xFFC4C4C4); // Iconos inactivos
  static const Color uberGray500 = Color(0xFF8A8A8A); // Texto secundario
  static const Color uberGray600 = Color(0xFF545454); // Texto terciario
  static const Color uberGray700 = Color(0xFF3D3D3D); // Superficie oscura
  static const Color uberGray800 = Color(0xFF2E2E2E); // Fondo modal
  static const Color uberGray900 = Color(0xFF1D1D1D); // Fondo muy oscuro

  // Colores de acción oficiales de Uber
  static const Color uberBlue = Color(0xFF1A73E8); // Azul Uber (enlaces, info)
  static const Color uberGreen =
      Color(0xFF06C270); // Verde Uber (disponible, éxito)
  static const Color uberRed =
      Color(0xFFEA4335); // Rojo Uber (errores, urgente)
  static const Color uberYellow =
      Color(0xFFFBBC04); // Amarillo Uber (advertencias)
  static const Color uberOrange = Color(0xFFFF9F43); // Naranja Uber (neutral)

  // Colores específicos de funcionalidad
  static const Color uberMapGreen = Color(0xFF00D688); // Pin de destino en mapa
  static const Color uberRating = Color(0xFFFFB000); // Estrellas de rating
  static const Color uberPromo = Color(0xFF9C27B0); // Promociones y descuentos
  static const Color uberPremium = Color(0xFF6200EA); // Uber Black/Premium

  // =============================================
  // VALORES DE OPACIDAD
  // =============================================

  static const double opacity10 = 0.1;
  static const double opacity20 = 0.2;
  static const double opacity30 = 0.3;
  static const double opacity40 = 0.4;
  static const double opacity50 = 0.5;
  static const double opacity60 = 0.6;
  static const double opacity70 = 0.7;
  static const double opacity80 = 0.8;
  static const double opacity90 = 0.9;

  // Static accessors for backward compatibility (default to dark)
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color surfaceLight = darkSurfaceLight;
  static const Color border = darkBorder;
  static const Color borderLight = darkBorderLight;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textTertiary = darkTextTertiary;

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, surfaceLight],
  );
}
