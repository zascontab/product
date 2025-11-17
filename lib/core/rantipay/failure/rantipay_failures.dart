import 'package:equatable/equatable.dart';

/// RantiPay: Definición de failures del sistema
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: equatable
///
/// Uso:
/// ```dart
/// // Retornar un failure
/// return Left(RantiPayInsufficientLevelFailure(
///   current: 1,
///   required: 2,
/// ));
/// ```

// Clase base para todos los failures de RantiPay
abstract class RantiPayFailure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;
  final DateTime timestamp;

  RantiPayFailure({
    required this.message,
    this.code,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [message, code, details, timestamp];

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
}

// Workaround para timestamp constante
class _ConstDateTime extends DateTime {
  _ConstDateTime() : super(0);
}

// ========== Failures de Autenticación ==========

/// Error de autenticación general
class RantiPayAuthFailure extends RantiPayFailure {
  RantiPayAuthFailure({
    super.message = 'Error de autenticación',
    super.code,
    super.details,
  });
}

/// Credenciales inválidas
class RantiPayInvalidCredentialsFailure extends RantiPayAuthFailure {
  RantiPayInvalidCredentialsFailure({
    super.message = 'Credenciales inválidas',
  }) : super(code: 'AUTH001');
}

/// Token expirado
class RantiPayTokenExpiredFailure extends RantiPayAuthFailure {
  RantiPayTokenExpiredFailure({
    super.message = 'Su sesión ha expirado',
  }) : super(code: 'AUTH002');
}

/// OTP inválido
class RantiPayInvalidOtpFailure extends RantiPayAuthFailure {
  final int? attemptsRemaining;

  RantiPayInvalidOtpFailure({
    super.message = 'Código OTP inválido',
    this.attemptsRemaining,
  }) : super(
          code: 'AUTH003',
          details: {'attemptsRemaining': attemptsRemaining},
        );
}

/// OTP expirado
class RantiPayOtpExpiredFailure extends RantiPayAuthFailure {
  RantiPayOtpExpiredFailure({
    super.message = 'El código OTP ha expirado',
  }) : super(code: 'AUTH004');
}

/// Cuenta bloqueada
class RantiPayAccountLockedFailure extends RantiPayAuthFailure {
  final Duration? lockDuration;

  RantiPayAccountLockedFailure({
    super.message = 'Cuenta bloqueada temporalmente',
    this.lockDuration,
  }) : super(
          code: 'AUTH005',
          details: {'lockDuration': lockDuration},
        );
}

// ========== Failures de Nivel de Usuario ==========

/// Nivel insuficiente
class RantiPayInsufficientLevelFailure extends RantiPayFailure {
  final int currentLevel;
  final int requiredLevel;
  final String? feature;

  RantiPayInsufficientLevelFailure({
    required this.currentLevel,
    required this.requiredLevel,
    this.feature,
  }) : super(
          message:
              'Nivel $requiredLevel requerido. Tu nivel actual es $currentLevel',
          code: 'LEVEL001',
          details: {
            'currentLevel': currentLevel,
            'requiredLevel': requiredLevel,
            'feature': feature,
          },
        );
}

/// Actualización de nivel en progreso
class RantiPayUpgradeInProgressFailure extends RantiPayFailure {
  final int targetLevel;
  final String? estimatedTime;

  RantiPayUpgradeInProgressFailure({
    required this.targetLevel,
    this.estimatedTime,
  }) : super(
          message: 'Actualización a nivel $targetLevel en progreso',
          code: 'LEVEL002',
          details: {
            'targetLevel': targetLevel,
            'estimatedTime': estimatedTime,
          },
        );
}

// ========== Failures de Límites ==========

/// Límite de transacción excedido
class RantiPayTransactionLimitFailure extends RantiPayFailure {
  final double amount;
  final double limit;
  final String limitType;

  RantiPayTransactionLimitFailure({
    required this.amount,
    required this.limit,
    required this.limitType,
  }) : super(
          message: 'Monto excede el límite $limitType de \$$limit',
          code: 'LIMIT001',
          details: {
            'amount': amount,
            'limit': limit,
            'limitType': limitType,
          },
        );
}

/// Límite de empresas alcanzado
class RantiPayCompanyLimitFailure extends RantiPayFailure {
  final int currentCount;
  final int maxAllowed;

  RantiPayCompanyLimitFailure({
    required this.currentCount,
    required this.maxAllowed,
  }) : super(
          message: 'Has alcanzado el límite de $maxAllowed empresas',
          code: 'LIMIT002',
          details: {
            'currentCount': currentCount,
            'maxAllowed': maxAllowed,
          },
        );
}

// ========== Failures de Compliance ==========

/// Error de compliance general
class RantiPayComplianceFailure extends RantiPayFailure {
  final String complianceType;
  final List<String>? violations;

  RantiPayComplianceFailure({
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
class RantiPaySoxValidationFailure extends RantiPayComplianceFailure {
  final double? soxScore;
  final double? requiredScore;

  RantiPaySoxValidationFailure({
    super.message = 'No cumple con los requisitos SOX',
    this.soxScore,
    this.requiredScore,
  }) : super(
          complianceType: 'SOX',
          violations: soxScore != null && requiredScore != null
              ? ['Score actual: $soxScore, Requerido: $requiredScore']
              : null,
        );
}

/// Error de auditoría
class RantiPayAuditFailure extends RantiPayComplianceFailure {
  RantiPayAuditFailure({
    super.message = 'Error en registro de auditoría',
    super.violations,
  }) : super(
          complianceType: 'AUDIT',
        );
}

// ========== Failures de HSM ==========

/// Error de operación HSM
class RantiPayHsmFailure extends RantiPayFailure {
  final String operation;
  final String? hsmErrorCode;

  RantiPayHsmFailure({
    required super.message,
    required this.operation,
    this.hsmErrorCode,
  }) : super(
          code: 'HSM001',
          details: {
            'operation': operation,
            'hsmErrorCode': hsmErrorCode,
          },
        );
}

// ========== Failures de Red ==========

/// Error de conexión
class RantiPayNetworkFailure extends RantiPayFailure {
  final int? statusCode;
  final String? endpoint;
  final String? type;

  RantiPayNetworkFailure({
    super.message = 'Error de conexión',
    this.statusCode,
    this.endpoint,
    this.type,
  }) : super(
          code: 'NET001',
          details: {
            'statusCode': statusCode,
            'endpoint': endpoint,
            'type': type,
          },
        );
}

/// Timeout de conexión
class RantiPayTimeoutFailure extends RantiPayNetworkFailure {
  final Duration? timeOut;

  RantiPayTimeoutFailure(
    this.timeOut, {
    super.message = 'Tiempo de espera agotado',
    Duration? timeout,
    super.endpoint,
  }) : super(
          statusCode: null,
        );
}

/// Sin conexión a internet
class RantiPayNoInternetFailure extends RantiPayNetworkFailure {
  RantiPayNoInternetFailure({
    super.message = 'Sin conexión a internet',
  });
}

// ========== Failures de Validación ==========

/// Error de validación de datos
class RantiPayValidationFailure extends RantiPayFailure {
  final Map<String, List<String>>? fieldErrors;

  RantiPayValidationFailure({
    super.message = 'Error de validación',
    this.fieldErrors,
  }) : super(
          code: 'VAL001',
          details: fieldErrors,
        );
}

// ========== Failures de Servidor ==========

/// Error del servidor
class RantiPayServerFailure extends RantiPayFailure {
  final String? statusCode;
  final String? serverMessage;

  RantiPayServerFailure({
    super.message = 'Error del servidor',
    this.statusCode,
    this.serverMessage,
  }) : super(
          code: 'SERVER001',
          details: {
            'statusCode': statusCode,
            'serverMessage': serverMessage,
          },
        );
}

// ========== Failures de Cache/Storage ==========

/// Error de almacenamiento local
class RantiPayCacheFailure extends RantiPayFailure {
  final String operation;

  RantiPayCacheFailure({
    super.message = 'Error de almacenamiento local',
    required this.operation,
  }) : super(
          code: 'CACHE001',
          details: {'operation': operation},
        );
}

// ========== Failures Genéricos ==========

/// Error desconocido
class RantiPayUnknownFailure extends RantiPayFailure {
  final Object? originalError;
  final StackTrace? stackTrace;

  RantiPayUnknownFailure({
    super.message = 'Ha ocurrido un error inesperado',
    this.originalError,
    this.stackTrace,
  }) : super(
          code: 'UNKNOWN001',
          details: {
            'originalError': originalError,
            'stackTrace': stackTrace,
          },
        );
}

/// Funcionalidad no disponible
class RantiPayFeatureNotAvailableFailure extends RantiPayFailure {
  final String feature;
  final String? reason;

  RantiPayFeatureNotAvailableFailure({
    required this.feature,
    this.reason,
  }) : super(
          message: 'Funcionalidad "$feature" no disponible',
          code: 'FEATURE001',
          details: {
            'feature': feature,
            'reason': reason,
          },
        );
}

// ========== Failures de Sincronización ==========

/// Error de sincronización
class RantiPaySyncFailure extends RantiPayFailure {
  final int? pendingOperations;
  final List<String>? failedOperations;

  RantiPaySyncFailure({
    super.message = 'Error de sincronización',
    this.pendingOperations,
    this.failedOperations,
  }) : super(
          code: 'SYNC001',
          details: {
            'pendingOperations': pendingOperations,
            'failedOperations': failedOperations,
          },
        );
}

/// Conflicto de sincronización
class RantiPaySyncConflictFailure extends RantiPaySyncFailure {
  final String? localVersion;
  final String? remoteVersion;

  RantiPaySyncConflictFailure({
    super.message = 'Conflicto de sincronización',
    this.localVersion,
    this.remoteVersion,
  }) : super(
          pendingOperations: null,
          failedOperations: null,
        );
}

class RantiPayAuthenticationFailure extends RantiPayFailure {
  final String? errorCode;
  final String? errorDescription;

  RantiPayAuthenticationFailure({
    super.message = 'Error de autenticación',
    this.errorCode,
    this.errorDescription,
  }) : super(
          code: 'AUTH_ERROR',
          details: {
            'errorCode': errorCode,
            'errorDescription': errorDescription,
          },
        );
}

class RantiPayPermissionFailure extends RantiPayFailure {
  final String? messages;
  final String? requiredLevel;

  RantiPayPermissionFailure({
    this.messages = 'Permiso denegado',
    this.requiredLevel,
  }) : super(
          message: messages ?? 'Permiso denegado',
          code: 'PERM001',
          details: {
            'requiredLevel': requiredLevel,
          },
        );
}
