// lib/core/errors/rantipay_failures_additional.dart


import 'package:rantipay_app/core/rantipay/failure/rantipay_database_exception.dart';
import 'package:rantipay_app/core/rantipay/failure/rantipay_error_mapper.dart';
import 'package:rantipay_app/core/rantipay/failure/rantipay_exceptions.dart';

import 'rantipay_failures.dart';
import 'rantipay_database_errors.dart';

// ========== Failures de Base de Datos ==========

/// Error de base de datos
class RantiPayDatabaseFailure extends RantiPayFailure {
  final DatabaseErrorType? errorType;
  final String? operation;

  RantiPayDatabaseFailure(
    String message, {
    this.errorType,
    this.operation,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'DB001',
          details: {
            'errorType': errorType?.name,
            'operation': operation,
            ...?details as Map<String, dynamic>?,
          },
        );

  // Factory constructors para tipos específicos de errores
  factory RantiPayDatabaseFailure.notFound(String entity, String id) {
    return RantiPayDatabaseFailure(
      '$entity con ID $id no encontrado',
      errorType: DatabaseErrorType.notFound,
      code: 'DB_NOT_FOUND',
    );
  }

  factory RantiPayDatabaseFailure.constraintViolation(String constraint) {
    return RantiPayDatabaseFailure(
      'Violación de restricción: $constraint',
      errorType: DatabaseErrorType.constraintViolation,
      code: 'DB_CONSTRAINT',
    );
  }

  factory RantiPayDatabaseFailure.connectionError() {
    return RantiPayDatabaseFailure(
      'Error de conexión a la base de datos',
      errorType: DatabaseErrorType.connectionError,
      code: 'DB_CONNECTION',
    );
  }

  factory RantiPayDatabaseFailure.timeout(String operation) {
    return RantiPayDatabaseFailure(
      'Timeout en operación: $operation',
      errorType: DatabaseErrorType.timeout,
      operation: operation,
      code: 'DB_TIMEOUT',
    );
  }

  factory RantiPayDatabaseFailure.permissionDenied() {
    return RantiPayDatabaseFailure(
      'Permiso denegado para acceder a la base de datos',
      errorType: DatabaseErrorType.permissionDenied,
      code: 'DB_PERMISSION',
    );
  }

  factory RantiPayDatabaseFailure.diskFull() {
    return RantiPayDatabaseFailure(
      'Espacio en disco insuficiente',
      errorType: DatabaseErrorType.diskFull,
      code: 'DB_DISK_FULL',
    );
  }

  factory RantiPayDatabaseFailure.corruptData(String table) {
    return RantiPayDatabaseFailure(
      'Datos corruptos detectados en tabla: $table',
      errorType: DatabaseErrorType.corruptData,
      code: 'DB_CORRUPT',
    );
  }

  factory RantiPayDatabaseFailure.migrationFailed(
      int fromVersion, int toVersion) {
    return RantiPayDatabaseFailure(
      'Migración fallida de versión $fromVersion a $toVersion',
      errorType: DatabaseErrorType.migrationFailed,
      code: 'DB_MIGRATION',
      details: {
        'fromVersion': fromVersion,
        'toVersion': toVersion,
      },
    );
  }

  // Crear desde DatabaseError
  factory RantiPayDatabaseFailure.fromDatabaseError(DatabaseError error) {
    return RantiPayDatabaseFailure(
      error.message,
      errorType: error.type,
      details: {
        'originalDetails': error.details,
        'originalException': error.originalException?.toString(),
      },
    );
  }
}

// ========== Failures de Estado Offline ==========

/// Error por estar offline
class RantiPayOfflineFailure extends RantiPayFailure {
  final String? requiredOperation;
  final bool canRetryLater;

  RantiPayOfflineFailure(
    String message, {
    this.requiredOperation,
    this.canRetryLater = true,
  }) : super(
          message: message,
          code: 'OFFLINE001',
          details: {
            'requiredOperation': requiredOperation,
            'canRetryLater': canRetryLater,
          },
        );

  // Factory para operaciones comunes
  factory RantiPayOfflineFailure.syncRequired() {
    return RantiPayOfflineFailure(
      'Se requiere conexión para sincronizar datos',
      requiredOperation: 'sync',
    );
  }

  factory RantiPayOfflineFailure.downloadRequired() {
    return RantiPayOfflineFailure(
      'Se requiere conexión para descargar datos',
      requiredOperation: 'download',
    );
  }

  factory RantiPayOfflineFailure.verificationRequired() {
    return RantiPayOfflineFailure(
      'Se requiere conexión para verificar información',
      requiredOperation: 'verification',
    );
  }
}

// ========== Failures de Búsqueda/Not Found ==========

/// Recurso no encontrado
class RantiPayNotFoundFailure extends RantiPayFailure {
  final String resourceType;
  final String? resourceId;
  final String? searchCriteria;

  RantiPayNotFoundFailure(
    String message, {
    this.resourceType = 'Recurso',
    this.resourceId,
    this.searchCriteria,
  }) : super(
          message: message,
          code: 'NOT_FOUND',
          details: {
            'resourceType': resourceType,
            'resourceId': resourceId,
            'searchCriteria': searchCriteria,
          },
        );

  // Factory constructors para recursos específicos
  factory RantiPayNotFoundFailure.user(String userId) {
    return RantiPayNotFoundFailure(
      'Usuario no encontrado',
      resourceType: 'User',
      resourceId: userId,
    );
  }

  factory RantiPayNotFoundFailure.company(String companyId) {
    return RantiPayNotFoundFailure(
      'Empresa no encontrada',
      resourceType: 'Company',
      resourceId: companyId,
    );
  }

  factory RantiPayNotFoundFailure.business(String businessId) {
    return RantiPayNotFoundFailure(
      'Negocio no encontrado',
      resourceType: 'Business',
      resourceId: businessId,
    );
  }

  factory RantiPayNotFoundFailure.byEmail(String email) {
    return RantiPayNotFoundFailure(
      'No se encontró usuario con email: $email',
      resourceType: 'User',
      searchCriteria: 'email=$email',
    );
  }

  factory RantiPayNotFoundFailure.byPhone(String phone) {
    return RantiPayNotFoundFailure(
      'No se encontró usuario con teléfono: $phone',
      resourceType: 'User',
      searchCriteria: 'phone=$phone',
    );
  }

  factory RantiPayNotFoundFailure.generic() {
    return RantiPayNotFoundFailure(
      'Recurso no encontrado',
    );
  }
}

// ========== Failures Inesperados ==========

/// Error inesperado/desconocido
class RantiPayUnexpectedFailure extends RantiPayFailure {
  final Object? originalError;
  final StackTrace? stackTrace;
  final String? context;
  @override
  final String? code;

  RantiPayUnexpectedFailure(
    String message, {
    this.originalError,
    this.stackTrace,
    this.context,
    this.code,
  }) : super(
          message: message,
          code: code,
          details: {
            'originalError': originalError?.toString(),
            'errorType': originalError?.runtimeType.toString(),
            'context': context,
            'stackTrace': stackTrace?.toString(),
          },
        );

  // Factory con mensaje por defecto
  factory RantiPayUnexpectedFailure.withError(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    return RantiPayUnexpectedFailure(
      'Error inesperado: ${error.toString()}',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  // Factory para errores en operaciones específicas
  factory RantiPayUnexpectedFailure.inOperation(
    String operation,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    return RantiPayUnexpectedFailure(
      'Error inesperado durante: $operation',
      originalError: error,
      stackTrace: stackTrace,
      context: operation,
    );
  }
}

// ========== Extension para facilitar creación de failures ==========

extension FailureHelpers on Object {
  /// Convierte cualquier error a RantiPayFailure
  RantiPayFailure toRantiPayFailure([String? context]) {
    // Si ya es un failure, retornarlo
    if (this is RantiPayFailure) {
      return this as RantiPayFailure;
    }

    // Si es una excepción conocida, usar el mapper
    if (this is RantiPayException) {
      return RantiPayErrorMapper.mapExceptionToFailure(this);
    }

    // Si es un DatabaseError
    if (this is DatabaseError) {
      return RantiPayDatabaseFailure.fromDatabaseError(this as DatabaseError);
    }

    // Para cualquier otro error
    return RantiPayUnexpectedFailure.withError(
      this,
      this is Error ? (this as Error).stackTrace : null,
    );
  }
}

// ========== Failure Helper para el Repository ==========

/// Helper para manejar failures en el repository
class RantiPayRepositoryFailureHelper {
  // Prevenir instanciación
  RantiPayRepositoryFailureHelper._();

  /// Maneja errores de base de datos
  static RantiPayFailure handleDatabaseError(
    Object error,
    String operation,
  ) {
    if (error is RantiPayDatabaseException) {
      return RantiPayDatabaseFailure(
        error.message,
        operation: operation,
        details: {
          'code': error.code,
          'originalError': error.originalError?.toString(),
        },
      );
    }

    return RantiPayDatabaseFailure(
      'Error en base de datos durante: $operation',
      operation: operation,
      errorType: DatabaseErrorType.unknown,
    );
  }

  /// Maneja errores de red
  static RantiPayFailure handleNetworkError(
    Object error,
    String endpoint,
  ) {
    if (error is RantiPayNetworkException) {
      return RantiPayServerFailure(
        message: error.message,
        statusCode:
            error.statusCode != null ? error.statusCode.toString() : '500',
        serverMessage: error.message,
      );
    }

    return RantiPayNetworkFailure(
      message: 'Error de red: ${error.toString()}',
      endpoint: endpoint,
    );
  }

  /// Crea failure para operación offline
  static RantiPayFailure createOfflineFailure(String operation) {
    final messages = {
      'sync': 'No hay conexión para sincronizar',
      'download': 'No hay conexión para descargar datos',
      'upload': 'No hay conexión para subir datos',
      'verify': 'No hay conexión para verificar',
      'refresh': 'No hay conexión para actualizar',
    };

    return RantiPayOfflineFailure(
      messages[operation] ?? 'No hay conexión para: $operation',
      requiredOperation: operation,
    );
  }
}
