import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rantipay_app/core/di/service_container.dart';
import 'package:rantipay_app/features/auth/infrastructure/rantipay_auth_state_manager.dart';
import 'package:rantipay_app/features/auth/infrastructure/rantipay_network_constants.dart';

/// Authentication interceptor for adding auth headers and handling token refresh

class RantiPayAuthInterceptor extends Interceptor {
  final Future<String?> Function() getAccessToken;
  final Future<String?> Function() getRefreshToken;
  final Future<bool> Function(String) saveAccessToken;
  final Future<bool> Function(String) saveRefreshToken;
  final Future<Map<String, String>?> Function(String) refreshTokens;
  final VoidCallback? onAuthenticationFailed;

  /// Tracks if we're currently refreshing to prevent multiple refresh attempts
  bool _isRefreshing = false;

  /// Queue of pending requests while refreshing
  final List<_PendingRequestInfo> _pendingRequests = [];

  RantiPayAuthInterceptor({
    required this.getAccessToken,
    required this.getRefreshToken,
    required this.saveAccessToken,
    required this.saveRefreshToken,
    required this.refreshTokens,
    this.onAuthenticationFailed,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for certain endpoints
    if (_shouldSkipAuth(options.path)) {
      return handler.next(options);
    }

    // If we're refreshing, queue this request
    if (_isRefreshing) {
      print('⏳ AUTH: Request queued during refresh: ${options.path}');
      _pendingRequests.add(_PendingRequestInfo(options, handler));
      return;
    }

    // Get access token
    print('🔍 AUTH INTERCEPTOR: Calling getAccessToken function...');
    try {
      final accessToken = await getAccessToken();
      print('🔍 AUTH INTERCEPTOR: getAccessToken returned: ${accessToken != null ? "token with ${accessToken.length} chars" : "null"}');

      // ✅ FIX Oct 22: Detectar y usar tokens de registro
      if (accessToken != null && accessToken.isNotEmpty) {
        // Check if it's a registration token (reg_XXXX format)
        final isRegistrationToken = accessToken.startsWith('reg_');

        if (isRegistrationToken) {
          // Registration tokens use different header format (no Bearer prefix)
          options.headers[RantiPayNetworkConstants.authorization] = accessToken;
          print('🔐 AUTH: Added REGISTRATION token header for ${options.path}');
          print('🔐 AUTH: Registration token length: ${accessToken.length}');
        } else {
          // JWT tokens use Bearer prefix
          options.headers[RantiPayNetworkConstants.authorization] =
              'Bearer $accessToken';
          print('🔐 AUTH: Added JWT Authorization header for ${options.path}');
          print('🔐 AUTH: Token length: ${accessToken.length}');
        }

        print('🔐 AUTH: Headers count: ${options.headers.length}');
        print(
            '🔐 AUTH: Has Authorization: ${options.headers.containsKey(RantiPayNetworkConstants.authorization)}');
      } else {
        print('⚠️ AUTH: No token available for ${options.path}');
        // If this is not a public endpoint and no token is available, we might want to fail fast
        if (!_shouldSkipAuth(options.path)) {
          print('❌ AUTH: Required authentication missing for ${options.path}');
        }
      }
    } catch (e, stack) {
      print('❌ AUTH INTERCEPTOR: Error getting access token: $e');
      print('❌ AUTH INTERCEPTOR: Stack trace: $stack');
    }

    // Add custom headers
    await _addCustomHeaders(options);

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    print('🚨 AUTH INTERCEPTOR onError: CALLED with ${err.response?.statusCode} - ${err.requestOptions.path}');
    print('🚨 AUTH INTERCEPTOR: Response data = ${err.response?.data}');

    // Check if error is due to expired token
    if (err.response?.statusCode ==
        RantiPayNetworkConstants.statusUnauthorized) {

      // Log the 401 error details for debugging
      print('🔴 AUTH ERROR: 401 Unauthorized on ${err.requestOptions.path}');
      print('🔴 Response data: ${err.response?.data}');

      final isTokenError = _isTokenError(err.response);
      print('🔍 AUTH: isTokenError = $isTokenError');

      if (isTokenError && !_isRefreshing) {
        print('🔄 AUTH: Attempting token refresh...');
        try {
          // Try to refresh token
          final refreshSuccess = await _handleTokenRefresh();

          if (refreshSuccess) {
            print('✅ AUTH: Token refresh successful, retrying request...');
            // Retry the original request
            final response = await _retryRequest(err.requestOptions);
            return handler.resolve(response);
          } else {
            print('❌ AUTH: Token refresh failed');
          }
        } catch (e) {
          print('❌ AUTH: Token refresh error: $e');
        }
      } else if (!isTokenError) {
        print('⚠️ AUTH: 401 error but not a token error, passing through');
      } else if (_isRefreshing) {
        print('⚠️ AUTH: Already refreshing tokens, queueing request');
      }

      // If refresh failed or not a token error, notify about auth failure
      onAuthenticationFailed?.call();
    } else {
      print('🔍 AUTH INTERCEPTOR: Non-401 error ${err.response?.statusCode}, passing through');
    }

    handler.next(err);
  }

  /// Check if we should skip authentication for this endpoint
  bool _shouldSkipAuth(String path) {
    final publicEndpoints = [
      '/health',
      '/api/v1/auth/register',
      '/api/v1/auth/login',
      '/api/v1/auth/refresh',
      '/api/v1/auth/otp',
      '/auth/register/phone',  // Endpoint de registro público
      '/auth/register/',       // Todos los endpoints de registro
      '/auth/login/',          // Todos los endpoints de login
      '/auth/otp/',            // Todos los endpoints de OTP
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Check if the error is specifically a token error
  bool _isTokenError(Response? response) {
    if (response == null) return false;

    // Check for various token error formats
    final data = response.data;
    print('🔍 AUTH: _isTokenError checking data: $data');
    
    // Check error code in error object - case insensitive
    final errorCode = data?['error']?['code'] as String?;
    print('🔍 AUTH: errorCode = $errorCode');
    if (errorCode != null) {
      final errorCodeLower = errorCode.toLowerCase();
      print('🔍 AUTH: errorCodeLower = $errorCodeLower');
      if (errorCodeLower == RantiPayNetworkConstants.errorTokenExpired.toLowerCase() ||
          errorCodeLower == RantiPayNetworkConstants.errorInvalidCredentials.toLowerCase() ||
          errorCodeLower == 'unauthorized' ||
          errorCodeLower == 'invalid_token') {
        print('✅ AUTH: Token error detected via error code');
        return true;
      }
    }
    
    // Check for message field (like "invalid_token") - case insensitive
    final message = data?['message'] as String?;
    print('🔍 AUTH: message = $message');
    if (message != null) {
      final messageLower = message.toLowerCase();
      print('🔍 AUTH: messageLower = $messageLower');
      if (messageLower.contains('invalid_token') ||
          messageLower.contains('token_expired') ||
          messageLower.contains('invalid token') ||
          messageLower.contains('unauthorized')) {
        print('✅ AUTH: Token error detected via message');
        return true;
      }
    }
    
    // Check for error field directly (most common case)
    final error = data?['error'] as String?;
    print('🔍 AUTH: error field = $error');
    if (error != null) {
      final errorLower = error.toLowerCase();
      if (errorLower.contains('invalid_token') ||
          errorLower.contains('token_expired') ||
          errorLower.contains('unauthorized') ||
          errorLower == 'invalid_token') {
        print('✅ AUTH: Token error detected via error field');
        return true;
      }
    }

    print('❌ AUTH: No token error detected');
    return false;
  }

  /// Handle token refresh with enhanced error handling
  Future<bool> _handleTokenRefresh() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;

    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ AUTH: No refresh token available for refresh');
        return false;
      }

      // ✅ CRITICAL FIX: Check if refresh token is expired before using it (with UTC)
      try {
        final refreshExpirationDate = JwtDecoder.getExpirationDate(refreshToken);
        final currentTime = DateTime.now().toUtc();
        final isRefreshExpired = currentTime.isAfter(refreshExpirationDate);

        if (isRefreshExpired) {
          print('❌ AUTH: Refresh token is expired, cannot refresh');
          print('🚨 AUTH: Both tokens expired - forcing logout');

          // Clear all tokens and force logout
          onAuthenticationFailed?.call();
          return false;
        }
      } catch (e) {
        print('⚠️ AUTH: Cannot validate refresh token expiry: $e');
        // Continue with refresh attempt
      }

      print('🔄 AUTH: Attempting token refresh with valid refresh token...');

      // Call refresh endpoint
      final tokens = await refreshTokens(refreshToken);

      if (tokens != null &&
          tokens['access_token'] != null &&
          tokens['refresh_token'] != null) {
        print('✅ AUTH: Token refresh successful');

        // Save new tokens
        await saveAccessToken(tokens['access_token']!);
        await saveRefreshToken(tokens['refresh_token']!);

        // Process pending requests with new token
        await _processPendingRequests(tokens['access_token']!);

        return true;
      } else {
        print('❌ AUTH: Token refresh failed - invalid response format');
        print('🚨 AUTH: Refresh failed - tokens may be completely invalid');

        // If refresh fails, it usually means both tokens are invalid
        onAuthenticationFailed?.call();
      }

      await _rejectPendingRequests();
      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      print('❌ AUTH: Token refresh error: $e');

      // Check if the error indicates invalid tokens
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('invalid_token') ||
          errorString.contains('unauthorized') ||
          errorString.contains('expired')) {
        print('🚨 AUTH: Error indicates invalid tokens - forcing logout');
        onAuthenticationFailed?.call();
      }

      await _rejectPendingRequests();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Retry a request with new token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    print('🔄 AUTH: Retrying request to ${requestOptions.path}');

    final accessToken = await getAccessToken();

    if (accessToken != null) {
      requestOptions.headers[RantiPayNetworkConstants.authorization] =
          'Bearer $accessToken';
      print('🔐 AUTH: Updated auth header for retry');
    }

    // Create new Dio instance without interceptors to avoid infinite loops
    final dio = Dio();
    dio.options.baseUrl = requestOptions.baseUrl;
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);
    dio.options.sendTimeout = Duration(seconds: 30);

    return await dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        persistentConnection: requestOptions.persistentConnection,
        requestEncoder: requestOptions.requestEncoder,
        responseDecoder: requestOptions.responseDecoder,
        listFormat: requestOptions.listFormat,
      ),
    );
  }

  /// Process pending requests after token refresh
  Future<void> _processPendingRequests(String newAccessToken) async {
    print('📤 AUTH: Processing ${_pendingRequests.length} pending requests...');

    final requestsToProcess = List<_PendingRequestInfo>.from(_pendingRequests);
    _pendingRequests.clear();

    for (final pendingRequest in requestsToProcess) {
      try {
        // Add new token to the request
        pendingRequest.options.headers[RantiPayNetworkConstants.authorization] =
            'Bearer $newAccessToken';

        // Add custom headers
        await _addCustomHeaders(pendingRequest.options);

        print('📤 AUTH: Processing pending request: ${pendingRequest.options.path}');

        // Continue with the original request
        pendingRequest.handler.next(pendingRequest.options);
      } catch (e) {
        print('❌ AUTH: Error processing pending request: $e');
        final error = DioException(
          requestOptions: pendingRequest.options,
          message: 'Error processing pending request: $e',
          type: DioExceptionType.unknown,
        );
        pendingRequest.handler.reject(error);
      }
    }
  }

  /// Reject pending requests when token refresh fails
  Future<void> _rejectPendingRequests() async {
    print('❌ AUTH: Rejecting ${_pendingRequests.length} pending requests...');

    final requestsToReject = List<_PendingRequestInfo>.from(_pendingRequests);
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

  /// Add custom headers to request
  Future<void> _addCustomHeaders(RequestOptions options) async {
    // Add platform header
    options.headers[RantiPayNetworkConstants.xPlatform] =
        RantiPayNetworkConstants.defaultPlatform;

    // Add API version
    options.headers[RantiPayNetworkConstants.xApiVersion] =
        RantiPayNetworkConstants.defaultApiVersion;

    // Add user agent
    options.headers[RantiPayNetworkConstants.userAgent] =
        RantiPayNetworkConstants.defaultUserAgent;

    // Generate request ID
    options.headers[RantiPayNetworkConstants.xRequestId] = _generateRequestId();

    // ✅ UPDATED Oct 22: Extract tenant/company headers from JWT token (skip for registration tokens)
    try {
      final accessToken = await getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        // ✅ FIX Oct 22: Skip JWT parsing for registration tokens
        final isRegistrationToken = accessToken.startsWith('reg_');

        if (isRegistrationToken) {
          // For registration tokens, use minimal headers
          options.headers[RantiPayNetworkConstants.xTenantId] = 'onboarding';
          options.headers[RantiPayNetworkConstants.xCompanyId] = 'onboarding';
          print('🔧 AUTH: Using onboarding headers for registration token');
        } else {
          // For JWT tokens, extract headers from payload
          final tokenData = _parseJwtPayload(accessToken);

          // Add tenant ID from JWT (matches confirmed backend format)
          final tenantId = tokenData['tenant_id'] as String?;
          if (tenantId != null && tenantId.isNotEmpty) {
            options.headers[RantiPayNetworkConstants.xTenantId] = tenantId;
          } else {
            options.headers[RantiPayNetworkConstants.xTenantId] = 'default';
          }

          // Add company ID from JWT (matches confirmed backend format)
          final companyId = tokenData['company_id'] as String?;
          if (companyId != null && companyId.isNotEmpty) {
            options.headers[RantiPayNetworkConstants.xCompanyId] = companyId;
          } else {
            options.headers[RantiPayNetworkConstants.xCompanyId] = 'default';
          }

          // Add user ID for tracking
          final userId = tokenData['sub'] as String? ?? tokenData['user_id'] as String?;
          if (userId != null && userId.isNotEmpty) {
            options.headers['X-User-ID'] = userId;
          }

          // Add user level - prioritize AuthStateManager over JWT for immediate updates
          int? userLevel;
          try {
            final authStateManager = getIt<RantiPayAuthStateManager>();
            userLevel = await authStateManager.getCurrentLevel();
          } catch (e) {
            // Fallback to JWT if AuthStateManager fails
            userLevel = tokenData['user_level'] as int?;
            debugPrint('⚠️ AUTH: Using JWT user level as fallback: $userLevel');
          }

          if (userLevel != null) {
            options.headers[RantiPayNetworkConstants.xUserLevel] = userLevel.toString();
            debugPrint('✅ AUTH: Added X-User-Level header: $userLevel');
          }
        }
      } else {
        // No token available, use defaults
        options.headers[RantiPayNetworkConstants.xTenantId] = 'default';
        options.headers[RantiPayNetworkConstants.xCompanyId] = 'default';
      }
    } catch (e) {
      // Fallback to defaults if JWT parsing fails
      print('⚠️ AUTH: Failed to parse JWT for headers, using defaults: $e');
      options.headers[RantiPayNetworkConstants.xTenantId] = 'default';
      options.headers[RantiPayNetworkConstants.xCompanyId] = 'default';
    }

    // Add device ID for tracking
    options.headers['X-Device-ID'] =
        'flutter_device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Generate unique request ID
  String _generateRequestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString().substring(8);
    return 'req_${timestamp}_$random';
  }

  /// Parse JWT payload for header extraction
  Map<String, dynamic> _parseJwtPayload(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      debugPrint('JWT parsing error: $e');
      return <String, dynamic>{};
    }
  }
}

/// Token storage interface
abstract class RantiPayTokenStorageMin {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<bool> saveAccessToken(String token);
  Future<bool> saveRefreshToken(String token);
  Future<bool> clearTokens();
}

/// Token refresh service interface
abstract class RantiPayTokenRefreshService {
  Future<Map<String, String>?> refreshTokens(String refreshToken);
}

/// **Request pendiente durante refresh**
class _PendingRequestInfo {
  final RequestOptions options;
  final RequestInterceptorHandler handler;
  final DateTime createdAt;

  _PendingRequestInfo(this.options, this.handler) : createdAt = DateTime.now();
}
