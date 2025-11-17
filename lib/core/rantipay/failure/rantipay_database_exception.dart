// lib/core/errors/rantipay_database_exception.dart

/// RantiPay: Excepción específica para errores de base de datos
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: Ninguna
///
/// Uso:
/// ```dart
/// throw RantiPayDatabaseException('Error al guardar usuario');
/// ```
class RantiPayDatabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  RantiPayDatabaseException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('RantiPayDatabaseException: $message');

    if (code != null) {
      buffer.write(' [Code: $code]');
    }

    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }

    if (stackTrace != null) {
      buffer.write('\nStack trace:\n$stackTrace');
    }

    return buffer.toString();
  }

  // Factory constructors para errores comunes

  factory RantiPayDatabaseException.notFound(String entity, String id) {
    return RantiPayDatabaseException(
      '$entity con ID $id no encontrado',
      code: 'NOT_FOUND',
    );
  }

  factory RantiPayDatabaseException.duplicate(
      String entity, String field, String value) {
    return RantiPayDatabaseException(
      '$entity con $field "$value" ya existe',
      code: 'DUPLICATE',
    );
  }

  factory RantiPayDatabaseException.invalidData(String field, String reason) {
    return RantiPayDatabaseException(
      'Datos inválidos en $field: $reason',
      code: 'INVALID_DATA',
    );
  }

  factory RantiPayDatabaseException.syncError(String entity, dynamic error) {
    return RantiPayDatabaseException(
      'Error sincronizando $entity',
      code: 'SYNC_ERROR',
      originalError: error,
    );
  }

  factory RantiPayDatabaseException.transactionFailed(dynamic error) {
    return RantiPayDatabaseException(
      'Transacción fallida',
      code: 'TRANSACTION_FAILED',
      originalError: error,
    );
  }

  factory RantiPayDatabaseException.migrationFailed(
      int from, int to, dynamic error) {
    return RantiPayDatabaseException(
      'Migración fallida de versión $from a $to',
      code: 'MIGRATION_FAILED',
      originalError: error,
    );
  }

  factory RantiPayDatabaseException.cacheError(
      String operation, dynamic error) {
    return RantiPayDatabaseException(
      'Error en caché durante $operation',
      code: 'CACHE_ERROR',
      originalError: error,
    );
  }

  factory RantiPayDatabaseException.connectionError(dynamic error) {
    return RantiPayDatabaseException(
      'Error de conexión a base de datos',
      code: 'CONNECTION_ERROR',
      originalError: error,
    );
  }

  factory RantiPayDatabaseException.constraintViolation(
      String constraint, dynamic error) {
    return RantiPayDatabaseException(
      'Violación de restricción: $constraint',
      code: 'CONSTRAINT_VIOLATION',
      originalError: error,
    );
  }

  factory RantiPayDatabaseException.quotaExceeded(String resource, int limit) {
    return RantiPayDatabaseException(
      'Cuota excedida para $resource. Límite: $limit',
      code: 'QUOTA_EXCEEDED',
    );
  }

  // Helper para convertir errores de SQLite
  static RantiPayDatabaseException fromSqliteError(dynamic error,
      [String? context]) {
    final errorString = error.toString();

    if (errorString.contains('UNIQUE constraint failed')) {
      final match = RegExp(r'UNIQUE constraint failed: (\w+)\.(\w+)')
          .firstMatch(errorString);
      if (match != null) {
        final table = match.group(1);
        final column = match.group(2);
        return RantiPayDatabaseException.duplicate(
            table ?? 'registro', column ?? 'campo', 'valor');
      }
      return RantiPayDatabaseException('Registro duplicado', code: 'DUPLICATE');
    }

    if (errorString.contains('FOREIGN KEY constraint failed')) {
      return RantiPayDatabaseException(
        'Referencia a registro inexistente',
        code: 'FOREIGN_KEY_VIOLATION',
        originalError: error,
      );
    }

    if (errorString.contains('NOT NULL constraint failed')) {
      final match = RegExp(r'NOT NULL constraint failed: (\w+)\.(\w+)')
          .firstMatch(errorString);
      if (match != null) {
        final table = match.group(1);
        final column = match.group(2);
        return RantiPayDatabaseException.invalidData(
          '$table.$column',
          'campo requerido no puede ser nulo',
        );
      }
      return RantiPayDatabaseException('Campo requerido faltante',
          code: 'NOT_NULL_VIOLATION');
    }

    if (errorString.contains('database is locked')) {
      return RantiPayDatabaseException(
        'Base de datos bloqueada',
        code: 'DATABASE_LOCKED',
        originalError: error,
      );
    }

    if (errorString.contains('no such table')) {
      return RantiPayDatabaseException(
        'Tabla no existe',
        code: 'TABLE_NOT_FOUND',
        originalError: error,
      );
    }

    if (errorString.contains('disk full')) {
      return RantiPayDatabaseException(
        'Disco lleno',
        code: 'DISK_FULL',
        originalError: error,
      );
    }

    // Error genérico
    return RantiPayDatabaseException(
      context ?? 'Error de base de datos',
      code: 'UNKNOWN',
      originalError: error,
    );
  }
}
