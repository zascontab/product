import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'page_error_boundary.dart';

/// Logger avanzado con contexto de página y métricas de performance
class ContextualErrorLogger {
  final String pageId;
  final String featureModule;
  final bool enableLogging;
  final bool enableAnalytics;
  final bool enableLocalStorage;
  
  // Stream para eventos de logging
  final StreamController<LogEntry> _logController = StreamController<LogEntry>.broadcast();
  final List<LogEntry> _logBuffer = [];
  
  static const int _maxBufferSize = 100;
  static const Duration _flushInterval = Duration(seconds: 30);
  
  Timer? _flushTimer;

  ContextualErrorLogger({
    required this.pageId,
    required this.featureModule,
    this.enableLogging = true,
    this.enableAnalytics = true,
    this.enableLocalStorage = false,
  }) {
    if (enableLogging) {
      _startPeriodicFlush();
    }
  }

  /// Stream de eventos de logging para observadores externos
  Stream<LogEntry> get logStream => _logController.stream;

  void _startPeriodicFlush() {
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flushLogs());
  }

  /// Registra un error con contexto completo
  void logError(
    PageError error,
    Map<String, dynamic> additionalContext,
  ) {
    if (!enableLogging) return;

    final logEntry = LogEntry(
      level: LogLevel.error,
      message: error.userMessage,
      timestamp: DateTime.now(),
      pageId: pageId,
      featureModule: featureModule,
      context: {
        'error_id': error.id,
        'error_severity': error.severity.name,
        'error_category': error.category.name,
        'technical_message': error.technicalMessage,
        'stack_trace': error.stackTrace?.toString(),
        'original_error_type': error.originalError?.runtimeType.toString(),
        'recovery_strategies': error.suggestedRecoveryStrategies.map((s) => s.name).toList(),
        ...error.context,
        ...additionalContext,
      },
      tags: [
        'error',
        error.severity.name,
        error.category.name,
        featureModule,
        pageId,
      ],
    );

    _addLogEntry(logEntry);
    
    // Log críticos se envían inmediatamente
    if (error.severity == ErrorSeverity.critical) {
      _flushLogs();
    }
  }

  /// Registra problemas de performance
  void logPerformanceIssue(
    String metric,
    Duration value,
    Map<String, dynamic> context,
  ) {
    if (!enableLogging) return;

    final logEntry = LogEntry(
      level: LogLevel.warning,
      message: 'Performance issue: $metric took ${value.inMilliseconds}ms',
      timestamp: DateTime.now(),
      pageId: pageId,
      featureModule: featureModule,
      context: {
        'metric_name': metric,
        'metric_value_ms': value.inMilliseconds,
        'performance_threshold_exceeded': true,
        ...context,
      },
      tags: [
        'performance',
        'slow_operation',
        featureModule,
        pageId,
        metric,
      ],
    );

    _addLogEntry(logEntry);
  }

  /// Registra eventos de usuario para contexto
  void logUserAction(
    String action,
    Map<String, dynamic> context,
  ) {
    if (!enableLogging) return;

    final logEntry = LogEntry(
      level: LogLevel.info,
      message: 'User action: $action',
      timestamp: DateTime.now(),
      pageId: pageId,
      featureModule: featureModule,
      context: {
        'action_type': action,
        'user_session_context': true,
        ...context,
      },
      tags: [
        'user_action',
        featureModule,
        pageId,
        action,
      ],
    );

    _addLogEntry(logEntry);
  }

  /// Registra recuperación exitosa de errores
  void logErrorRecovery(
    PageError originalError,
    ErrorRecoveryStrategy strategy,
    Duration recoveryTime,
    bool successful,
  ) {
    if (!enableLogging) return;

    final logEntry = LogEntry(
      level: successful ? LogLevel.info : LogLevel.warning,
      message: successful 
          ? 'Error recovered using ${strategy.name} in ${recoveryTime.inMilliseconds}ms'
          : 'Error recovery failed using ${strategy.name}',
      timestamp: DateTime.now(),
      pageId: pageId,
      featureModule: featureModule,
      context: {
        'original_error_id': originalError.id,
        'recovery_strategy': strategy.name,
        'recovery_time_ms': recoveryTime.inMilliseconds,
        'recovery_successful': successful,
        'original_error_severity': originalError.severity.name,
        'original_error_category': originalError.category.name,
      },
      tags: [
        'error_recovery',
        successful ? 'recovery_success' : 'recovery_failure',
        strategy.name,
        featureModule,
        pageId,
      ],
    );

    _addLogEntry(logEntry);
  }

  /// Registra métricas de sesión de página
  void logPageMetrics(
    Map<String, dynamic> metrics,
  ) {
    if (!enableLogging) return;

    final logEntry = LogEntry(
      level: LogLevel.info,
      message: 'Page metrics for $pageId',
      timestamp: DateTime.now(),
      pageId: pageId,
      featureModule: featureModule,
      context: {
        'metrics_type': 'page_session',
        ...metrics,
      },
      tags: [
        'metrics',
        'page_session',
        featureModule,
        pageId,
      ],
    );

    _addLogEntry(logEntry);
  }

  void _addLogEntry(LogEntry entry) {
    _logBuffer.add(entry);
    _logController.add(entry);

    // Debug output
    if (kDebugMode) {
      debugPrint('📊 [${entry.level.name.toUpperCase()}] ${entry.pageId}: ${entry.message}');
      if (entry.context.isNotEmpty) {
        debugPrint('   Context: ${entry.context}');
      }
    }

    // Mantener buffer size
    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeAt(0);
    }

    // Auto-flush para errores críticos
    if (entry.level == LogLevel.error && 
        entry.context['error_severity'] == 'critical') {
      _flushLogs();
    }
  }

  /// Envía logs acumulados a analytics/backend
  Future<void> _flushLogs() async {
    if (_logBuffer.isEmpty) return;

    try {
      final logsToFlush = List<LogEntry>.from(_logBuffer);
      _logBuffer.clear();

      if (enableAnalytics) {
        await _sendToAnalytics(logsToFlush);
      }

      if (enableLocalStorage) {
        await _saveToLocalStorage(logsToFlush);
      }

      if (kDebugMode) {
        debugPrint('📤 Flushed ${logsToFlush.length} log entries');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error flushing logs: $e');
      }
    }
  }

  Future<void> _sendToAnalytics(List<LogEntry> logs) async {
    // Aquí integrarías con tu servicio de analytics
    // Por ejemplo: Firebase Analytics, Mixpanel, etc.
    
    for (final log in logs) {
      // Simulación de envío a analytics
      if (kDebugMode) {
        debugPrint('📈 Analytics: ${log.toMap()}');
      }
    }
  }

  Future<void> _saveToLocalStorage(List<LogEntry> logs) async {
    // Aquí guardarías logs localmente para offline
    // Por ejemplo: usando SQLite, Sembast, etc.
    
    try {
      final logsJson = logs.map((log) => log.toMap()).toList();
      final jsonString = jsonEncode(logsJson);
      
      // Simulación de guardado local
      if (kDebugMode) {
        debugPrint('💾 Saved ${logs.length} logs locally');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving logs locally: $e');
      }
    }
  }

  /// Obtiene estadísticas de la sesión actual
  Map<String, dynamic> getSessionStats() {
    final errorLogs = _logBuffer.where((log) => log.level == LogLevel.error);
    final warningLogs = _logBuffer.where((log) => log.level == LogLevel.warning);
    final performanceLogs = _logBuffer.where((log) => log.tags.contains('performance'));
    
    return {
      'page_id': pageId,
      'feature_module': featureModule,
      'total_logs': _logBuffer.length,
      'error_count': errorLogs.length,
      'warning_count': warningLogs.length,
      'performance_issues': performanceLogs.length,
      'session_duration_minutes': _logBuffer.isNotEmpty 
          ? DateTime.now().difference(_logBuffer.first.timestamp).inMinutes
          : 0,
      'most_common_tags': _getMostCommonTags(),
    };
  }

  List<String> _getMostCommonTags() {
    final tagCount = <String, int>{};
    
    for (final log in _logBuffer) {
      for (final tag in log.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }
    
    final sortedTags = tagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTags.take(5).map((entry) => entry.key).toList();
  }

  /// Genera reporte de errores para debugging
  String generateErrorReport() {
    final errorLogs = _logBuffer.where((log) => log.level == LogLevel.error);
    
    if (errorLogs.isEmpty) {
      return 'No errors found in current session for $pageId';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('🔍 Error Report for $pageId ($featureModule)');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total errors: ${errorLogs.length}');
    buffer.writeln('');
    
    for (final log in errorLogs) {
      buffer.writeln('--- Error ${log.context['error_id']} ---');
      buffer.writeln('Time: ${log.timestamp}');
      buffer.writeln('Severity: ${log.context['error_severity']}');
      buffer.writeln('Category: ${log.context['error_category']}');
      buffer.writeln('Message: ${log.message}');
      buffer.writeln('Technical: ${log.context['technical_message']}');
      if (log.context['stack_trace'] != null) {
        buffer.writeln('Stack trace: ${log.context['stack_trace']}');
      }
      buffer.writeln('');
    }
    
    return buffer.toString();
  }

  /// Copia el reporte de errores al clipboard
  Future<void> copyErrorReportToClipboard() async {
    final report = generateErrorReport();
    await Clipboard.setData(ClipboardData(text: report));
  }

  void dispose() {
    _flushTimer?.cancel();
    _flushLogs(); // Flush final
    _logController.close();
  }
}

/// Niveles de logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Entrada de log estructurada
class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String pageId;
  final String featureModule;
  final Map<String, dynamic> context;
  final List<String> tags;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    required this.pageId,
    required this.featureModule,
    this.context = const {},
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'level': level.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'page_id': pageId,
      'feature_module': featureModule,
      'context': context,
      'tags': tags,
    };
  }

  @override
  String toString() {
    return 'LogEntry(level: $level, message: $message, page: $pageId)';
  }
}