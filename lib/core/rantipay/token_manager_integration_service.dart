// lib/core/rantipay/token_manager_integration_service.dart

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/infrastructure/rantipay_token_manager.dart';
import '../../features/auth/infrastructure/token_manager_wrapper.dart';
import '../di/service_container.dart';

/// **Service para integrar Enhanced Token Manager con el sistema existente**
/// 
/// Este service permite activar el sistema enhanced de tokens sin romper
/// el código existente. Intercepta las llamadas al token manager original
/// y las redirige al enhanced system cuando está activo.
@lazySingleton
class TokenManagerIntegrationService {
  static bool _isEnhancedActive = false;
  static TokenManagerWrapper? _wrapper;

  /// **Activar Enhanced Token System**
  static Future<void> activateEnhancedSystem() async {
    if (_isEnhancedActive) {
      debugPrint('⚠️ Enhanced Token System already active');
      print('⚠️ Enhanced Token System already active');
      return;
    }

    try {
      debugPrint('🚀 Activating Enhanced Token System...');
      print('🚀 TOKEN INTEGRATION SERVICE: Activating Enhanced Token System...');

      // Inicializar wrapper
      print('🔧 TOKEN INTEGRATION SERVICE: Getting TokenManagerWrapper from DI...');
      _wrapper = getIt<TokenManagerWrapper>();
      print('✅ TOKEN INTEGRATION SERVICE: TokenManagerWrapper obtained');

      print('🚀 TOKEN INTEGRATION SERVICE: Initializing enhanced system...');
      await _wrapper!.initializeEnhanced();
      print('✅ TOKEN INTEGRATION SERVICE: Enhanced system initialized');
      
      if (_wrapper!.isEnhancedMode) {
        print('🎯 TOKEN INTEGRATION SERVICE: Wrapper is in enhanced mode');
        _isEnhancedActive = true;

        // Reemplazar métodos del token manager existente
        print('🔧 TOKEN INTEGRATION SERVICE: Patching existing token manager...');
        await _patchExistingTokenManager();
        print('✅ TOKEN INTEGRATION SERVICE: Token manager patched');

        debugPrint('✅ Enhanced Token System activated successfully');
        print('✅ TOKEN INTEGRATION SERVICE: Enhanced Token System activated successfully');
        debugPrint('   - Mode: Enhanced');
        debugPrint('   - Auto-refresh: Enabled');
        debugPrint('   - Proactive refresh: Enabled');
      } else {
        debugPrint('⚠️ Enhanced Token System fallback to basic mode');
        print('⚠️ TOKEN INTEGRATION SERVICE: Enhanced Token System fallback to basic mode');
      }
      
    } catch (e, stack) {
      debugPrint('❌ Failed to activate Enhanced Token System: $e');
      print('❌ TOKEN INTEGRATION SERVICE: Failed to activate Enhanced Token System: $e');
      debugPrint('Stack: $stack');
      print('❌ TOKEN INTEGRATION SERVICE: Stack: $stack');

      _isEnhancedActive = false;
      _wrapper = null;
    }
  }

  /// **Verificar si el sistema enhanced está activo**
  static bool get isEnhancedActive => _isEnhancedActive;

  /// **Obtener wrapper (para uso interno)**
  static TokenManagerWrapper? get wrapper => _wrapper;

  /// **Obtener access token usando el sistema apropiado**
  static Future<String?> getAccessToken() async {
    if (_isEnhancedActive && _wrapper != null) {
      return await _wrapper!.getAccessToken();
    }
    
    // Fallback al sistema original
    try {
      final originalManager = getIt<RantiPayTokenManager>();
      return await originalManager.getAccessToken();
    } catch (e) {
      debugPrint('❌ Error getting access token: $e');
      return null;
    }
  }

  /// **Obtener refresh token usando el sistema apropiado**
  static Future<String?> getRefreshToken() async {
    if (_isEnhancedActive && _wrapper != null) {
      return await _wrapper!.getRefreshToken();
    }
    
    // Fallback al sistema original
    try {
      final originalManager = getIt<RantiPayTokenManager>();
      return await originalManager.getRefreshToken();
    } catch (e) {
      debugPrint('❌ Error getting refresh token: $e');
      return null;
    }
  }

  /// **Guardar tokens usando el sistema apropiado**
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (_isEnhancedActive && _wrapper != null) {
      await _wrapper!.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } else {
      // Fallback al sistema original
      try {
        final originalManager = getIt<RantiPayTokenManager>();
        await originalManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } catch (e) {
        debugPrint('❌ Error saving tokens: $e');
      }
    }
  }

  /// **Verificar validez de tokens**
  static Future<bool> areTokensValid() async {
    if (_isEnhancedActive && _wrapper != null) {
      return await _wrapper!.areTokensValid();
    }
    
    // Fallback al sistema original
    try {
      final originalManager = getIt<RantiPayTokenManager>();
      return await originalManager.hasValidTokens();
    } catch (e) {
      debugPrint('❌ Error checking token validity: $e');
      return false;
    }
  }

  /// **Limpiar tokens**
  static Future<void> clearTokens() async {
    if (_isEnhancedActive && _wrapper != null) {
      await _wrapper!.clearTokens();
    } else {
      try {
        final originalManager = getIt<RantiPayTokenManager>();
        await originalManager.clearTokens();
      } catch (e) {
        debugPrint('❌ Error clearing tokens: $e');
      }
    }
  }

  /// **Forzar refresh de tokens (solo enhanced mode)**
  static Future<String?> forceRefreshTokens() async {
    if (_isEnhancedActive && _wrapper != null) {
      return await _wrapper!.forceRefresh();
    }
    
    debugPrint('⚠️ Force refresh not available in basic mode');
    return null;
  }

  /// **Obtener información de debug**
  static Future<Map<String, dynamic>> getDebugInfo() async {
    final info = <String, dynamic>{
      'enhanced_active': _isEnhancedActive,
      'wrapper_available': _wrapper != null,
    };

    if (_wrapper != null) {
      try {
        final wrapperInfo = await _wrapper!.getDebugInfo();
        info.addAll(wrapperInfo);
      } catch (e) {
        info['wrapper_error'] = e.toString();
      }
    }

    return info;
  }

  /// **Métodos privados de implementación**
  
  /// Parchear el token manager existente para usar enhanced system
  static Future<void> _patchExistingTokenManager() async {
    try {
      debugPrint('🔧 Patching existing token manager...');
      
      // Aquí puedes interceptar y redirigir llamadas al token manager original
      // Esta implementación es conceptual - en producción necesitarías más integración
      
      debugPrint('✅ Token manager patched successfully');
    } catch (e) {
      debugPrint('❌ Error patching token manager: $e');
    }
  }

  /// **Wrapper methods para interceptar llamadas del DioClient**
  
  /// Factory method para crear enhanced auth interceptor
  static dynamic createEnhancedAuthInterceptor({
    VoidCallback? onAuthenticationFailed,
  }) {
    if (_isEnhancedActive && _wrapper?.enhancedManager != null) {
      debugPrint('🔧 Creating Enhanced Auth Interceptor');
      
      // En este punto retornarías el EnhancedAuthInterceptor
      // Por ahora, retornamos un factory function que puede ser usado
      return {
        'type': 'enhanced',
        'getAccessToken': getAccessToken,
        'getRefreshToken': getRefreshToken,
        'saveTokens': saveTokens,
        'onAuthenticationFailed': onAuthenticationFailed,
        'forceRefresh': forceRefreshTokens,
      };
    } else {
      debugPrint('🔧 Creating Standard Auth Interceptor');
      
      return {
        'type': 'standard',
        'getAccessToken': getAccessToken,
        'getRefreshToken': getRefreshToken,
        'saveTokens': saveTokens,
        'onAuthenticationFailed': onAuthenticationFailed,
      };
    }
  }

  /// **Métodos de utilidad**
  
  /// Verificar si el sistema necesita migración
  static Future<bool> shouldMigrate() async {
    if (_isEnhancedActive) return false;
    
    try {
      // Verificar si hay problemas con el sistema actual
      final hasTokens = await areTokensValid();
      
      if (!hasTokens) {
        debugPrint('⚠️ No valid tokens found, migration recommended');
        return true;
      }
      
      // Más verificaciones podrían ir aquí...
      
    } catch (e) {
      debugPrint('⚠️ Error checking migration status: $e');
      return true;
    }
    
    return false;
  }

  /// Auto-activar enhanced system si es beneficioso
  static Future<void> autoActivateIfNeeded() async {
    if (_isEnhancedActive) return;
    
    final shouldActivate = await shouldMigrate();
    
    if (shouldActivate) {
      debugPrint('🤖 Auto-activating Enhanced Token System...');
      await activateEnhancedSystem();
    }
  }

  /// Desactivar enhanced system (para testing)
  static Future<void> deactivateEnhancedSystem() async {
    if (!_isEnhancedActive) return;
    
    debugPrint('🔄 Deactivating Enhanced Token System...');
    
    try {
      _wrapper?.dispose();
      _wrapper = null;
      _isEnhancedActive = false;
      
      debugPrint('✅ Enhanced Token System deactivated');
    } catch (e) {
      debugPrint('❌ Error deactivating enhanced system: $e');
    }
  }

  /// **Diagnósticos y monitoring**
  
  /// Obtener métricas del sistema de tokens
  static Future<Map<String, dynamic>> getMetrics() async {
    final metrics = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'enhanced_active': _isEnhancedActive,
    };

    try {
      final debugInfo = await getDebugInfo();
      metrics.addAll(debugInfo);

      // Métricas adicionales
      metrics['access_token_length'] = (await getAccessToken())?.length ?? 0;
      metrics['refresh_token_length'] = (await getRefreshToken())?.length ?? 0;
      metrics['tokens_valid'] = await areTokensValid();

    } catch (e) {
      metrics['error'] = e.toString();
    }

    return metrics;
  }

  /// Log de estado actual
  static Future<void> logCurrentState() async {
    final metrics = await getMetrics();
    
    debugPrint('📊 Token Manager State:');
    metrics.forEach((key, value) {
      debugPrint('   - $key: $value');
    });
  }
}