// lib/core/rantipay/enhanced_auth_interceptor.dart

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/infrastructure/enhanced_token_manager.dart';
import '../../features/auth/infrastructure/rantipay_network_constants.dart';

/// **Enhanced Auth Interceptor con Refresh Automático Proactivo**
/// 
/// Este interceptor soluciona el problema de pérdida de tokens implementando:
/// - ✅ Refresh automático antes de que los tokens expiren
/// - ✅ Queue inteligente de requests durante refresh
/// - ✅ Retry automático de requests fallidos por auth
/// - ✅ Detección proactiva de tokens expirados
/// - ✅ Fallback robusto en caso de errores
/// - ✅ Logging detallado para debugging
class EnhancedAuthInterceptor extends Interceptor {
  final EnhancedTokenManager _tokenManager;
  final VoidCallback? onAuthenticationFailed;
  
  // Estado del interceptor
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];
  Completer<bool>? _refreshCompleter;
  
  // Configuración
  static const Duration _requestTimeout = Duration(seconds: 30);

  EnhancedAuthInterceptor({
    required EnhancedTokenManager tokenManager,
    this.onAuthenticationFailed,
  }) : _tokenManager = tokenManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    debugPrint('🔍 EnhancedAuthInterceptor: Processing request to ${options.path}');
    
    // Skip auth for public endpoints
    if (_shouldSkipAuth(options.path)) {
      debugPrint('⚪ EnhancedAuthInterceptor: Skipping auth for public endpoint ${options.path}');
      return handler.next(options);
    }

    // Si hay refresh en progreso, poner en queue
    if (_isRefreshing) {
      debugPrint('⏳ EnhancedAuthInterceptor: Refresh in progress, queuing request...');
      await _queueRequest(options, handler);
      return;
    }

    // Intentar añadir token de autenticación
    final success = await _addAuthToken(options);
    if (!success) {
      debugPrint('❌ EnhancedAuthInterceptor: Failed to add auth token for ${options.path}');
      // Si no se puede autenticar y no es endpoint público, fallar
      if (!_shouldSkipAuth(options.path)) {
        final error = DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            statusMessage: 'No authentication token available',
          ),
          type: DioExceptionType.badResponse,
        );
        return handler.reject(error);
      }
    }

    // Añadir headers personalizados
    await _addCustomHeaders(options);
    
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint('🔴 EnhancedAuthInterceptor: Error on ${err.requestOptions.path}: ${err.response?.statusCode}');
    print('🔴 ENHANCED AUTH INTERCEPTOR: Error ${err.response?.statusCode} on ${err.requestOptions.path}');
    print('🔴 ENHANCED AUTH INTERCEPTOR: Response data: ${err.response?.data}');

    // Manejar errores de autenticación (401/403)
    if (_isAuthError(err)) {
      print('🔍 ENHANCED AUTH INTERCEPTOR: Is auth error, handling...');
      final handled = await _handleAuthError(err, handler);
      print('🔍 ENHANCED AUTH INTERCEPTOR: Auth error handled: $handled');
      if (handled) return;
    } else {
      print('❌ ENHANCED AUTH INTERCEPTOR: Not an auth error, skipping');
    }

    // Si no se manejó el error, continuar con el flow normal
    print('➡️ ENHANCED AUTH INTERCEPTOR: Passing error to next handler');
    handler.next(err);
  }

  /// **Métodos privados de implementación**
  
  /// Verificar si debe saltarse la autenticación
  bool _shouldSkipAuth(String path) {
    final publicEndpoints = [
      '/health',
      '/api/v1/auth/register',
      '/api/v1/auth/login',
      '/api/v1/auth/refresh',
      '/api/v1/auth/otp',
      '/api/public/',
      '/auth/register/phone',  // Endpoint de registro público
      '/auth/register/',       // Todos los endpoints de registro
      '/auth/login/',          // Todos los endpoints de login
      '/auth/otp/',            // Todos los endpoints de OTP
      '/auth/oauth/',          // 🚀 Todos los endpoints de OAuth (públicos)
      '/api/oauth/',           // Compatibilidad con endpoints OAuth alternativos
      '/api/auth/oauth/',      // 🚀 Endpoints OAuth con prefijo /api/auth/
      '/oauth/',               // 🚀 Backend OAuth endpoints (GET /oauth/{provider}/authorize)  
      '/api/v1/auth/oauth/',   // 🚀 Full OAuth endpoints path
      '/login/social',         // 🚀 Social login endpoint
      '/register/social',      // 🚀 Social registration endpoint
      '/api/v1/auth/login/social',     // 🚀 Full social login endpoint
      '/api/v1/auth/register/social',  // 🚀 Full social registration endpoint
    ];
    
    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Añadir token de autenticación al request
  Future<bool> _addAuthToken(RequestOptions options) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();
      
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers[RantiPayNetworkConstants.authorization] = 'Bearer $accessToken';
        
        debugPrint('🔐 EnhancedAuthInterceptor: Auth token added');
        debugPrint('   - Path: ${options.path}');
        debugPrint('   - Token length: ${accessToken.length}');
        debugPrint('   - Headers count: ${options.headers.length}');
        
        return true;
      } else {
        debugPrint('⚠️ EnhancedAuthInterceptor: No access token available');
        return false;
      }
    } catch (e, stack) {
      debugPrint('❌ EnhancedAuthInterceptor: Error adding auth token: $e');
      debugPrint('Stack: $stack');
      return false;
    }
  }

  /// Añadir headers personalizados
  Future<void> _addCustomHeaders(RequestOptions options) async {
    try {
      // Headers estándar de RantiPay
      options.headers.addAll({
        'Accept': 'application/json',
        'User-Agent': 'RantiPay-Flutter/1.0.0',
        'X-API-Version': 'v1',
        'X-Platform': 'flutter',
        'X-Request-ID': 'req_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().millisecondsSinceEpoch % 100000}',
        'X-Request-Time': DateTime.now().toIso8601String(),
      });

      // Extraer tenant_id y company_id del JWT token
      try {
        final jwtHeaders = await _extractJwtHeaders();
        if (jwtHeaders != null && jwtHeaders.isNotEmpty) {
          options.headers.addAll(jwtHeaders);
          debugPrint('✅ EnhancedAuthInterceptor: Added JWT-extracted headers (tenant_id: ${jwtHeaders['X-Tenant-ID']?.substring(0, 8)}..., company_id: ${jwtHeaders['X-Company-ID']?.substring(0, 8)}...)');
        } else {
          // Fallback to default values if JWT extraction fails
          options.headers.addAll({
            'X-Tenant-ID': 'default',
            'X-Company-ID': 'default',
          });
          debugPrint('⚠️ EnhancedAuthInterceptor: Using default headers (JWT extraction failed)');
        }

        // Headers adicionales
        options.headers.addAll({
          'X-Device-ID': 'flutter_device_${DateTime.now().millisecondsSinceEpoch}',
          'Content-Type': 'application/json',
          'X-App-Version': '1.0.0',
          'X-Request-Timestamp': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (e) {
        debugPrint('⚠️ Warning adding custom headers: $e');
        // Emergency fallback
        options.headers.addAll({
          'X-Tenant-ID': 'default',
          'X-Company-ID': 'default',
        });
      }
    } catch (e) {
      debugPrint('❌ Error adding custom headers: $e');
    }
  }

  /// Extraer headers de tenant_id y company_id del JWT token
  Future<Map<String, String>?> _extractJwtHeaders() async {
    try {
      // Obtener el token actual
      final token = await _tokenManager.getAccessToken();

      if (token == null || token.isEmpty) {
        debugPrint('⚠️ EnhancedAuthInterceptor: No access token available for header extraction');
        return null;
      }

      // Parsear el JWT token (formato: header.payload.signature)
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('⚠️ EnhancedAuthInterceptor: Invalid JWT format (expected 3 parts, got ${parts.length})');
        return null;
      }

      // Decodificar el payload (segunda parte del JWT)
      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final Map<String, dynamic> claims = jsonDecode(decodedString);

      // Extraer los IDs del JWT
      final tenantId = claims['tenant_id'] as String?;
      final companyId = claims['company_id'] as String?;
      final userId = claims['sub'] as String? ?? claims['user_id'] as String?;

      if (tenantId == null || companyId == null) {
        debugPrint('⚠️ EnhancedAuthInterceptor: Missing required claims in JWT');
        debugPrint('   tenant_id: ${tenantId ?? "missing"}');
        debugPrint('   company_id: ${companyId ?? "missing"}');
        return null;
      }

      debugPrint('🔍 EnhancedAuthInterceptor: JWT headers extracted successfully');
      debugPrint('   tenant_id: ${tenantId.substring(0, 8)}...');
      debugPrint('   company_id: ${companyId.substring(0, 8)}...');

      return {
        'X-Tenant-ID': tenantId,
        'X-Company-ID': companyId,
        if (userId != null) 'X-User-ID': userId,
      };
    } catch (e, stack) {
      debugPrint('❌ EnhancedAuthInterceptor: Error extracting JWT headers: $e');
      debugPrint('Stack: ${stack.toString().split('\n').take(3).join('\n')}');
      return null;
    }
  }

  /// Verificar si es un error de autenticación
  bool _isAuthError(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }

  /// Manejar errores de autenticación
  Future<bool> _handleAuthError(DioException error, ErrorInterceptorHandler handler) async {
    debugPrint('🔐 EnhancedAuthInterceptor: Handling auth error (${error.response?.statusCode})');
    
    // Verificar si es un error de token
    if (!_isTokenError(error)) {
      debugPrint('⚠️ Auth error but not token-related, skipping refresh');
      return false;
    }

    // Intentar refresh si no está en progreso
    if (!_isRefreshing) {
      final refreshSuccess = await _attemptTokenRefresh();
      
      if (refreshSuccess) {
        debugPrint('✅ Token refreshed, retrying original request...');
        
        try {
          final response = await _retryRequest(error.requestOptions);
          handler.resolve(response);
          return true;
        } catch (e) {
          debugPrint('❌ Retry failed after token refresh: $e');
        }
      }
    }

    // Si el refresh falla o ya está en progreso, notificar falla de autenticación
    debugPrint('❌ Authentication failed, calling onAuthenticationFailed');
    onAuthenticationFailed?.call();
    return false;
  }

  /// Verificar si es un error relacionado con tokens
  bool _isTokenError(DioException error) {
    final responseData = error.response?.data;
    print('🔍 ENHANCED AUTH INTERCEPTOR: _isTokenError checking data: $responseData');

    if (responseData is Map) {
      final message = responseData['message']?.toString().toLowerCase() ?? '';
      final errorText = responseData['error']?.toString().toLowerCase() ?? '';
      final errorCode = responseData['error']?['code']?.toString().toLowerCase() ?? '';
      final errorMessage = responseData['error']?['message']?.toString().toLowerCase() ?? '';

      print('🔍 ENHANCED AUTH INTERCEPTOR: message = $message');
      print('🔍 ENHANCED AUTH INTERCEPTOR: errorText = $errorText');
      print('🔍 ENHANCED AUTH INTERCEPTOR: errorCode = $errorCode');
      print('🔍 ENHANCED AUTH INTERCEPTOR: errorMessage = $errorMessage');

      // Patrones comunes de errores de token
      final tokenErrorPatterns = [
        'token',
        'expired',
        'unauthorized',
        'invalid_token',
        'access_denied',
        'jwt',
      ];
      
      final isTokenError = tokenErrorPatterns.any((pattern) =>
        message.contains(pattern) ||
        errorText.contains(pattern) ||
        errorCode.contains(pattern) ||
        errorMessage.contains(pattern));

      print('✅ ENHANCED AUTH INTERCEPTOR: Token error detected: $isTokenError');
      return isTokenError;
    }

    print('❌ ENHANCED AUTH INTERCEPTOR: No token error detected (not a Map), defaulting to true for 401/403');
    return true; // Por defecto, asumir que 401/403 son errores de token
  }

  /// Intentar refresh de token
  Future<bool> _attemptTokenRefresh() async {
    if (_isRefreshing) {
      // Si ya hay refresh en progreso, esperar
      return await _waitForRefreshCompletion();
    }
    
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();
    
    try {
      debugPrint('🔄 EnhancedAuthInterceptor: Starting token refresh...');
      
      final newToken = await _tokenManager.forceRefresh();
      final success = newToken != null;
      
      if (success) {
        debugPrint('✅ EnhancedAuthInterceptor: Token refresh successful');
        // Procesar requests pendientes
        await _processPendingRequests();
      } else {
        debugPrint('❌ EnhancedAuthInterceptor: Token refresh failed');
        // Rechazar requests pendientes
        await _rejectPendingRequests();
      }
      
      _refreshCompleter!.complete(success);
      return success;
      
    } catch (e, stack) {
      debugPrint('❌ EnhancedAuthInterceptor: Token refresh error: $e');
      debugPrint('Stack: $stack');
      
      _refreshCompleter!.complete(false);
      await _rejectPendingRequests();
      return false;
      
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Esperar a que termine el refresh
  Future<bool> _waitForRefreshCompletion() async {
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }
    return false;
  }

  /// Poner request en queue
  Future<void> _queueRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final pendingRequest = _PendingRequest(options, handler);
    _pendingRequests.add(pendingRequest);
    
    debugPrint('📋 EnhancedAuthInterceptor: Request queued (${_pendingRequests.length} pending)');
  }

  /// Procesar requests pendientes después de refresh exitoso
  Future<void> _processPendingRequests() async {
    debugPrint('📤 EnhancedAuthInterceptor: Processing ${_pendingRequests.length} pending requests...');
    
    final requestsToProcess = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();
    
    for (final pendingRequest in requestsToProcess) {
      try {
        // Añadir nuevo token al request
        final success = await _addAuthToken(pendingRequest.options);
        
        if (success) {
          pendingRequest.handler.next(pendingRequest.options);
        } else {
          final error = DioException(
            requestOptions: pendingRequest.options,
            response: Response(
              requestOptions: pendingRequest.options,
              statusCode: 401,
              statusMessage: 'Failed to add auth token after refresh',
            ),
            type: DioExceptionType.badResponse,
          );
          pendingRequest.handler.reject(error);
        }
      } catch (e) {
        debugPrint('❌ Error processing pending request: $e');
        final error = DioException(
          requestOptions: pendingRequest.options,
          message: 'Error processing pending request: $e',
          type: DioExceptionType.unknown,
        );
        pendingRequest.handler.reject(error);
      }
    }
  }

  /// Rechazar requests pendientes cuando falla el refresh
  Future<void> _rejectPendingRequests() async {
    debugPrint('❌ EnhancedAuthInterceptor: Rejecting ${_pendingRequests.length} pending requests...');
    
    final requestsToReject = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();
    
    for (final pendingRequest in requestsToReject) {
      final error = DioException(
        requestOptions: pendingRequest.options,
        response: Response(
          requestOptions: pendingRequest.options,
          statusCode: 401,
          statusMessage: 'Authentication failed - token refresh unsuccessful',
        ),
        type: DioExceptionType.badResponse,
      );
      pendingRequest.handler.reject(error);
    }
  }

  /// Reintentar request original
  Future<Response> _retryRequest(RequestOptions originalOptions) async {
    debugPrint('🔄 EnhancedAuthInterceptor: Retrying request to ${originalOptions.path}');
    
    // Crear nueva instancia de Dio para evitar interceptor loops
    final dio = Dio();
    
    // Copiar configuración básica
    dio.options.baseUrl = originalOptions.baseUrl;
    dio.options.connectTimeout = _requestTimeout;
    dio.options.receiveTimeout = _requestTimeout;
    dio.options.sendTimeout = _requestTimeout;
    
    // Añadir token actualizado
    final newOptions = originalOptions.copyWith();
    await _addAuthToken(newOptions);
    await _addCustomHeaders(newOptions);
    
    // Realizar request
    return await dio.request(
      newOptions.path,
      data: newOptions.data,
      queryParameters: newOptions.queryParameters,
      cancelToken: newOptions.cancelToken,
      options: Options(
        method: newOptions.method,
        sendTimeout: newOptions.sendTimeout,
        receiveTimeout: newOptions.receiveTimeout,
        extra: newOptions.extra,
        headers: newOptions.headers,
        responseType: newOptions.responseType,
        contentType: newOptions.contentType,
        validateStatus: newOptions.validateStatus,
        receiveDataWhenStatusError: newOptions.receiveDataWhenStatusError,
        followRedirects: newOptions.followRedirects,
        maxRedirects: newOptions.maxRedirects,
        persistentConnection: newOptions.persistentConnection,
        requestEncoder: newOptions.requestEncoder,
        responseDecoder: newOptions.responseDecoder,
        listFormat: newOptions.listFormat,
      ),
    );
  }
}

/// **Request pendiente durante refresh**
class _PendingRequest {
  final RequestOptions options;
  final RequestInterceptorHandler handler;
  final DateTime createdAt;
  
  _PendingRequest(this.options, this.handler) : createdAt = DateTime.now();
}