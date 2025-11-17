// ==============================================================================
// 8. DATABASE ERROR TYPES
// lib/core/errors/rantipay_database_errors.dart

import 'package:drift/native.dart';

enum DatabaseErrorType {
  notFound,
  constraintViolation,
  connectionError,
  timeout,
  permissionDenied,
  diskFull,
  corruptData,
  migrationFailed,
  unknown,
  readError,
  writeError,
  updateError,
  deleteError,
}

class DatabaseError {
  final DatabaseErrorType type;
  final String message;
  final String? details;
  final Exception? originalException;

  const DatabaseError({
    required this.type,
    required this.message,
    this.details,
    this.originalException,
  });

  factory DatabaseError.fromException(Object exception) {
    if (exception is SqliteException) {
      switch (exception.extendedResultCode) {
        case 19: // CONSTRAINT
          return DatabaseError(
            type: DatabaseErrorType.constraintViolation,
            message: 'Violación de restricción de base de datos',
            details: exception.message,
            originalException: exception,
          );
        case 14: // CANTOPEN
          return DatabaseError(
            type: DatabaseErrorType.connectionError,
            message: 'No se puede abrir la base de datos',
            details: exception.message,
            originalException: exception,
          );
        default:
          return DatabaseError(
            type: DatabaseErrorType.unknown,
            message: 'Error de SQLite: ${exception.message}',
            originalException: exception,
          );
      }
    }

    return DatabaseError(
      type: DatabaseErrorType.unknown,
      message: 'Error desconocido: $exception',
      originalException: exception is Exception ? exception : null,
    );
  }

  @override
  String toString() {
    return 'DatabaseError(type: $type, message: $message, details: $details)';
  }
}
