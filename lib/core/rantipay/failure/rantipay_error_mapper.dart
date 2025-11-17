import 'package:dio/dio.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/common/api_response_entity.dart';

import 'rantipay_exceptions.dart';
import 'rantipay_failures.dart';

/// RantiPay: Mapeador de errores
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: RantiPayExceptions, RantiPayFailures
///
/// Uso:
/// ```dart
/// try {
///   // código que puede fallar
/// } catch (e) {
///   final failure = RantiPayErrorMapper.mapExceptionToFailure(e);
/// }
/// ```
class RantiPayErrorMapper {
  // Prevenir instanciación
  RantiPayErrorMapper._();

  /// Mapea cualquier excepción a un Failure
  static RantiPayFailure mapExceptionToFailure(dynamic exception) {
    // Si ya es un Failure, retornarlo
    if (exception is RantiPayFailure) {
      return exception;
    }

    // Mapear excepciones de RantiPay
    if (exception is RantiPayException) {
      return _mapRantiPayException(exception);
    }

    // Mapear errores de Dio
    if (exception is DioException) {
      return _mapDioException(exception);
    }

    // Mapear errores comunes de Dart
    if (exception is FormatException) {
      return RantiPayValidationFailure(
        message: 'Formato inválido: ${exception.message}',
      );
    }

    if (exception is TypeError) {
      return RantiPayValidationFailure(
        message: 'Error de tipo: ${exception.toString()}',
      );
    }

    if (exception is RangeError) {
      return RantiPayValidationFailure(
        message: 'Valor fuera de rango: ${exception.message}',
      );
    }

    // Error desconocido
    return RantiPayUnknownFailure(
      message: 'Error inesperado',
      originalError: exception,
      stackTrace: exception is Error ? exception.stackTrace : null,
    );
  }

  /// Mapea excepciones de RantiPay a Failures
  /// Mapea excepciones de RantiPay a Failures
  static RantiPayFailure _mapRantiPayException(RantiPayException exception) {
    // Mapeo de Auth
    if (exception is RantiPayInvalidCredentialsException) {
      return RantiPayInvalidCredentialsFailure();
    }

    if (exception is RantiPayTokenExpiredException) {
      return RantiPayTokenExpiredFailure();
    }

    if (exception is RantiPayUnauthorizedException) {
      return RantiPayAuthFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    // Mapeo de Nivel
    if (exception is RantiPayInsufficientLevelException) {
      return RantiPayInsufficientLevelFailure(
        currentLevel: exception.currentLevel,
        requiredLevel: exception.requiredLevel,
        feature: exception.details?['feature'],
      );
    }

    if (exception is RantiPayUpgradeException) {
      return RantiPayUpgradeInProgressFailure(
        targetLevel: exception.targetLevel,
        estimatedTime: exception.details?['estimatedTime'],
      );
    }

    // Mapeo de Compliance
    if (exception is RantiPaySoxException) {
      return RantiPaySoxValidationFailure(
        message: exception.message,
        soxScore: exception.details?['soxScore'],
        requiredScore: exception.details?['requiredScore'],
      );
    }

    if (exception is RantiPayAuditException) {
      return RantiPayAuditFailure(
        message: exception.message,
        violations: exception.violations,
      );
    }

    if (exception is RantiPayComplianceException) {
      return RantiPayComplianceFailure(
        message: exception.message,
        complianceType: exception.complianceType,
        violations: exception.violations,
      );
    }

    // Mapeo de HSM
    if (exception is RantiPayHsmException) {
      return RantiPayHsmFailure(
        message: exception.message,
        operation: exception.operation,
        hsmErrorCode: exception.details?['hsmErrorCode'],
      );
    }

    // Mapeo de Red
    if (exception is RantiPayTimeoutException) {
      return RantiPayTimeoutFailure(
        exception.details?['timeout'] as Duration?, // Corregido
        message: exception.message,
        endpoint: exception.endpoint,
      );
    }

    if (exception is RantiPayNoInternetException) {
      return RantiPayNoInternetFailure();
    }

    if (exception is RantiPayNetworkException) {
      return RantiPayNetworkFailure(
        message: exception.message,
        statusCode: exception.statusCode,
        endpoint: exception.endpoint,
      );
    }

    // Mapeo de Servidor
    if (exception is RantiPayServerException) {
      return RantiPayServerFailure(
        message: exception.message,
        statusCode: exception.statusCode.toString(),
        serverMessage: exception.serverMessage,
      );
    }

    // Mapeo de Validación
    if (exception is RantiPayValidationException) {
      return RantiPayValidationFailure(
        message: exception.message,
        fieldErrors: exception.fieldErrors,
      );
    }

    // Mapeo de Límites
    if (exception is RantiPayLimitExceededException) {
      if (exception.limitType == 'transaction') {
        return RantiPayTransactionLimitFailure(
          amount: exception.currentValue as double,
          limit: exception.maxValue as double,
          limitType: exception.details?['limitType'] ?? 'daily',
        );
      }

      if (exception.limitType == 'company') {
        return RantiPayCompanyLimitFailure(
          currentCount: exception.currentValue as int,
          maxAllowed: exception.maxValue as int,
        );
      }
    }

    // Mapeo de Cache
    if (exception is RantiPayCacheException) {
      return RantiPayCacheFailure(
        message: exception.message,
        operation: exception.operation,
      );
    }

    // Mapeo de Sincronización
    if (exception is RantiPaySyncConflictException) {
      return RantiPaySyncConflictFailure(
        message: exception.message,
        localVersion: exception.details?['localVersion'],
        remoteVersion: exception.details?['remoteVersion'],
      );
    }

    if (exception is RantiPaySyncException) {
      return RantiPaySyncFailure(
        message: exception.message,
        failedOperations: exception.details?['failedOperations'],
      );
    }

    // Mapeo de Funcionalidad
    if (exception is RantiPayFeatureDisabledException) {
      return RantiPayFeatureNotAvailableFailure(
        feature: exception.details?['feature'] ?? 'unknown',
        reason: exception.details?['reason'],
      );
    }

    // Default
    return RantiPayUnknownFailure(
      message: exception.message,
      originalError: exception,
    );
  }

  /// Mapea errores de Dio a Failures
  /// Mapea errores de Dio a Failures
  static RantiPayFailure _mapDioException(DioException exception) {
    // Si el error ya contiene una excepción de RantiPay, mapearla
    if (exception.error is RantiPayException) {
      return _mapRantiPayException(exception.error as RantiPayException);
    }

    // Mapear por tipo de error
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return RantiPayTimeoutFailure(
          null, // Corregido
          endpoint: exception.requestOptions.path,
        );

      case DioExceptionType.connectionError:
        return RantiPayNoInternetFailure();

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode ?? 0;

        if (statusCode == 401) {
          return RantiPayTokenExpiredFailure();
        }

        if (statusCode >= 500) {
          return RantiPayServerFailure(
            statusCode: statusCode.toString(),
            serverMessage: exception.response?.data?.toString(),
          );
        }

        return RantiPayNetworkFailure(
          message: 'Error HTTP $statusCode',
          statusCode: statusCode,
          endpoint: exception.requestOptions.path,
        );

      default:
        return RantiPayNetworkFailure(
          message: exception.message ?? 'Error de red',
          endpoint: exception.requestOptions.path,
        );
    }
  }

  /// Mapea códigos de error del backend a Failures (RantiPayFailure)
  static RantiPayFailure mapDioErrorToFailure(
    DioException exception, {
    String? errorCode,
    Map<String, dynamic>? data,
  }) {
    // Si el error ya contiene una excepción de RantiPay, mapearla
    if (exception.error is RantiPayException) {
      return _mapRantiPayException(exception.error as RantiPayException);
    }

    // Extraer el código de error y los datos de la excepción
    if (exception.response != null) {
      var responseData = exception.response!.data;
      if (responseData is Map) {
        // Usar casting seguro para errorCode
        errorCode = responseData['error']?['code']?.toString() ?? errorCode;

        // Verificar si 'error' es un Map antes de hacer el casting
        if (responseData['error'] is Map) {
          data = responseData['error'] as Map<String, dynamic>;
        }
      }
    }

    // Mapear el código de error específico
    return mapErrorCode(errorCode!, data);
  }

  static RantiPayFailure mapApiResponseError(
      RantiPayApiResponseEntity apiResponse) {
    if (apiResponse.error?.code == 'insufficient_level') {
      return RantiPayInsufficientLevelFailure(
        currentLevel: apiResponse.error?.details?['currentLevel'] ?? 1,
        requiredLevel: apiResponse.error?.details?['requiredLevel'] ?? 2,
      );
    }

    if (apiResponse.error?.code == 'no_permission') {
      return RantiPayPermissionFailure();
    }

    // Otros mapeos específicos...

    return RantiPayServerFailure(
      message: apiResponse.message ?? 'Error del servidor',
      statusCode: apiResponse.error?.code ?? 'unknown_error',
    );
  }

  static RantiPayFailure mapPermissionError(
      RantiPayApiResponseEntity apiResponse) {
    return RantiPayPermissionFailure(
      requiredLevel: apiResponse.error?.code,
    );
  }

  /// Mapea códigos de error del backend a Failures
  static RantiPayFailure mapErrorCode(String errorCode,
      [Map<String, dynamic>? data]) {
    // Mapeo por prefijo de código
    if (errorCode.startsWith('AUTH')) {
      return _mapAuthErrorCode(errorCode, data);
    }

    if (errorCode.startsWith('LEVEL')) {
      return _mapLevelErrorCode(errorCode, data);
    }

    if (errorCode.startsWith('COMP')) {
      return _mapComplianceErrorCode(errorCode, data);
    }

    if (errorCode.startsWith('LIMIT')) {
      return _mapLimitErrorCode(errorCode, data);
    }

    if (errorCode.startsWith('VAL')) {
      return _mapValidationErrorCode(errorCode, data);
    }

    // Código desconocido
    return RantiPayUnknownFailure(
      message: 'Error con código: $errorCode',
      originalError: {'code': errorCode, 'data': data},
    );
  }

  static RantiPayFailure _mapAuthErrorCode(
      String code, Map<String, dynamic>? data) {
    switch (code) {
      case 'AUTH001':
        return RantiPayInvalidCredentialsFailure();
      case 'AUTH002':
        return RantiPayTokenExpiredFailure();
      case 'AUTH003':
        return RantiPayInvalidOtpFailure(
          attemptsRemaining: data?['attemptsRemaining'],
        );
      case 'AUTH004':
        return RantiPayOtpExpiredFailure();
      case 'AUTH005':
        return RantiPayAccountLockedFailure(
          lockDuration: data?['lockDuration'] != null
              ? Duration(seconds: data!['lockDuration'])
              : null,
        );
      default:
        return RantiPayAuthFailure(
          message: data?['message'] ?? 'Error de autenticación',
          code: code,
        );
    }
  }

  static RantiPayFailure _mapLevelErrorCode(
      String code, Map<String, dynamic>? data) {
    switch (code) {
      case 'LEVEL001':
        return RantiPayInsufficientLevelFailure(
          currentLevel: data?['currentLevel'] ?? 0,
          requiredLevel: data?['requiredLevel'] ?? 0,
          feature: data?['feature'],
        );
      case 'LEVEL002':
        return RantiPayUpgradeInProgressFailure(
          targetLevel: data?['targetLevel'] ?? 0,
          estimatedTime: data?['estimatedTime'],
        );
      default:
        return RantiPayUnknownFailure(
          message: data?['message'] as String? ?? 'Error de nivel',
          originalError: {'code': code, 'data': data},
        );
    }
  }

  static RantiPayFailure _mapComplianceErrorCode(
      String code, Map<String, dynamic>? data) {
    switch (code) {
      case 'COMP001':
        final complianceType = data?['complianceType'] ?? 'UNKNOWN';
        if (complianceType == 'SOX') {
          return RantiPaySoxValidationFailure(
            message: data?['message'] ?? 'Validación SOX fallida',
            soxScore: data?['soxScore'],
            requiredScore: data?['requiredScore'],
          );
        }
        return RantiPayComplianceFailure(
          message: data?['message'] ?? 'Error de compliance',
          complianceType: complianceType,
          violations: data?['violations'] != null
              ? List<String>.from(data!['violations'])
              : null,
        );
      default:
        return RantiPayComplianceFailure(
          message: data?['message'] ?? 'Error de compliance',
          complianceType: 'UNKNOWN',
        );
    }
  }

  static RantiPayFailure _mapLimitErrorCode(
      String code, Map<String, dynamic>? data) {
    switch (code) {
      case 'LIMIT001':
        return RantiPayTransactionLimitFailure(
          amount: data?['amount']?.toDouble() ?? 0,
          limit: data?['limit']?.toDouble() ?? 0,
          limitType: data?['limitType'] ?? 'daily',
        );
      case 'LIMIT002':
        return RantiPayCompanyLimitFailure(
          currentCount: data?['currentCount'] ?? 0,
          maxAllowed: data?['maxAllowed'] ?? 0,
        );
      default:
        return RantiPayUnknownFailure(
          message: data?['message'] as String? ?? 'Límite excedido',
          originalError: {'code': code, 'data': data},
        );
    }
  }

  static RantiPayFailure _mapValidationErrorCode(
      String code, Map<String, dynamic>? data) {
    return RantiPayValidationFailure(
      message: data?['message'] ?? 'Error de validación',
      fieldErrors: data?['errors'] != null
          ? Map<String, List<String>>.from(
              (data!['errors'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  value is List
                      ? value.map((e) => e.toString()).toList()
                      : [value.toString()],
                ),
              ),
            )
          : null,
    );
  }
}
