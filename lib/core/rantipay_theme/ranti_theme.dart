// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_tokens.dart';
import 'ranti_colors.dart';
import 'ranti_typography.dart';
import 'theme_config.dart';

/// Sistema de temas avanzado y dinámico para RantiPay V2
/// Implementa Material 3, ColorScheme.fromSeed(), ThemeExtension y mejores prácticas de Flutter 2025
/// Soluciona problemas de colores hardcodeados y inconsistencias en temas claro/oscuro
class RantiPayTheme {
  
  // =============================================
  // COLORES BASE PARA MATERIAL 3
  // =============================================
  
  /// Color primario base (negro) para generar paletas cohesivas
  static const Color _primarySeedColor = Color(0xFF000000);
  
  /// Color primario para modo claro (negro, igual que oscuro)
  static const Color _lightPrimarySeedColor = Color(0xFF000000);

  // =============================================
  // COLORES DINÁMICOS HELPER METHODS
  // =============================================
  
  /// Obtiene el color de relleno de input según el tema
  static Color _getInputFillColor(Brightness brightness) {
    switch (brightness) {
      case Brightness.dark:
        return RantiColors.darkSurface;
      case Brightness.light:
        return const Color(0xFFF8F9FA); // Gris muy claro pero no blanco puro
    }
  }

  // =============================================
  // TEMAS PRINCIPALES CON MATERIAL 3
  // =============================================

  /// Tema oscuro con Material 3 y ColorScheme.fromSeed()
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeedColor,
      brightness: Brightness.dark,
    ).copyWith(
      // Sobrescribir colores específicos para mantener la identidad de RantiPay
      primary: RantiColors.primary,
      onPrimary: RantiColors.white,
      surface: RantiColors.darkSurface,
      onSurface: RantiColors.darkTextPrimary,
      surfaceContainerHighest: RantiColors.darkSurfaceLight,
      outline: RantiColors.darkBorder,
      outlineVariant: RantiColors.darkBorderLight,
      error: RantiColors.error,
      // Usar surface container en lugar de surfaceVariant (deprecado)
      surfaceContainer: RantiColors.darkBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Removed extensions for compatibility
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: RantiTextStyles.headlineStatic.copyWith(
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Scaffold Theme
      scaffoldBackgroundColor: colorScheme.surfaceContainer,

      // Text Theme con colores dinámicos
      textTheme: TextTheme(
        displayLarge: RantiTextStyles.displayLargeStatic.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineLarge: RantiTextStyles.headlineStatic.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineMedium: RantiTextStyles.titleStatic.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyLarge: RantiTextStyles.bodyStatic.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyMedium: RantiTextStyles.captionStatic.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelSmall: RantiTextStyles.labelStatic.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Input Decoration Theme sin colores hardcodeados
      inputDecorationTheme: InputDecorationTheme(
        filled: false, // Cambiado a false para permitir fondo transparente por defecto
        fillColor: Colors.transparent, // Transparente por defecto
        border: InputBorder.none, // Sin borde por defecto para componentes personalizados
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintStyle: RantiTextStyles.bodyStatic.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: RantiTextStyles.bodyStatic.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: RantiTextStyles.bodyStatic.copyWith(
          color: colorScheme.primary,
        ),
        contentPadding: EdgeInsets.zero, // Sin padding por defecto
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
          ),
          textStyle: RantiTextStyles.bodyStatic,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: RantiDesignTokens.iconSizeL,
      ),
    );
  }

  /// Tema claro con Material 3 y ColorScheme.fromSeed()
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _lightPrimarySeedColor,
      brightness: Brightness.light,
    ).copyWith(
      // Sobrescribir colores específicos para mantener identidad RantiPay
      primary: RantiColors.primary, // Negro como marca RantiPay
      onPrimary: RantiColors.white,
      surface: Colors.white,
      onSurface: RantiColors.lightTextPrimary,
      surfaceContainerHighest: const Color(0xFFF5F5F5),
      outline: RantiColors.lightBorder,
      outlineVariant: RantiColors.lightBorderLight,
      error: RantiColors.error,
      // Usar surface en lugar de background (deprecado)
      surfaceContainer: RantiColors.lightBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Removed extensions for compatibility
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: RantiTextStyles.headlineStatic.copyWith(
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Scaffold Theme
      scaffoldBackgroundColor: colorScheme.surfaceContainer,

      // Text Theme con colores dinámicos
      textTheme: TextTheme(
        displayLarge: RantiTextStyles.displayLargeStatic.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineLarge: RantiTextStyles.headlineStatic.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineMedium: RantiTextStyles.titleStatic.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyLarge: RantiTextStyles.bodyStatic.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyMedium: RantiTextStyles.captionStatic.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelSmall: RantiTextStyles.labelStatic.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Input Decoration Theme sin colores hardcodeados
      inputDecorationTheme: InputDecorationTheme(
        filled: false, // Cambiado a false para permitir fondo transparente por defecto
        fillColor: Colors.transparent, // Transparente por defecto
        border: InputBorder.none, // Sin borde por defecto para componentes personalizados
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintStyle: RantiTextStyles.bodyStatic.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: RantiTextStyles.bodyStatic.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: RantiTextStyles.bodyStatic.copyWith(
          color: colorScheme.primary,
        ),
        contentPadding: EdgeInsets.zero, // Sin padding por defecto
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
          ),
          textStyle: RantiTextStyles.bodyStatic,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: RantiDesignTokens.iconSizeL,
      ),
    );
  }

  // =============================================
  // TEMAS ESPECIALIZADOS MEJORADOS
  // =============================================

  /// Tema de alto contraste para accesibilidad con Material 3
  static ThemeData getHighContrastTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RantiColors.highContrastBorder,
      brightness: Brightness.dark,
    ).copyWith(
      primary: RantiColors.highContrastBorder,
      onPrimary: RantiColors.highContrastTextOnSurface,
      surface: RantiColors.highContrastSurface,
      onSurface: RantiColors.highContrastTextOnSurface,
      surfaceContainer: RantiColors.highContrastBackground,
      error: RantiColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Removed extensions for compatibility
      scaffoldBackgroundColor: colorScheme.surfaceContainerHighest,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: RantiTextStyles.headlineStatic.copyWith(
          color: RantiColors.highContrastText,
          fontWeight: RantiDesignTokens.weightBold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
          ),
        ),
      ),
    );
  }

  /// Tema sepia para lectura cómoda con Material 3
  static ThemeData getSepiaTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RantiColors.sepiaTextSecondary,
      brightness: Brightness.light,
    ).copyWith(
      primary: RantiColors.sepiaTextSecondary,
      onPrimary: RantiColors.sepiaBackground,
      surface: RantiColors.sepiaSurface,
      onSurface: RantiColors.sepiaText,
      surfaceContainer: RantiColors.sepiaBackground,
      error: RantiColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Removed extensions for compatibility
      scaffoldBackgroundColor: colorScheme.surfaceContainerHighest,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: RantiTextStyles.headlineStatic.copyWith(
          color: RantiColors.sepiaText,
          fontWeight: RantiDesignTokens.weightSemiBold,
        ),
      ),
    );
  }

  /// Tema TikTok (monocromático) con Material 3
  static ThemeData getTikTokTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RantiColors.tiktokAction,
      brightness: Brightness.dark,
    ).copyWith(
      primary: RantiColors.tiktokAction,
      onPrimary: RantiColors.tiktokBackground,
      surface: RantiColors.tiktokSurface,
      onSurface: RantiColors.tiktokText,
      surfaceContainer: RantiColors.tiktokBackground,
      error: RantiColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Removed extensions for compatibility
      scaffoldBackgroundColor: colorScheme.surfaceContainerHighest,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: RantiTextStyles.headlineStatic.copyWith(
          color: RantiColors.tiktokText,
          fontWeight: RantiDesignTokens.weightMedium,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RantiDesignTokens.radiusCircular),
          ),
        ),
      ),
    );
  }

  /// Tema oficial de Uber mejorado con Material 3
  static ThemeData getUberTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RantiColors.uberBlack,
      brightness: Brightness.light,
    ).copyWith(
      primary: RantiColors.uberBlack,
      onPrimary: RantiColors.uberWhite,
      secondary: RantiColors.uberGreen,
      onSecondary: RantiColors.uberWhite,
      tertiary: RantiColors.uberBlue,
      onTertiary: RantiColors.uberWhite,
      error: RantiColors.uberRed,
      onError: RantiColors.uberWhite,
      surface: RantiColors.uberWhite,
      onSurface: RantiColors.uberBlack,
      surfaceContainerHighest: RantiColors.uberGray100,
      onSurfaceVariant: RantiColors.uberGray600,
      outline: RantiColors.uberGray300,
      outlineVariant: RantiColors.uberGray200,
      surfaceContainer: RantiColors.uberWhite,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Removed extensions for compatibility
      scaffoldBackgroundColor: colorScheme.surfaceContainerHighest,
      
      // AppBar estilo Uber
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: RantiColors.uberGray200,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
      ),

      // Inputs estilo Uber
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RantiColors.uberGray100,
        hintStyle: TextStyle(
          color: RantiColors.uberGray500,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: RantiColors.uberGray600,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Botones estilo Uber
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Cards estilo Uber
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: RantiColors.uberGray400,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  // =============================================
  // MÉTODOS PÚBLICOS (COMPATIBILIDAD)
  // =============================================

  /// Genera un tema según el modo actual configurado
  static ThemeData getCurrentTheme(BuildContext context) {
    switch (RantiThemeConfig.currentThemeMode) {
      case RantiThemeConfig.light:
        return lightTheme;
      case RantiThemeConfig.highContrast:
        return getHighContrastTheme();
      case RantiThemeConfig.sepia:
        return getSepiaTheme();
      case RantiThemeConfig.tiktok:
        return getTikTokTheme();
      case RantiThemeConfig.uber:
        return getUberTheme();
      case 'system':
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? darkTheme : lightTheme;
      default:
        return darkTheme;
    }
  }

  /// Actualiza el tema con esquema de colores personalizado
  static ThemeData getCustomColorTheme({
    required String colorScheme,
    required String themeMode,
  }) {
    RantiThemeConfig.updateColorScheme(colorScheme);
    RantiThemeConfig.updateThemeMode(themeMode);

    final baseTheme = themeMode == RantiThemeConfig.light ? lightTheme : darkTheme;
    final customColors = RantiColors.getCurrentColorScheme();

    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: customColors['primary'],
        secondary: customColors['secondary'],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customColors['primary'],
          foregroundColor: RantiColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
          ),
        ),
      ),
    );
  }

  /// Método para aplicar configuración de marca personalizada
  static void applyBrandConfiguration(Map<String, dynamic> brandConfig) {
    RantiThemeConfig.updateBrandConfig(brandConfig);
  }

  /// Obtiene tokens de diseño responsivos según el dispositivo
  static Map<String, double> getResponsiveTokens(BuildContext context) {
    return {
      'spaceS': RantiDesignTokens.getResponsiveSpacing(context, RantiDesignTokens.spaceS),
      'spaceM': RantiDesignTokens.getResponsiveSpacing(context, RantiDesignTokens.spaceM),
      'spaceL': RantiDesignTokens.getResponsiveSpacing(context, RantiDesignTokens.spaceL),
      'fontSizeM': RantiDesignTokens.getResponsiveFontSize(context, RantiDesignTokens.fontSizeM),
      'fontSizeL': RantiDesignTokens.getResponsiveFontSize(context, RantiDesignTokens.fontSizeL),
      'iconSizeM': RantiDesignTokens.getResponsiveIconSize(context, RantiDesignTokens.iconSizeM),
      'radiusL': RantiDesignTokens.getResponsiveRadius(context, RantiDesignTokens.radiusL),
    };
  }
}

/// Extensión para facilitar el acceso a temas personalizados
extension ThemeExtension on BuildContext {
  /// Obtiene el tema actual según la configuración
  ThemeData get currentTheme => RantiPayTheme.getCurrentTheme(this);

  /// Obtiene tokens responsivos
  Map<String, double> get responsiveTokens => RantiPayTheme.getResponsiveTokens(this);

  /// Verifica si está en modo TikTok
  bool get isTikTokMode => RantiThemeConfig.currentThemeMode == RantiThemeConfig.tiktok;

  /// Verifica si está en modo de alto contraste
  bool get isHighContrastMode => RantiThemeConfig.currentThemeMode == RantiThemeConfig.highContrast;

  /// Verifica si está en modo Uber
  bool get isUberMode => RantiThemeConfig.currentThemeMode == RantiThemeConfig.uber;
}