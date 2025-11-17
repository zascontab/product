// lib/core/utils/rantipay_logger.dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/config/rantipay_enviroment.dart';

/// RantiPay: Servicio de logging centralizado
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: Injectable
///
/// Uso:
/// ```dart
/// final logger = getIt<RantiPayLogger>();
/// logger.info('Usuario autenticado', {'userId': '123'});
/// logger.error('Error al sincronizar', error, stackTrace);
/// ```
@lazySingleton
class RantiPayLogger {
  static const String _name = 'RantiPay';

  // Niveles de log
  static const int _verbose = 0;
  static const int _debug = 1;
  static const int _info = 2;
  static const int _warning = 3;
  static const int _error = 4;
  static const int _critical = 5;

  // Colores ANSI para consola
  static const String _reset = '\x1B[0m';
  static const String _black = '\x1B[30m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';

  // Buffer para logs en producción
  final List<LogEntry> _logBuffer = [];
  static const int _maxBufferSize = 1000;

  // Constructor
  RantiPayLogger();

  // Métodos públicos de logging

  void verbose(String message, [Map<String, dynamic>? data]) {
    _log(_verbose, message, data);
  }

  void debug(String message, [Map<String, dynamic>? data]) {
    _log(_debug, message, data);
  }

  void info(String message, [Map<String, dynamic>? data]) {
    _log(_info, message, data);
  }

  void warning(String message, [Map<String, dynamic>? data]) {
    _log(_warning, message, data);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    final data = <String, dynamic>{};
    if (error != null) {
      data['error'] = error.toString();
    }
    if (stackTrace != null) {
      data['stackTrace'] = stackTrace.toString();
    }
    _log(_error, message, data);
  }

  void critical(String message, [dynamic error, StackTrace? stackTrace]) {
    final data = <String, dynamic>{};
    if (error != null) {
      data['error'] = error.toString();
    }
    if (stackTrace != null) {
      data['stackTrace'] = stackTrace.toString();
    }
    _log(_critical, message, data);
  }

  // Método para medir tiempo de ejecución
  Future<T> measureTime<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      stopwatch.stop();
      info('$operation completado', {
        'duration': '${stopwatch.elapsedMilliseconds}ms',
      });
      return result;
    } catch (e, stack) {
      stopwatch.stop();
      error('$operation falló', e, stack);
      rethrow;
    }
  }

  // Método para logs de red
  void network({
    required String method,
    required String url,
    int? statusCode,
    Map<String, dynamic>? headers,
    dynamic requestBody,
    dynamic responseBody,
    Duration? duration,
    dynamic error,
  }) {
    final data = <String, dynamic>{
      'method': method,
      'url': url,
    };

    if (statusCode != null) data['statusCode'] = statusCode;
    if (headers != null) data['headers'] = _sanitizeHeaders(headers);
    if (requestBody != null) {
      data['request'] = _truncate(requestBody.toString());
    }
    if (responseBody != null) {
      data['response'] = _truncate(responseBody.toString());
    }
    if (duration != null) data['duration'] = '${duration.inMilliseconds}ms';
    if (error != null) data['error'] = error.toString();

    if (error != null || (statusCode != null && statusCode >= 400)) {
      warning('Network request failed', data);
    } else {
      debug('Network request', data);
    }
  }

  // Método para logs de base de datos
  void database({
    required String operation,
    required String table,
    String? query,
    Duration? duration,
    int? affectedRows,
    dynamic error,
  }) {
    final data = <String, dynamic>{
      'operation': operation,
      'table': table,
    };

    if (query != null) data['query'] = _truncate(query);
    if (duration != null) data['duration'] = '${duration.inMilliseconds}ms';
    if (affectedRows != null) data['affectedRows'] = affectedRows;
    if (error != null) data['error'] = error.toString();

    if (error != null) {
      error('Database operation failed', data);
    } else {
      verbose('Database operation', data);
    }
  }

  // Método para logs de analytics
  void analytics(String event, Map<String, dynamic>? parameters) {
    debug('Analytics event: $event', parameters);
  }

  // Método para logs de performance
  void performance(String metric, double value, [String? unit]) {
    info('Performance metric', {
      'metric': metric,
      'value': value,
      'unit': unit ?? 'ms',
    });
  }

  // Obtener logs buffereados (útil para enviar a servidor)
  List<LogEntry> getBufferedLogs({
    int? level,
    DateTime? since,
    int? limit,
  }) {
    var logs = List<LogEntry>.from(_logBuffer);

    if (level != null) {
      logs = logs.where((log) => log.level >= level).toList();
    }

    if (since != null) {
      logs = logs.where((log) => log.timestamp.isAfter(since)).toList();
    }

    if (limit != null && logs.length > limit) {
      logs = logs.sublist(logs.length - limit);
    }

    return logs;
  }

  // Limpiar buffer de logs
  void clearBuffer() {
    _logBuffer.clear();
  }

  // Método privado principal de logging
  void _log(int level, String message, Map<String, dynamic>? data) {
    // Verificar si el nivel está habilitado
    if (!_shouldLog(level)) return;

    final timestamp = DateTime.now();
    final levelName = _getLevelName(level);
    final color = _getLevelColor(level);

    // Crear entrada de log
    final entry = LogEntry(
      timestamp: timestamp,
      level: level,
      levelName: levelName,
      message: message,
      data: data,
    );

    // Agregar al buffer
    _addToBuffer(entry);

    // Output según el entorno
    if (kDebugMode || RantiPayEnvironment.isDev) {
      _logToConsole(entry, color);
    } else {
      _logToProduction(entry);
    }
  }

  bool _shouldLog(int level) {
    if (kDebugMode || RantiPayEnvironment.isDev) {
      return true; // Log todo en desarrollo
    }

    // En producción, solo log de info en adelante
    return level >= _info;
  }

  void _addToBuffer(LogEntry entry) {
    _logBuffer.add(entry);

    // Mantener el buffer dentro del límite
    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeRange(0, _logBuffer.length - _maxBufferSize);
    }
  }

  void _logToConsole(LogEntry entry, String color) {
    final buffer = StringBuffer();

    // Formato: [HH:MM:SS.mmm] [LEVEL] message
    buffer.write(color);
    buffer.write('[${_formatTime(entry.timestamp)}] ');
    buffer.write('[${entry.levelName}] ');
    buffer.write(entry.message);

    if (entry.data != null && entry.data!.isNotEmpty) {
      buffer.write('\n');
      entry.data!.forEach((key, value) {
        buffer.write('  $key: $value\n');
      });
    }

    buffer.write(_reset);

    // Usar developer.log para mejor integración con DevTools
    developer.log(
      buffer.toString(),
      name: _name,
      time: entry.timestamp,
      level: entry.level * 100, // Escalar para developer.log
    );
  }

  void _logToProduction(LogEntry entry) {
    // En producción, podrías enviar logs a un servicio externo
    // Por ahora, solo los mantenemos en el buffer

    // Para errores críticos, podrías enviarlos inmediatamente
    if (entry.level >= _error) {
      // TODO: Enviar a servicio de logging remoto
    }
  }

  String _getLevelName(int level) {
    switch (level) {
      case _verbose:
        return 'VERBOSE';
      case _debug:
        return 'DEBUG';
      case _info:
        return 'INFO';
      case _warning:
        return 'WARNING';
      case _error:
        return 'ERROR';
      case _critical:
        return 'CRITICAL';
      default:
        return 'UNKNOWN';
    }
  }

  String _getLevelColor(int level) {
    switch (level) {
      case _verbose:
        return _white;
      case _debug:
        return _cyan;
      case _info:
        return _green;
      case _warning:
        return _yellow;
      case _error:
        return _red;
      case _critical:
        return _magenta;
      default:
        return _reset;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);

    // Ocultar headers sensibles
    const sensitiveHeaders = [
      'authorization',
      'x-api-key',
      'x-auth-token',
      'cookie',
      'set-cookie',
    ];

    for (final key in sensitiveHeaders) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '***REDACTED***';
      }
    }

    return sanitized;
  }

  String _truncate(String text, [int maxLength = 500]) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}... (truncated)';
  }
}

// Clase para representar una entrada de log
class LogEntry {
  final DateTime timestamp;
  final int level;
  final String levelName;
  final String message;
  final Map<String, dynamic>? data;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.levelName,
    required this.message,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level,
      'levelName': levelName,
      'message': message,
      if (data != null) 'data': data,
    };
  }
}

// Extension para facilitar el uso del logger
extension LoggerX on Object {
  RantiPayLogger get logger => RantiPayLogger();
}
