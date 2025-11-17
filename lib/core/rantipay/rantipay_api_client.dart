// lib/core/network/rantipay_api_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/config/rantipay_api_config.dart';
import 'package:rantipay_app/core/config/rantipay_enviroment.dart';
import 'package:rantipay_app/core/rantipay/rantipay_logger.dart';


/// RantiPay: Cliente HTTP para comunicación con APIs
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: Dio, Injectable, Logger
@lazySingleton
class RantiPayApiClient {
  final RantiPayLogger _logger;

  // Un Dio client por cada servicio
  late final Map<String, Dio> _serviceClients;

  RantiPayApiClient(this._logger) {
    _initializeServiceClients();
  }

  void _initializeServiceClients() {
    _serviceClients = {
      'kong_gateway': _createDioClient(RantiPayApiConfig.kongGatewayUrl),
      'auth': _createDioClient(RantiPayApiConfig.authServiceUrl),
      'company': _createDioClient(RantiPayApiConfig.companyServiceUrl),
      'hsm': _createDioClient(RantiPayApiConfig.hsmServiceUrl),
      'audit': _createDioClient(RantiPayApiConfig.auditServiceUrl),
      'compliance': _createDioClient(RantiPayApiConfig.complianceServiceUrl),
      'privacy': _createDioClient(RantiPayApiConfig.privacyServiceUrl),
    };
  }

  Dio _createDioClient(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: RantiPayApiConfig.connectTimeout,
      receiveTimeout: RantiPayApiConfig.receiveTimeout,
      sendTimeout: RantiPayApiConfig.sendTimeout,
      headers: RantiPayApiConfig.defaultHeaders,
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
    ));

    // Agregar interceptores básicos para logging
    if (RantiPayEnvironment.isDev) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    return dio;
  }

  // Getters para cada servicio
  Dio get auth => _serviceClients['auth']!;
  Dio get company => _serviceClients['company']!;
  Dio get hsm => _serviceClients['hsm']!;
  Dio get audit => _serviceClients['audit']!;
  Dio get compliance => _serviceClients['compliance']!;
  Dio get privacy => _serviceClients['privacy']!;

  // Generic HTTP methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool useAuth = true,
  }) async {
    final dio = _getDioForPath(path);
    return await dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool useAuth = true,
  }) async {
    final dio = _getDioForPath(path);
    return await dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool useAuth = true,
  }) async {
    final dio = _getDioForPath(path);
    return await dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool useAuth = true,
  }) async {
    final dio = _getDioForPath(path);
    return await dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool useAuth = true,
  }) async {
    final dio = _getDioForPath(path);
    return await dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Determinar qué cliente usar basado en el path
  Dio _getDioForPath(String path) {
    if (path.contains('/auth/') ||
        path.contains('/login') ||
        path.contains('/register')) {
      return auth;
    } else if (path.contains('/companies') || path.contains('/businesses')) {
      return company;
    } else if (path.contains('/hsm')) {
      return hsm;
    } else if (path.contains('/audit')) {
      return audit;
    } else if (path.contains('/compliance')) {
      return compliance;
    } else if (path.contains('/privacy')) {
      return privacy;
    }
    return auth; // Por defecto
  }

  // File upload
  Future<Response<T>> uploadFile<T>(
    String path, {
    required File file,
    String? fileName,
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    bool useAuth = true,
  }) async {
    try {
      final String name = fileName ?? file.path.split('/').last;
      final FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: name,
        ),
        if (additionalData != null) ...additionalData,
      });

      return await post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        useAuth: useAuth,
      );
    } catch (e) {
      _logger.error('Error uploading file', e);
      rethrow;
    }
  }

  // Health check
  Future<bool> checkHealth(String service) async {
    try {
      final dio = _serviceClients[service] ?? auth;
      final response = await dio.get(
        '/health',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.error('Health check failed for $service', e);
      return false;
    }
  }

  void updateEnvironment(String environment) {
    RantiPayEnvironment.setCurrent(environment);
    _initializeServiceClients(); // Recrear clientes con nuevas URLs
    _logger.info('API client environment updated to: $environment');
  }

  void cancelAllRequests() {
    for (final client in _serviceClients.values) {
      client.close();
    }
  }
}

// Batch request model
class BatchRequest {
  final String method;
  final String path;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final bool useAuth;

  BatchRequest({
    required this.method,
    required this.path,
    this.data,
    this.queryParameters,
    this.useAuth = true,
  });
}
