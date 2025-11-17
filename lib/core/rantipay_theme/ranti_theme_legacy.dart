import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ranti_colors.dart';
import 'ranti_typography.dart';
import 'design_tokens.dart';
import 'theme_config.dart';

/// Sistema de temas avanzado y dinámico para RantiPay
/// Soporta múltiples modos, esquemas de color y personalización de marca
class RantiPayTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: RantiColors.darkBackground,
    primaryColor: RantiColors.primary,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: RantiTextStyles.headlineStatic,
    ),

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: RantiColors.primary,
      secondary: RantiColors.primary,
      surface: RantiColors.darkSurface,
      error: RantiColors.error,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: RantiTextStyles.displayLargeStatic,
      headlineLarge: RantiTextStyles.headlineStatic,
      headlineMedium: RantiTextStyles.titleStatic,
      bodyLarge: RantiTextStyles.bodyStatic,
      bodyMedium: RantiTextStyles.captionStatic,
      labelSmall: RantiTextStyles.labelStatic,
    ),

    // Bottom Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: RantiColors.black,
      selectedItemColor: RantiColors.primary,
      unselectedItemColor: RantiColors.darkTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RantiColors.darkSurface, // 1A1A1A (color oscuro apropiado)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        borderSide: const BorderSide(color: RantiColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        borderSide: const BorderSide(color: RantiColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        borderSide: const BorderSide(color: RantiColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        borderSide: const BorderSide(color: RantiColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        borderSide: const BorderSide(color: RantiColors.error, width: 2),
      ),
      hintStyle: RantiTextStyles.bodyStatic.copyWith(
        color: RantiColors.darkTextTertiary,
      ),
      labelStyle: RantiTextStyles.bodyStatic.copyWith(
        color: RantiColors.darkTextSecondary,
      ),
      floatingLabelStyle: RantiTextStyles.bodyStatic.copyWith(
        color: RantiColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: RantiDesignTokens.spaceM,
        vertical: RantiDesignTokens.spaceM,
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RantiColors.primary,
        foregroundColor: RantiColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: RantiTextStyles.bodyStatic,
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: RantiColors.lightBackground,
    primaryColor: RantiColors.primary,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: RantiTextStyles.headlineStatic.copyWith(
        color: RantiColors.lightTextPrimary,
      ),
    ),

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2196F3), // Azul en lugar de negro para modo claro
      onPrimary: Colors.white,
      secondary: Color(0xFF03DAC6),
      onSecondary: Colors.black,
      surface: Colors.white, // Superficie blanca
      onSurface: Colors.black, // Texto negro sobre superficie blanca
      error: RantiColors.error,
      onError: Colors.white,
      outline: Color(0xFFE0E0E0), // Bordes claros
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: Color(0xFF666666), // Gris para iconos en modo claro
      size: 24,
    ),
    primaryIconTheme: const IconThemeData(
      color: Colors.white, // Iconos blancos sobre color primario
      size: 24,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: RantiTextStyles.displayLargeStatic.copyWith(
        color: RantiColors.lightTextPrimary,
      ),
      headlineLarge: RantiTextStyles.headlineStatic.copyWith(
        color: RantiColors.lightTextPrimary,
      ),
      headlineMedium: RantiTextStyles.titleStatic.copyWith(
        color: RantiColors.lightTextPrimary,
      ),
      bodyLarge: RantiTextStyles.bodyStatic.copyWith(
        color: RantiColors.lightTextPrimary,
      ),
      bodyMedium: RantiTextStyles.captionStatic.copyWith(
        color: RantiColors.lightTextSecondary,
      ),
      labelSmall: RantiTextStyles.labelStatic.copyWith(
        color: RantiColors.lightTextTertiary,
      ),
    ),

    // Bottom Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: RantiColors.white,
      selectedItemColor: RantiColors.primary,
      unselectedItemColor: RantiColors.lightTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8F9FA), // Color gris muy claro pero no blanco puro
      focusColor: const Color(0xFFF8F9FA), // Mismo color en focus
      hoverColor: const Color(0xFFF8F9FA), // Mismo color en hover
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        borderSide: const BorderSide(color: RantiColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
        borderSide: const BorderSide(color: RantiColors.error, width: 2),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF999999), // Gris para hints
        fontSize: 16,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF666666), // Gris más oscuro para labels
        fontSize: 16,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF2196F3), // Azul para floating label
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: RantiDesignTokens.spaceM,
        vertical: RantiDesignTokens.spaceM,
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RantiColors.primary,
        foregroundColor: RantiColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: RantiTextStyles.bodyStatic,
      ),
    ),
  );

  // =============================================
  // GENERACIÓN DINÁMICA DE TEMAS
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
        // Usar el tema del sistema
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? darkTheme : lightTheme;
      default:
        return darkTheme;
    }
  }

  /// Tema de alto contraste para accesibilidad
  static ThemeData getHighContrastTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: RantiColors.highContrastBackground,
      primaryColor: RantiColors.highContrastBorder,
      colorScheme: ColorScheme.dark(
        primary: RantiColors.highContrastBorder,
        secondary: RantiColors.highContrastBorder,
        surface: RantiColors.highContrastSurface,
        error: RantiColors.error,
        onPrimary: RantiColors.highContrastTextOnSurface,
        onSecondary: RantiColors.highContrastTextOnSurface,
        onSurface: RantiColors.highContrastTextOnSurface,
        onError: RantiColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: RantiColors.highContrastText,
          fontSize: RantiDesignTokens.fontSizeXL,
          fontWeight: RantiDesignTokens.weightBold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RantiColors.highContrastBorder,
          foregroundColor: RantiColors.highContrastTextOnSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
          ),
        ),
      ),
    );
  }

  /// Tema sepia para lectura cómoda
  static ThemeData getSepiaTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: RantiColors.sepiaBackground,
      primaryColor: RantiColors.sepiaTextSecondary,
      colorScheme: ColorScheme.light(
        primary: RantiColors.sepiaTextSecondary,
        secondary: RantiColors.sepiaTextSecondary,
        surface: RantiColors.sepiaSurface,
        error: RantiColors.error,
        onPrimary: RantiColors.sepiaBackground,
        onSecondary: RantiColors.sepiaBackground,
        onSurface: RantiColors.sepiaText,
        onError: RantiColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: RantiColors.sepiaText,
          fontSize: RantiDesignTokens.fontSizeXL,
          fontWeight: RantiDesignTokens.weightSemiBold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RantiColors.sepiaTextSecondary,
          foregroundColor: RantiColors.sepiaBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
          ),
        ),
      ),
    );
  }

  /// Tema TikTok (monocromático para contenido de video)
  static ThemeData getTikTokTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: RantiColors.tiktokBackground,
      primaryColor: RantiColors.tiktokAction,

      colorScheme: const ColorScheme.dark(
        primary: RantiColors.tiktokAction,
        secondary: RantiColors.tiktokAction,
        surface: RantiColors.tiktokSurface,
        error: RantiColors.error,
        onPrimary: RantiColors.tiktokBackground,
        onSecondary: RantiColors.tiktokBackground,
        onSurface: RantiColors.tiktokText,
        onError: RantiColors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: RantiColors.tiktokText,
          fontSize: RantiDesignTokens.fontSizeXL,
          fontWeight: RantiDesignTokens.weightMedium,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RantiColors.tiktokAction,
          foregroundColor: RantiColors.tiktokBackground,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(RantiDesignTokens.radiusCircular),
          ),
        ),
      ),

      // Ocultar elementos de navegación para inmersión completa
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  /// Tema oficial de Uber (auténtico y fiel al diseño original)
  static ThemeData getUberTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: RantiColors.uberWhite,
      primaryColor: RantiColors.uberBlack,

      // Color Scheme auténtico de Uber
      colorScheme: const ColorScheme.light(
        primary: RantiColors.uberBlack, // Negro principal
        onPrimary: RantiColors.uberWhite, // Texto en primario
        secondary: RantiColors.uberGreen, // Verde Uber para success
        onSecondary: RantiColors.uberWhite, // Texto en secundario
        tertiary: RantiColors.uberBlue, // Azul para info/links
        onTertiary: RantiColors.uberWhite, // Texto en terciario
        error: RantiColors.uberRed, // Rojo Uber para errores
        onError: RantiColors.uberWhite, // Texto en error
        surface: RantiColors.uberWhite, // Superficie principal
        onSurface: RantiColors.uberBlack, // Texto en superficie
        surfaceContainerHighest: RantiColors.uberGray100, // Superficie elevada
        onSurfaceVariant: RantiColors.uberGray600, // Texto secundario
        outline: RantiColors.uberGray300, // Bordes
        outlineVariant: RantiColors.uberGray200, // Bordes suaaves
        inverseSurface: RantiColors.uberBlack, // Superficie inversa
        onInverseSurface: RantiColors.uberWhite, // Texto en superficie inversa
        inversePrimary: RantiColors.uberWhite, // Primario inverso
        surfaceTint: Colors.transparent, // Sin tinte de elevación
      ),

      // AppBar estilo Uber (limpio y minimalista)
      appBarTheme: const AppBarTheme(
        backgroundColor: RantiColors.uberWhite,
        foregroundColor: RantiColors.uberBlack,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: RantiColors.uberGray200,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: RantiColors.uberBlack,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: RantiColors.uberBlack,
          size: 24,
        ),
      ),

      // Botones principales estilo Uber
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RantiColors.uberBlack,
          foregroundColor: RantiColors.uberWhite,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize:
              const Size(double.infinity, 56), // Altura estándar de Uber
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                8), // Bordes suaves pero no muy redondeados
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Botones outline estilo Uber
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RantiColors.uberBlack,
          backgroundColor: RantiColors.uberWhite,
          side: const BorderSide(color: RantiColors.uberGray300, width: 1),
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Botones de texto estilo Uber
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RantiColors.uberBlack,
          backgroundColor: Colors.transparent,
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Input fields estilo Uber
      inputDecorationTheme: const InputDecorationTheme(
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
          color: RantiColors.uberBlack,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: RantiColors.uberGray300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: RantiColors.uberGray300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: RantiColors.uberBlack, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: RantiColors.uberRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: RantiColors.uberRed, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Cards estilo Uber
      cardTheme: CardThemeData(
        color: RantiColors.uberWhite,
        surfaceTintColor: Colors.transparent,
        shadowColor: RantiColors.uberGray400,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.all(8),
      ),

      // List tiles estilo Uber
      listTileTheme: const ListTileThemeData(
        tileColor: RantiColors.uberWhite,
        selectedTileColor: RantiColors.uberGray100,
        iconColor: RantiColors.uberGray600,
        selectedColor: RantiColors.uberBlack,
        textColor: RantiColors.uberBlack,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: RantiColors.uberBlack,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: RantiColors.uberGray500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Dividers estilo Uber
      dividerTheme: const DividerThemeData(
        color: RantiColors.uberGray200,
        thickness: 1,
        space: 1,
      ),

      // Bottom navigation estilo Uber
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: RantiColors.uberWhite,
        selectedItemColor: RantiColors.uberBlack,
        unselectedItemColor: RantiColors.uberGray500,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Progress indicators estilo Uber
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: RantiColors.uberBlack,
        linearTrackColor: RantiColors.uberGray200,
        circularTrackColor: RantiColors.uberGray200,
      ),

      // Switch estilo Uber
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return RantiColors.uberWhite;
          }
          return RantiColors.uberGray400;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return RantiColors.uberBlack;
          }
          return RantiColors.uberGray300;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return RantiColors.uberGray200;
          }
          return Colors.transparent;
        }),
      ),

      // Checkboxes estilo Uber
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return RantiColors.uberBlack;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(RantiColors.uberWhite),
        side: const BorderSide(color: RantiColors.uberGray400, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio buttons estilo Uber
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return RantiColors.uberBlack;
          }
          return RantiColors.uberGray400;
        }),
      ),

      // FloatingActionButton estilo Uber
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: RantiColors.uberBlack,
        foregroundColor: RantiColors.uberWhite,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Snackbar estilo Uber
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: RantiColors.uberGray800,
        contentTextStyle: TextStyle(
          color: RantiColors.uberWhite,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        actionTextColor: RantiColors.uberGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        elevation: 6,
      ),

      // Dialogs estilo Uber
      dialogTheme: const DialogThemeData(
        backgroundColor: RantiColors.uberWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: RantiColors.uberGray400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        titleTextStyle: TextStyle(
          color: RantiColors.uberBlack,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: RantiColors.uberGray600,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Bottom sheets estilo Uber
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: RantiColors.uberWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        modalElevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: RantiColors.uberGray300,
        modalBarrierColor: Color(0x80000000),
      ),

      // Icon theme estilo Uber
      iconTheme: const IconThemeData(
        color: RantiColors.uberBlack,
        size: 24,
      ),

      // Text theme estilo Uber (limpio y legible)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: RantiColors.uberBlack,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: RantiColors.uberBlack,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: RantiColors.uberBlack,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: RantiColors.uberBlack,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: RantiColors.uberBlack,
          letterSpacing: -0.25,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: RantiColors.uberBlack,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: RantiColors.uberBlack,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: RantiColors.uberBlack,
          letterSpacing: 0,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: RantiColors.uberGray600,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: RantiColors.uberBlack,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: RantiColors.uberGray600,
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: RantiColors.uberGray500,
          letterSpacing: 0.25,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: RantiColors.uberBlack,
          letterSpacing: 0.25,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: RantiColors.uberGray600,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: RantiColors.uberGray500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Actualiza el tema con esquema de colores personalizado
  static ThemeData getCustomColorTheme({
    required String colorScheme,
    required String themeMode,
  }) {
    // Actualizar configuración
    RantiThemeConfig.updateColorScheme(colorScheme);
    RantiThemeConfig.updateThemeMode(themeMode);

    // Generar tema base
    final baseTheme =
        themeMode == RantiThemeConfig.light ? lightTheme : darkTheme;

    // Aplicar esquema de colores personalizado
    final customColors = RantiColors.getCurrentColorScheme();

    return baseTheme.copyWith(
      primaryColor: customColors['primary'],
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
      'spaceS': RantiDesignTokens.getResponsiveSpacing(
          context, RantiDesignTokens.spaceS),
      'spaceM': RantiDesignTokens.getResponsiveSpacing(
          context, RantiDesignTokens.spaceM),
      'spaceL': RantiDesignTokens.getResponsiveSpacing(
          context, RantiDesignTokens.spaceL),
      'fontSizeM': RantiDesignTokens.getResponsiveFontSize(
          context, RantiDesignTokens.fontSizeM),
      'fontSizeL': RantiDesignTokens.getResponsiveFontSize(
          context, RantiDesignTokens.fontSizeL),
      'iconSizeM': RantiDesignTokens.getResponsiveIconSize(
          context, RantiDesignTokens.iconSizeM),
      'radiusL': RantiDesignTokens.getResponsiveRadius(
          context, RantiDesignTokens.radiusL),
    };
  }
}

/// Extensión para facilitar el acceso a temas personalizados
extension ThemeExtension on BuildContext {
  /// Obtiene el tema actual según la configuración
  ThemeData get currentTheme => RantiPayTheme.getCurrentTheme(this);

  /// Obtiene tokens responsivos
  Map<String, double> get responsiveTokens =>
      RantiPayTheme.getResponsiveTokens(this);

  /// Verifica si está en modo TikTok
  bool get isTikTokMode =>
      RantiThemeConfig.currentThemeMode == RantiThemeConfig.tiktok;

  /// Verifica si está en modo de alto contraste
  bool get isHighContrastMode =>
      RantiThemeConfig.currentThemeMode == RantiThemeConfig.highContrast;

  /// Verifica si está en modo Uber
  bool get isUberMode =>
      RantiThemeConfig.currentThemeMode == RantiThemeConfig.uber;
}
