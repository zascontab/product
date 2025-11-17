import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
/// Configuración central del sistema de temas RantiPay
/// Maneja modos de tema, tokens de diseño y personalización de marca
class RantiThemeConfig {
  /// Modos de tema disponibles
  static const String light = 'light';
  static const String dark = 'dark';
  static const String highContrast = 'high_contrast';
  static const String sepia = 'sepia';
  static const String tiktok = 'tiktok';
  static const String uber = 'uber';
  
  /// Esquemas de color disponibles
  static const String blueScheme = 'blue';
  static const String greenScheme = 'green';
  static const String purpleScheme = 'purple';
  static const String customScheme = 'custom';
  
  /// Configuración actual del tema
  static String currentThemeMode = 'system'; // Seguir automáticamente el tema del sistema
  static String currentColorScheme = blueScheme;
  
  /// Configuración de marca personalizable
  static Map<String, dynamic> brandConfig = {
    'name': 'RantiPay',
    'primaryColor': '#2196F3',
    'secondaryColor': '#21CBF3',
    'logo': 'assets/images/rantipay_logo.png',
    'customTokens': <String, dynamic>{},
  };
  
  /// Breakpoints responsivos
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
  
  /// Detecta el tipo de dispositivo actual
  static String getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 'mobile';
    if (width < tabletBreakpoint) return 'tablet';
    return 'desktop';
  }
  
  /// Actualiza la configuración de tema
  static void updateThemeMode(String mode) {
    if ([light, dark, highContrast, sepia, tiktok, uber, 'system'].contains(mode)) {
      currentThemeMode = mode;
    }
  }
  
  /// Actualiza el esquema de colores
  static void updateColorScheme(String scheme) {
    if ([blueScheme, greenScheme, purpleScheme, customScheme].contains(scheme)) {
      currentColorScheme = scheme;
    }
  }
  
  /// Actualiza la configuración de marca
  static void updateBrandConfig(Map<String, dynamic> config) {
    brandConfig.addAll(config);
  }
  
  /// Obtiene tokens personalizados de la marca
  static T getBrandToken<T>(String key, T defaultValue) {
    return brandConfig['customTokens']?[key] ?? defaultValue;
  }
}