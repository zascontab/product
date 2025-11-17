import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/config/rantipay_api_config.dart';
import 'package:rantipay_app/core/config/rantipay_enviroment.dart';
import 'package:rantipay_app/core/network/rantipay_network_info.dart';
import 'package:rantipay_app/core/rantipay/failure/rantipay_error_interceptor.dart';
import 'package:rantipay_app/core/rantipay/rantipay_auth_interceptor.dart';
import 'package:rantipay_app/features/auth/infrastructure/rantipay_network_constants.dart';
import 'package:rantipay_app/features/auth/infrastructure/rantipay_request_interceptor.dart';
import 'package:rantipay_app/features/auth/infrastructure/rantipay_response_interceptor.dart';
import 'package:rantipay_app/features/auth/infrastructure/rantipay_retry_interceptor.dart';
import 'package:rantipay_app/features/auth/infrastructure/rantipay_token_manager.dart';
import 'package:rantipay_app/core/di/service_container.dart';
import 'package:rantipay_app/core/rantipay/token_manager_integration_service.dart';
import 'package:rantipay_app/core/rantipay/enhanced_auth_interceptor.dart';

/// Main Dio client for RantiPay API communications

class RantiPayDioClient {
  late final Dio _dio;
  final RantiPayApiConfig apiConfig;
  final RantiPayNetworkInfo? networkInfo;
  final RantiPayTokenStorageMin? tokenStorage;
  final RantiPayTokenRefreshService? tokenRefreshService;

  // Interceptors
  final List<Interceptor> additionalInterceptors;

  // Configuration
  final bool enableLogging;
  final bool enableRetry;
  final bool enableCaching;
  final bool enableCertificatePinning;

  RantiPayDioClient({
    required this.apiConfig,
    this.networkInfo,
    this.tokenStorage,
    this.tokenRefreshService,
    this.additionalInterceptors = const [],
    this.enableLogging = true,
    this.enableRetry = true,
    this.enableCaching = false,
    this.enableCertificatePinning = false,
  }) {
    _initializeDio();
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Initialize Dio with all configurations
  void _initializeDio() {
    _dio = Dio();

    // Set base options
    _dio.options = BaseOptions(
      baseUrl: apiConfig.baseUrl,
      connectTimeout: RantiPayNetworkConstants.connectTimeout,
      receiveTimeout: RantiPayNetworkConstants.receiveTimeout,
      sendTimeout: RantiPayNetworkConstants.sendTimeout,
      headers: _getDefaultHeaders(),
      responseType: ResponseType.json,
      // CAMBIO IMPORTANTE: Ajustar validateStatus para NO rechazar respuestas con success: false
      validateStatus: (status) {
        // Aceptar todos los status 2xx y 3xx como válidos
        // Los errores 4xx y 5xx serán manejados por el código
        return status != null && status < 400;
      },
    );

    // Configure HTTP adapter for certificate pinning
    if (enableCertificatePinning && RantiPayEnvironment.isProd) {
      _configureCertificatePinning();
    }

    // Add interceptors in order
    _addInterceptors();
  }

  /// Get default headers
  Map<String, dynamic> _getDefaultHeaders() {
    return {
      // ✅ CRITICAL FIX: Do NOT set Content-Type as base header
      // Let interceptor handle Content-Type based on request type
      RantiPayNetworkConstants.accept: RantiPayNetworkConstants.applicationJson,
      RantiPayNetworkConstants.userAgent:
          RantiPayNetworkConstants.defaultUserAgent,
      RantiPayNetworkConstants.xApiVersion:
          RantiPayNetworkConstants.defaultApiVersion,
      RantiPayNetworkConstants.xPlatform:
          RantiPayNetworkConstants.defaultPlatform,
    };
  }

  /// Configure certificate pinning for production
  void _configureCertificatePinning() {
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();

      client.badCertificateCallback = (cert, host, port) {
        // Verify certificate fingerprint
        final certFingerprint = _getCertificateFingerprint(cert);
        return RantiPayNetworkConstants.certificatePins
            .contains(certFingerprint);
      };

      return client;
    };
  }

  /// Get certificate fingerprint (simplified - implement proper SHA256)
  String _getCertificateFingerprint(X509Certificate cert) {
    // This is a simplified version. In production, implement proper SHA256 hashing
    return 'sha256/${cert.sha1.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  /// Add standard auth interceptor (fallback)
  void _addStandardAuthInterceptor() {
    print('🔧 DIO CLIENT: Adding Standard Auth Interceptor...');
    final authInterceptor = RantiPayAuthInterceptor(
        getAccessToken: () async {
          try {
            // Try enhanced system first
            if (TokenManagerIntegrationService.isEnhancedActive) {
              return await TokenManagerIntegrationService.getAccessToken();
            }
            
            // Fallback to original system
            if (tokenStorage != null) {
              print('🔍 DIO CLIENT: Using tokenStorage.getAccessToken()...');
              return await tokenStorage!.getAccessToken();
            } else {
              print('⚠️ DIO CLIENT: tokenStorage is null, trying GetIt fallback...');
              try {
                final tokenManager = getIt<RantiPayTokenManager>();
                print('✅ DIO CLIENT: Found TokenManager via GetIt');
                return await tokenManager.getAccessToken();
              } catch (e) {
                print('❌ DIO CLIENT: GetIt fallback failed: $e');
                return null;
              }
            }
          } catch (e) {
            print('❌ DIO CLIENT: Error in getAccessToken: $e');
            return null;
          }
        },
        getRefreshToken: () async {
          try {
            // Try enhanced system first
            if (TokenManagerIntegrationService.isEnhancedActive) {
              return await TokenManagerIntegrationService.getRefreshToken();
            }
            
            // Fallback to original system
            if (tokenStorage != null) {
              return await tokenStorage!.getRefreshToken();
            } else {
              try {
                final tokenManager = getIt<RantiPayTokenManager>();
                return await tokenManager.getRefreshToken();
              } catch (e) {
                print('❌ DIO CLIENT: GetIt fallback failed for refresh token: $e');
                return null;
              }
            }
          } catch (e) {
            print('❌ DIO CLIENT: Error in getRefreshToken: $e');
            return null;
          }
        },
        saveAccessToken: (token) async {
          try {
            if (TokenManagerIntegrationService.isEnhancedActive) {
              // Enhanced system doesn't use individual saves - handled internally
              return true;
            }
            return await (tokenStorage?.saveAccessToken(token) ?? Future.value(true));
          } catch (e) {
            print('❌ DIO CLIENT: Error saving access token: $e');
            return false;
          }
        },
        saveRefreshToken: (token) async {
          try {
            if (TokenManagerIntegrationService.isEnhancedActive) {
              // Enhanced system doesn't use individual saves - handled internally  
              return true;
            }
            return await (tokenStorage?.saveRefreshToken(token) ?? Future.value(true));
          } catch (e) {
            print('❌ DIO CLIENT: Error saving refresh token: $e');
            return false;
          }
        },
        refreshTokens: (refreshToken) async {
          try {
            if (TokenManagerIntegrationService.isEnhancedActive) {
              final newToken = await TokenManagerIntegrationService.forceRefreshTokens();
              if (newToken != null) {
                return {'access_token': newToken, 'refresh_token': refreshToken};
              }
              return null;
            }
            return await (tokenRefreshService?.refreshTokens(refreshToken) ?? Future.value(null));
          } catch (e) {
            print('❌ DIO CLIENT: Error refreshing tokens: $e');
            return null;
          }
        },
        onAuthenticationFailed: () {
          print('❌ DIO CLIENT: Authentication failed via Standard System');
          // Handle authentication failure
        },
      );

    print('✅ DIO CLIENT: Standard Auth Interceptor created');
    _dio.interceptors.add(authInterceptor);
    print('✅ DIO CLIENT: Standard Auth Interceptor added successfully');
    print('🔧 DIO CLIENT: Total interceptors after Standard Auth: ${_dio.interceptors.length}');
  }

  /// Add all interceptors
  void _addInterceptors() {
    // Error interceptor (first to catch all errors)
    _dio.interceptors.add(
      RantiPayErrorInterceptor(
        enableLogging: enableLogging,
      ),
    );

    // ✅ TEMP: Move auth interceptor to end to ensure it handles errors first

    // Request interceptor
    _dio.interceptors.add(
      RantiPayRequestInterceptor(
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
        enableLogging: enableLogging,
      ),
    );

    // Response interceptor
    _dio.interceptors.add(
      RantiPayResponseInterceptor(
        enableLogging: enableLogging,
        enableCaching: enableCaching,
      ),
    );

    // Retry interceptor (if enabled)
    if (enableRetry) {
      _dio.interceptors.add(
        RantiPayRetryInterceptor(
          networkInfo: networkInfo,
          maxRetryAttempts: RantiPayApiConfig.maxRetries,
        ),
      );
    }

    // Add any additional custom interceptors
    _dio.interceptors.addAll(additionalInterceptors);

    // ✅ AUTH INTERCEPTOR LAST: This ensures it handles errors FIRST (onError executes in reverse order)
    try {
      print('🔍 DIO CLIENT: Checking Enhanced Token System availability...');
      print('   - Enhanced Active: ${TokenManagerIntegrationService.isEnhancedActive}');

      final wrapper = TokenManagerIntegrationService.wrapper;
      print('   - Wrapper Available: ${wrapper != null}');
      print('   - Enhanced Manager Available: ${wrapper?.enhancedManager != null}');

      if (TokenManagerIntegrationService.isEnhancedActive &&
          wrapper != null &&
          wrapper.enhancedManager != null) {

        print('🚀 DIO CLIENT: Using Enhanced Auth Interceptor (LAST - handles errors first)');
        final enhancedInterceptor = EnhancedAuthInterceptor(
          tokenManager: wrapper.enhancedManager!,
          onAuthenticationFailed: () {
            print('❌ DIO CLIENT: Authentication failed via Enhanced System');
            // Handle authentication failure
          },
        );
        _dio.interceptors.add(enhancedInterceptor);
        print('✅ DIO CLIENT: Enhanced Auth Interceptor added successfully');
        print('🔧 DIO CLIENT: Total interceptors after Enhanced Auth: ${_dio.interceptors.length}');

      } else {
        print('🔄 DIO CLIENT: Using Standard Auth Interceptor (Enhanced not available) - LAST');
        print('   - Will use RantiPayAuthInterceptor instead (handles errors first)');
        _addStandardAuthInterceptor();
      }

    } catch (e) {
      print('⚠️ DIO CLIENT: Error setting up Enhanced Auth, falling back to Standard: $e');
      _addStandardAuthInterceptor();
    }
  }

  /// Create a new Dio instance for a specific service
  Dio createServiceClient(String serviceBaseUrl) {
    final serviceClient = Dio();

    // Copy base options
    serviceClient.options = _dio.options.copyWith(
      baseUrl: serviceBaseUrl,
    );

    // Copy interceptors
    serviceClient.interceptors.addAll(_dio.interceptors);

    // Debug: Log interceptors for service client
    print('🔧 SERVICE CLIENT: Created service client for $serviceBaseUrl');
    print('🔧 SERVICE CLIENT: Main Dio interceptors count: ${_dio.interceptors.length}');
    print('🔧 SERVICE CLIENT: Service client interceptors count: ${serviceClient.interceptors.length}');
    for (int i = 0; i < serviceClient.interceptors.length; i++) {
      final interceptor = serviceClient.interceptors[i];
      print('🔧 SERVICE CLIENT: Interceptor $i: ${interceptor.runtimeType}');
    }

    return serviceClient;
  }

  /// Update context headers (tenant, company, business)
  void updateContext({
    String? tenantId,
    String? companyId,
    String? businessId,
  }) {
    if (tenantId != null) {
      _dio.options.headers[RantiPayNetworkConstants.xTenantId] = tenantId;
    }
    if (companyId != null) {
      _dio.options.headers[RantiPayNetworkConstants.xCompanyId] = companyId;
    }
    if (businessId != null) {
      _dio.options.headers[RantiPayNetworkConstants.xBusinessId] = businessId;
    }
  }

  /// Clear all context headers
  void clearContext() {
    _dio.options.headers.remove(RantiPayNetworkConstants.xTenantId);
    _dio.options.headers.remove(RantiPayNetworkConstants.xCompanyId);
    _dio.options.headers.remove(RantiPayNetworkConstants.xBusinessId);
  }

  /// Perform GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Perform POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Perform PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Perform PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Perform DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options? options,
  }) {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }

// Agregar este método en RantiPayDioClient después de _addInterceptors()

  /// Agregar interceptor temporal para debug de errores 400
  void addDebugInterceptor() {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, handler) {
        print('🔴 ===== DEBUG ERROR INTERCEPTOR =====');
        print('🔴 URL: ${error.requestOptions.uri}');
        print('🔴 Status Code: ${error.response?.statusCode}');
        print('🔴 Error Type: ${error.type}');

        if (error.response != null) {
          print('🔴 Response Headers: ${error.response!.headers}');
          print('🔴 Response Body Raw: ${error.response!.data}');

          // Intentar parsear el body si es JSON
          try {
            if (error.response!.data is Map) {
              final json = error.response!.data as Map<String, dynamic>;
              print('🔴 Response Body JSON:');
              print('🔴   success: ${json['success']}');
              print('🔴   message: ${json['message']}');
              print('🔴   error: ${json['error']}');

              if (json['error'] != null && json['error'] is Map) {
                final errorData = json['error'] as Map<String, dynamic>;
                print('🔴   error.code: ${errorData['code']}');
                print('🔴   error.message: ${errorData['message']}');
                print('🔴   error.details: ${errorData['details']}');
              }
            }
          } catch (e) {
            print('🔴 Could not parse response body as JSON: $e');
          }
        }

        print('🔴 ===== END DEBUG ERROR =====\n');
        handler.next(error);
      },
    ));
  }

  /// Close Dio instance
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}

/// Factory for creating service-specific Dio clients
class RantiPayDioClientFactory {
  final RantiPayApiConfig apiConfig;
  final RantiPayNetworkInfo? networkInfo;
  final RantiPayTokenStorageMin? tokenStorage;
  final RantiPayTokenRefreshService? tokenRefreshService;

  RantiPayDioClientFactory({
    required this.apiConfig,
    this.networkInfo,
    this.tokenStorage,
    this.tokenRefreshService,
  });

  /// Create auth service client
  RantiPayDioClient createAuthClient() {
    return RantiPayDioClient(
      apiConfig: RantiPayApiConfig(
        baseUrl: RantiPayApiConfig.authServiceUrl,
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
      ),
      networkInfo: networkInfo,
      tokenStorage: null,
      tokenRefreshService: null,
    );
  }

  /// Create company service client
  RantiPayDioClient createCompanyClient() {
    return RantiPayDioClient(
      apiConfig: RantiPayApiConfig(
        baseUrl: RantiPayApiConfig.companyServiceUrl,
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
      ),
      networkInfo: networkInfo,
      tokenStorage: tokenStorage,
      tokenRefreshService: tokenRefreshService,
    );
  }

  /// Create electronic invoicing service client
  RantiPayDioClient createElectronicInvoicingClient() {
    return RantiPayDioClient(
      apiConfig: RantiPayApiConfig(
        baseUrl: RantiPayApiConfig.electronicInvoicingServiceUrl,
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
      ),
      networkInfo: networkInfo,
      tokenStorage: tokenStorage,
      tokenRefreshService: tokenRefreshService,
      enableLogging: true,
      enableRetry: true,
    );
  }

  /// Create HSM service client
  RantiPayDioClient createHsmClient() {
    return RantiPayDioClient(
      apiConfig: RantiPayApiConfig(
        baseUrl: RantiPayApiConfig.hsmServiceUrl,
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
      ),
      networkInfo: networkInfo,
      tokenStorage: tokenStorage,
      tokenRefreshService: tokenRefreshService,
      enableCertificatePinning: true,
    );
  }

  /// Create audit service client
  RantiPayDioClient createAuditClient() {
    return RantiPayDioClient(
      apiConfig: RantiPayApiConfig(
        baseUrl: RantiPayApiConfig.auditServiceUrl,
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
      ),
      networkInfo: networkInfo,
      tokenStorage: tokenStorage,
      tokenRefreshService: tokenRefreshService,
    );
  }

  /// Create compliance service client
  RantiPayDioClient createComplianceClient() {
    return RantiPayDioClient(
      apiConfig: RantiPayApiConfig(
        baseUrl: RantiPayApiConfig.complianceServiceUrl,
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
      ),
      networkInfo: networkInfo,
      tokenStorage: tokenStorage,
      tokenRefreshService: tokenRefreshService,
    );
  }

  /// Create privacy service client
  RantiPayDioClient createPrivacyClient() {
    return RantiPayDioClient(
      apiConfig: RantiPayApiConfig(
        baseUrl: RantiPayApiConfig.privacyServiceUrl,
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
      ),
      networkInfo: networkInfo,
      tokenStorage: tokenStorage,
      tokenRefreshService: tokenRefreshService,
    );
  }

  /// Create product service client
  RantiPayDioClient createProductClient() {
    return RantiPayDioClient(
      apiConfig: RantiPayApiConfig(
        baseUrl: RantiPayApiConfig.productServiceUrl,
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
      ),
      networkInfo: networkInfo,
      tokenStorage: tokenStorage,
      tokenRefreshService: tokenRefreshService,
      enableLogging: true,
      enableRetry: true,
    );
  }

  /// Create product advanced service client
  RantiPayDioClient createProductAdvancedClient() {
    return RantiPayDioClient(
      apiConfig: RantiPayApiConfig(
        baseUrl: RantiPayApiConfig.productAdvancedServiceUrl,
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
      ),
      networkInfo: networkInfo,
      tokenStorage: tokenStorage,
      tokenRefreshService: tokenRefreshService,
      enableLogging: true,
      enableRetry: true,
    );
  }

  /// Create Kong Gateway client
  RantiPayDioClient createKongGatewayClient() {
    return RantiPayDioClient(
      apiConfig: RantiPayApiConfig(
        baseUrl: RantiPayApiConfig.kongGatewayUrl,
        tenantId: apiConfig.tenantId,
        companyId: apiConfig.companyId,
        businessId: apiConfig.businessId,
        deviceId: apiConfig.deviceId,
        appVersion: apiConfig.appVersion,
      ),
      networkInfo: networkInfo,
      tokenStorage: tokenStorage,
      tokenRefreshService: tokenRefreshService,
      enableLogging: true,
      enableRetry: true,
    );
  }
}
