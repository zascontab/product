/// RantiPay: Excepciones del sistema
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: Ninguna
///
/// Uso:
/// ```dart
/// // Lanzar excepción
/// throw RantiPayInsufficientLevelException(
///   currentLevel: 1,
///   requiredLevel: 2,
/// );
/// ```
library;

// Clase base para todas las excepciones de RantiPay
abstract class RantiPayException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const RantiPayException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
}

// ========== Excepciones de Autenticación ==========

/// Excepción de autenticación general
class RantiPayAuthException extends RantiPayException {
  const RantiPayAuthException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Credenciales inválidas
class RantiPayInvalidCredentialsException extends RantiPayAuthException {
  const RantiPayInvalidCredentialsException({
    super.message = 'Credenciales inválidas',
  }) : super(code: 'AUTH001');
}

/// Token expirado
class RantiPayTokenExpiredException extends RantiPayAuthException {
  const RantiPayTokenExpiredException({
    super.message = 'Token expirado',
  }) : super(code: 'AUTH002');
}

/// Token inválido
class RantiPayInvalidTokenException extends RantiPayAuthException {
  const RantiPayInvalidTokenException({
    super.message = 'Token inválido',
  }) : super(code: 'AUTH003');
}

/// Sin autorización
class RantiPayUnauthorizedException extends RantiPayAuthException {
  const RantiPayUnauthorizedException({
    super.message = 'No autorizado',
  }) : super(code: 'AUTH004');
}

// ========== Excepciones de Nivel ==========

/// Nivel insuficiente
class RantiPayInsufficientLevelException extends RantiPayException {
  final int currentLevel;
  final int requiredLevel;

   RantiPayInsufficientLevelException({
    required this.currentLevel,
    required this.requiredLevel,
    String? feature,
  }) : super(
          message: 'Nivel $requiredLevel requerido (actual: $currentLevel)',
          code: 'LEVEL001',
          details: {
            'currentLevel': currentLevel,
            'requiredLevel': requiredLevel,
            'feature': feature,
          },
        );
}

/// Actualización en progreso
class RantiPayUpgradeException extends RantiPayException {
  final int targetLevel;

   RantiPayUpgradeException({
    required this.targetLevel,
    String? estimatedTime,
  }) : super(
          message: 'Actualización a nivel $targetLevel en progreso',
          code: 'LEVEL002',
          details: {
            'targetLevel': targetLevel,
            'estimatedTime': estimatedTime,
          },
        );
}

// ========== Excepciones de Compliance ==========

/// Excepción de compliance
class RantiPayComplianceException extends RantiPayException {
  final String complianceType;
  final List<String>? violations;

  RantiPayComplianceException({
    required super.message,
    required this.complianceType,
    this.violations,
  }) : super(
          code: 'COMP001',
          details: {
            'complianceType': complianceType,
            'violations': violations,
          },
        );
}

/// Validación SOX fallida
class RantiPaySoxException extends RantiPayComplianceException {
   RantiPaySoxException({
    super.message = 'Validación SOX fallida',
    super.violations,
  }) : super(
          complianceType: 'SOX',
        );
}

/// Error de auditoría
class RantiPayAuditException extends RantiPayComplianceException {
   RantiPayAuditException({
    super.message = 'Error de auditoría',
    super.violations,
  }) : super(
          complianceType: 'AUDIT',
        );
}

// ========== Excepciones de HSM ==========

/// Excepción de HSM
class RantiPayHsmException extends RantiPayException {
  final String operation;

   RantiPayHsmException({
    required super.message,
    required this.operation,
    String? hsmErrorCode,
  }) : super(
          code: 'HSM001',
          details: {
            'operation': operation,
            'hsmErrorCode': hsmErrorCode,
          },
        );
}

// ========== Excepciones de Red ==========

/// Excepción de red
class RantiPayNetworkException extends RantiPayException {
  final int? statusCode;
  final String? endpoint;

   RantiPayNetworkException({
    required super.message,
    this.statusCode,
    this.endpoint,
  }) : super(
          code: 'NET001',
          details: {
            'statusCode': statusCode,
            'endpoint': endpoint,
          },
        );
}

/// Timeout
class RantiPayTimeoutException extends RantiPayNetworkException {
   RantiPayTimeoutException({
    super.message = 'Timeout de conexión',
    super.endpoint,
    Duration? timeout,
  });
}

/// Sin internet
class RantiPayNoInternetException extends RantiPayNetworkException {
   RantiPayNoInternetException({
    super.message = 'Sin conexión a internet',
  });
}

// ========== Excepciones de Servidor ==========

/// Error del servidor
class RantiPayServerException extends RantiPayException {
  final int statusCode;
  final String? serverMessage;
  final Map<String, dynamic>? response;

   RantiPayServerException({
    required this.statusCode,
    this.serverMessage,
    this.response,
  }) : super(
          message: serverMessage ?? 'Error del servidor ($statusCode)',
          code: 'SERVER001',
          details: {
            'statusCode': statusCode,
            'serverMessage': serverMessage,
            'response': response,
          },
        );
}

// ========== Excepciones de Validación ==========

/// Error de validación
class RantiPayValidationException extends RantiPayException {
  final Map<String, List<String>>? fieldErrors;

  const RantiPayValidationException({
    super.message = 'Error de validación',
    this.fieldErrors,
  }) : super(
          code: 'VAL001',
          details: fieldErrors,
        );
}

/// Campo requerido
class RantiPayRequiredFieldException extends RantiPayValidationException {
   RantiPayRequiredFieldException({
    required String fieldName,
  }) : super(
          message: 'El campo "$fieldName" es requerido',
          fieldErrors: {
            fieldName: ['Campo requerido'],
          },
        );
}

// ========== Excepciones de Cache ==========

/// Error de cache
class RantiPayCacheException extends RantiPayException {
  final String operation;

   RantiPayCacheException({
    required super.message,
    required this.operation,
  }) : super(
          code: 'CACHE001',
          details: {'operation': operation},
        );
}

// ========== Excepciones de Parsing ==========

/// Error de parsing
class RantiPayParsingException extends RantiPayException {
  final Type expectedType;
  final dynamic actualValue;

   RantiPayParsingException({
    required this.expectedType,
    this.actualValue,
  }) : super(
          message: 'Error parseando a $expectedType',
          code: 'PARSE001',
          details: {
            'expectedType': expectedType,
            'actualValue': actualValue,
          },
        );
}

// ========== Excepciones de Límites ==========

/// Límite excedido
class RantiPayLimitExceededException extends RantiPayException {
  final String limitType;
  final dynamic currentValue;
  final dynamic maxValue;

   RantiPayLimitExceededException({
    required this.limitType,
    required this.currentValue,
    required this.maxValue,
  }) : super(
          message: 'Límite de $limitType excedido: $currentValue > $maxValue',
          code: 'LIMIT001',
          details: {
            'limitType': limitType,
            'currentValue': currentValue,
            'maxValue': maxValue,
          },
        );
}

// ========== Excepciones de Funcionalidad ==========

/// Funcionalidad no implementada
class RantiPayNotImplementedException extends RantiPayException {
   RantiPayNotImplementedException({
    required String feature,
  }) : super(
          message: 'Funcionalidad "$feature" no implementada',
          code: 'IMPL001',
          details: {'feature': feature},
        );
}

/// Funcionalidad deshabilitada
class RantiPayFeatureDisabledException extends RantiPayException {
   RantiPayFeatureDisabledException({
    required String feature,
    String? reason,
  }) : super(
          message: 'Funcionalidad "$feature" deshabilitada',
          code: 'FEATURE001',
          details: {
            'feature': feature,
            'reason': reason,
          },
        );
}

// ========== Excepciones de Sincronización ==========

/// Error de sincronización
class RantiPaySyncException extends RantiPayException {
   RantiPaySyncException({
    required super.message,
    List<String>? failedOperations,
  }) : super(
          code: 'SYNC001',
          details: {'failedOperations': failedOperations},
        );
}

/// Conflicto de sincronización
class RantiPaySyncConflictException extends RantiPaySyncException {
   RantiPaySyncConflictException({
    required String entityType,
    required String entityId,
    String? localVersion,
    String? remoteVersion,
  }) : super(
          message: 'Conflicto sincronizando $entityType:$entityId',
          failedOperations: ['$entityType:$entityId'],
        );
}
