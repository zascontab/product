/// RantiPay: Entidad para respuestas estandarizadas del API
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: Ninguna
///
/// Uso:
/// ```dart
/// final response = RantiPayApiResponseEntity.fromJson(responseData);
/// if (response.success) {
///   // Procesar response.data
/// }
/// ```
class RantiPayApiResponseEntity {
  /// Indica si la operación fue exitosa
  final bool success;

  /// Mensaje descriptivo (éxito o error)
  final String? message;

  /// Datos de la respuesta (puede ser cualquier tipo)
  final dynamic data;

  /// Información del error si hubo uno
  final RantiPayApiErrorEntity? error;

  /// Timestamp de la respuesta
  final DateTime timestamp;

  /// Metadata adicional de la respuesta
  final Map<String, dynamic>? metadata;

  /// Versión del API
  final String? apiVersion;

  /// ID de tracking para debugging
  final String? trackingId;

  RantiPayApiResponseEntity({
    required this.success,
    this.message,
    this.data,
    this.error,
    DateTime? timestamp,
    this.metadata,
    this.apiVersion,
    this.trackingId,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory constructor desde JSON
  factory RantiPayApiResponseEntity.fromJson(Map<String, dynamic> json) {
    return RantiPayApiResponseEntity(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'],
      error: json['error'] != null
          ? RantiPayApiErrorEntity.fromJson(json['error'])
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      apiVersion: json['api_version'] as String?,
      trackingId: json['tracking_id'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
      if (error != null) 'error': error!.toJson(),
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
      if (apiVersion != null) 'api_version': apiVersion,
      if (trackingId != null) 'tracking_id': trackingId,
    };
  }

  /// Factory para respuesta exitosa
  factory RantiPayApiResponseEntity.success({
    dynamic data,
    String? message,
    Map<String, dynamic>? metadata,
  }) {
    return RantiPayApiResponseEntity(
      success: true,
      data: data,
      message: message ?? 'Operación exitosa',
      metadata: metadata,
    );
  }

  /// Factory para respuesta de error
  factory RantiPayApiResponseEntity.error({
    required String message,
    required String code,
    dynamic details,
    Map<String, dynamic>? metadata,
  }) {
    return RantiPayApiResponseEntity(
      success: false,
      message: message,
      error: RantiPayApiErrorEntity(
        code: code,
        message: message,
        details: details,
      ),
      metadata: metadata,
    );
  }

  /// Verifica si la respuesta contiene datos
  bool get hasData => data != null;

  /// Verifica si la respuesta es un error
  bool get isError => !success || error != null;

  /// Obtiene el código de error si existe
  String? get errorCode => error?.code;

  /// Crea una copia con nuevos valores
  RantiPayApiResponseEntity copyWith({
    bool? success,
    String? message,
    dynamic data,
    RantiPayApiErrorEntity? error,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? apiVersion,
    String? trackingId,
  }) {
    return RantiPayApiResponseEntity(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
      error: error ?? this.error,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      apiVersion: apiVersion ?? this.apiVersion,
      trackingId: trackingId ?? this.trackingId,
    );
  }
}

/// Entidad para información de errores en respuestas API
class RantiPayApiErrorEntity {
  /// Código único del error
  final String code;

  /// Mensaje descriptivo del error
  final String message;

  /// Detalles adicionales del error
  final dynamic details;

  /// Campo específico que causó el error (para validaciones)
  final String? field;

  /// Stack trace (solo en desarrollo)
  final String? stackTrace;

  RantiPayApiErrorEntity({
    required this.code,
    required this.message,
    this.details,
    this.field,
    this.stackTrace,
  });

  /// Factory constructor desde JSON
  factory RantiPayApiErrorEntity.fromJson(Map<String, dynamic> json) {
    return RantiPayApiErrorEntity(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'],
      field: json['field'] as String?,
      stackTrace: json['stack_trace'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (details != null) 'details': details,
      if (field != null) 'field': field,
      if (stackTrace != null) 'stack_trace': stackTrace,
    };
  }

  /// Verifica si es un error de validación
  bool get isValidationError => field != null;

  /// Obtiene detalles como Map si es posible
  Map<String, dynamic>? get detailsAsMap {
    if (details is Map<String, dynamic>) {
      return details as Map<String, dynamic>;
    }
    return null;
  }
}

/// Extension para manejar respuestas API más fácilmente
extension RantiPayApiResponseExtension on RantiPayApiResponseEntity {
  /// Ejecuta una función si la respuesta es exitosa
  T? whenSuccess<T>(T Function(dynamic data) onSuccess) {
    if (success && data != null) {
      return onSuccess(data);
    }
    return null;
  }

  /// Ejecuta una función si la respuesta es error
  T? whenError<T>(T Function(RantiPayApiErrorEntity error) onError) {
    if (!success && error != null) {
      return onError(error!);
    }
    return null;
  }

  /// Mapea la respuesta a otro tipo
  RantiPayApiResponseEntity mapData<T>(T Function(dynamic) mapper) {
    if (success && data != null) {
      return copyWith(data: mapper(data));
    }
    return this;
  }
}

/// Códigos de error comunes del API
class RantiPayApiErrorCodes {
  static const String unauthorized = 'unauthorized';
  static const String forbidden = 'forbidden';
  static const String notFound = 'not_found';
  static const String validationError = 'validation_error';
  static const String serverError = 'server_error';
  static const String networkError = 'network_error';
  static const String timeoutError = 'timeout_error';
  static const String insufficientLevel = 'insufficient_level';
  static const String noPermission = 'no_permission';
  static const String quotaExceeded = 'quota_exceeded';
  static const String resourceLocked = 'resource_locked';
  static const String duplicateEntry = 'duplicate_entry';
  static const String invalidToken = 'invalid_token';
  static const String tokenExpired = 'token_expired';
  static const String maintenanceMode = 'maintenance_mode';
}
