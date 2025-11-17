import 'dart:convert';

import 'package:dio/dio.dart';
import 'rantipay_exceptions.dart';

/// RantiPay: Interceptor de errores para Dio
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: dio, RantiPayExceptions, RantiPayErrorMapper
///
/// Uso:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(RantiPayErrorInterceptor());
/// ```
class RantiPayErrorInterceptor extends Interceptor {
  final bool enableLogging;

  RantiPayErrorInterceptor({
    this.enableLogging = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Agregar headers de tracking
    options.headers['X-Request-ID'] = _generateRequestId();
    options.headers['X-Request-Time'] = DateTime.now().toIso8601String();

    if (enableLogging) {
      print('🔵 REQUEST[${options.method}] => PATH: ${options.path}');
    }

    super.onRequest(options, handler);
  }

/*   @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enableLogging) {
      print(
          '🟢 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    }

    // Verificar si la respuesta tiene un error en el body
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;

      // Verificar estructura de error común
      if (data.containsKey('error') ||
          data.containsKey('errorCode') ||
          (data.containsKey('success') && data['success'] == false)) {
        final errorCode = data['errorCode'] ?? data['error']?['code'];
        final errorMessage = data['message'] ??
            data['error']?['message'] ??
            'Error en la respuesta del servidor';

        // Convertir a error
        final dioError = DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: {
            'code': errorCode,
            'message': errorMessage,
            'data': data,
          },
        );

        handler.reject(dioError);
        return;
      }
    }

    super.onResponse(response, handler);
  }
 */

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // COMENTAR O MODIFICAR ESTA LÓGICA:
    // if (response.data is Map && response.data['success'] == false) {
    //   handler.reject(DioException(
    //     requestOptions: response.requestOptions,
    //     response: response,
    //     type: DioExceptionType.badResponse,
    //   ));
    //   return;
    // }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enableLogging) {
      print('🔴 ERROR[${err.type}] => PATH: ${err.requestOptions.path}');
      print('🔴 MESSAGE: ${err.message}');

      if (err.response != null) {
        print('🔴 STATUS: ${err.response?.statusCode}');
        print('🔴 STATUS MESSAGE: ${err.response?.statusMessage}');
        print('🔴 HEADERS: ${err.response?.headers}');

        // Imprimir el body completo
        print('🔴 ===== RESPONSE BODY START =====');
        final responseData = err.response?.data;

        if (responseData == null) {
          print('🔴 Response data is NULL');
        } else {
          print('🔴 Response data type: ${responseData.runtimeType}');

          if (responseData is Map) {
            print('🔴 Response as Map:');
            responseData.forEach((key, value) {
              print('🔴   $key: $value (${value.runtimeType})');
            });

            // Si hay un campo error, imprimirlo en detalle
            if (responseData['error'] != null) {
              print('🔴 Error field details:');
              if (responseData['error'] is Map) {
                (responseData['error'] as Map).forEach((k, v) {
                  print('🔴   error.$k: $v');
                });
              } else {
                print('🔴   error: ${responseData['error']}');
              }
            }

            // Si hay validation_errors
            if (responseData['validation_errors'] != null) {
              print('🔴 Validation errors:');
              print('🔴   ${responseData['validation_errors']}');
            }

            // Si hay errors (otro formato común)
            if (responseData['errors'] != null) {
              print('🔴 Errors field:');
              print('🔴   ${responseData['errors']}');
            }
          } else if (responseData is String) {
            print('🔴 Response as String: $responseData');

            // Intentar parsear como JSON si es string
            try {
              final parsed = jsonDecode(responseData);
              print('🔴 Parsed String to JSON:');
              print('🔴   $parsed');
            } catch (e) {
              print('🔴 Could not parse string as JSON');
            }
          } else if (responseData is List) {
            print('🔴 Response as List:');
            print('🔴   $responseData');
          } else {
            print('🔴 Response (other type): $responseData');
          }
        }
        print('🔴 ===== RESPONSE BODY END =====');
      } else {
        print('🔴 No response object available');
      }
    }

    // ✅ CRITICAL FIX: Skip token-related 401 errors to allow AuthInterceptor to handle them
    if (err.response?.statusCode == 401) {
      final responseData = err.response?.data;
      if (responseData is Map<String, dynamic>) {
        final errorCode = responseData['errorCode'] as String? ??
            responseData['code'] as String? ??
            responseData['error'] as String?;
        final serverMessage = responseData['message'] as String?;

        if (errorCode == 'TOKEN_EXPIRED' ||
            errorCode == 'invalid_token' ||
            (serverMessage?.toLowerCase().contains('invalid token') == true) ||
            (serverMessage?.toLowerCase().contains('expired token') == true)) {
          print('🔄 ERROR INTERCEPTOR: Token error detected - passing to AuthInterceptor');
          print('   - Error code: $errorCode');
          print('   - Server message: $serverMessage');
          // Pass the error to the next interceptor (AuthInterceptor) without processing
          handler.next(err);
          return;
        }
      }
    }

    // Mapear el error a una excepción específica de RantiPay
    final exception = _mapDioErrorToException(err);

    // Crear un nuevo DioError con nuestra excepción
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: exception,
    );

    handler.reject(newError);
  }

  /// Mapea errores de Dio a excepciones de RantiPay
  RantiPayException _mapDioErrorToException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return RantiPayTimeoutException(
          message: 'Tiempo de espera agotado',
          endpoint: error.requestOptions.path,
          timeout: error.requestOptions.connectTimeout ??
              error.requestOptions.sendTimeout ??
              error.requestOptions.receiveTimeout,
        );

      case DioExceptionType.connectionError:
        return RantiPayNoInternetException(
          message: 'No se pudo conectar al servidor',
        );

      case DioExceptionType.cancel:
        return RantiPayNetworkException(
          message: 'Solicitud cancelada',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.badCertificate:
        return RantiPayNetworkException(
          message: 'Certificado SSL inválido',
        );

      case DioExceptionType.unknown:
      default:
        return RantiPayNetworkException(
          message: error.message ?? 'Error de red desconocido',
          endpoint: error.requestOptions.path,
        );
    }
  }

  /// Maneja errores de respuesta HTTP
  RantiPayException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final data = error.response?.data;

    // Extraer mensaje de error del response
    String? serverMessage;
    String? errorCode;
    Map<String, List<String>>? validationErrors;

    if (data is Map<String, dynamic>) {
      // Convertir valores a String? explícitamente
      serverMessage = data['message'] as String? ??
          (data['error'] is Map<String, dynamic>
              ? (data['error'] as Map<String, dynamic>)['message'] as String?
              : null) ??
          data['detail'] as String?;

      errorCode = data['errorCode'] as String? ??
          (data['error'] is Map<String, dynamic>
              ? (data['error'] as Map<String, dynamic>)['code'] as String?
              : null) ??
          data['code'] as String?;

      // Extraer errores de validación si existen
      if (data.containsKey('errors') && data['errors'] is Map) {
        validationErrors = {};
        final errors = data['errors'] as Map;
        errors.forEach((key, value) {
          if (value is List) {
            validationErrors![key.toString()] =
                value.map((e) => e.toString()).toList();
          } else if (value is String) {
            validationErrors![key.toString()] = [value];
          }
        });
      }
    }

    // Mapear por código de estado HTTP
    switch (statusCode) {
      case 400:
        // Bad Request - usualmente validación
        if (validationErrors != null && validationErrors.isNotEmpty) {
          return RantiPayValidationException(
            message: serverMessage ?? 'Error de validación',
            fieldErrors: validationErrors,
          );
        }
        return RantiPayNetworkException(
          message: serverMessage ?? 'Solicitud incorrecta',
          statusCode: statusCode,
          endpoint: error.requestOptions.path,
        );

      case 401:
        // Unauthorized
        if (errorCode == 'TOKEN_EXPIRED') {
          return const RantiPayTokenExpiredException();
        }
        return RantiPayUnauthorizedException(
          message: serverMessage ?? 'No autorizado',
        );

      case 403:
        // Forbidden - posiblemente nivel insuficiente
        if (errorCode?.startsWith('LEVEL') == true) {
          // Extraer niveles del mensaje o data
          final match = RegExp(r'nivel (\d+).*actual.*(\d+)').firstMatch(
            serverMessage ?? '',
          );
          if (match != null) {
            return RantiPayInsufficientLevelException(
              requiredLevel: int.parse(match.group(1)!),
              currentLevel: int.parse(match.group(2)!),
            );
          }
        }
        return RantiPayNetworkException(
          message: serverMessage ?? 'Acceso denegado',
          statusCode: statusCode,
          endpoint: error.requestOptions.path,
        );

      case 404:
        // Not Found
        return RantiPayNetworkException(
          message: serverMessage ?? 'Recurso no encontrado',
          statusCode: statusCode,
          endpoint: error.requestOptions.path,
        );

      case 409:
        // Conflict - posiblemente sincronización
        return RantiPaySyncConflictException(
          entityType: 'resource',
          entityId: error.requestOptions.path,
        );

      case 422:
        // Unprocessable Entity - validación de negocio
        return RantiPayValidationException(
          message: serverMessage ?? 'Entidad no procesable',
          fieldErrors: validationErrors,
        );

      case 429:
        // Too Many Requests
        return RantiPayLimitExceededException(
          limitType: 'rate',
          currentValue: 'exceeded',
          maxValue: 'limit',
        );

      case 500:
      case 502:
      case 503:
      case 504:
        // Server errors
        return RantiPayServerException(
          statusCode: statusCode,
          serverMessage: serverMessage ?? 'Error interno del servidor',
          response: data is Map<String, dynamic> ? data : null,
        );

      default:
        // Otros códigos
        return RantiPayNetworkException(
          message: serverMessage ?? 'Error HTTP $statusCode',
          statusCode: statusCode,
          endpoint: error.requestOptions.path,
        );
    }
  }

  /// Genera un ID único para la request
  String _generateRequestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toRadixString(36);
    return 'req_$random';
  }
}

/// Extension para facilitar el uso del interceptor
extension DioErrorInterceptorExtension on Dio {
  /// Agrega el interceptor de errores de RantiPay
  void addRantiPayErrorInterceptor({bool enableLogging = true}) {
    interceptors.add(RantiPayErrorInterceptor(enableLogging: enableLogging));
  }
}
