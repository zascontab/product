import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tipos de error clasificados por severidad
enum ErrorSeverity {
  low,      // Warnings, validaciones
  medium,   // Errores de red, timeouts
  high,     // Errores de lógica de negocio
  critical, // Crashes que requieren restart
}

/// Tipos de error por categoría
enum ErrorCategory {
  widget,     // Errores de UI/rendering
  network,    // Conectividad, API
  business,   // Lógica de negocio
  validation, // Validación de datos
  permission, // Permisos, autenticación
  system,     // Sistema operativo, dispositivo
}

/// Estrategias de recuperación automática
enum ErrorRecoveryStrategy {
  retry,           // Reintentar operación
  refresh,         // Refrescar datos
  fallback,        // Usar datos en caché
  navigation,      // Navegar a página segura
  restart,         // Reiniciar componente
  ignore,          // Ignorar y continuar
}

/// Modelo de error enriquecido con contexto
class PageError {
  final String id;
  final ErrorSeverity severity;
  final ErrorCategory category;
  final String userMessage;
  final String? technicalMessage;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final String? pageId;
  final String? featureModule;
  final DateTime timestamp;
  final Map<String, dynamic> context;
  final List<ErrorRecoveryStrategy> suggestedRecoveryStrategies;

  PageError({
    String? id,
    required this.severity,
    required this.category,
    required this.userMessage,
    this.technicalMessage,
    this.originalError,
    this.stackTrace,
    this.pageId,
    this.featureModule,
    DateTime? timestamp,
    this.context = const {},
    this.suggestedRecoveryStrategies = const [],
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       timestamp = timestamp ?? DateTime.now();

  /// Crea un PageError desde un error de BLoC
  factory PageError.fromBlocError(
    dynamic blocError, {
    String? pageId,
    String? featureModule,
    Map<String, dynamic> additionalContext = const {},
  }) {
    ErrorSeverity severity;
    ErrorCategory category;
    String userMessage;
    List<ErrorRecoveryStrategy> strategies;

    // Clasificar error basado en el tipo
    if (blocError.toString().contains('Network') || 
        blocError.toString().contains('Connection')) {
      severity = ErrorSeverity.medium;
      category = ErrorCategory.network;
      userMessage = 'Problema de conexión. Verifica tu internet.';
      strategies = [ErrorRecoveryStrategy.retry, ErrorRecoveryStrategy.fallback];
    } else if (blocError.toString().contains('Validation') ||
               blocError.toString().contains('Invalid')) {
      severity = ErrorSeverity.low;
      category = ErrorCategory.validation;
      userMessage = 'Datos incorretos. Verifica la información.';
      strategies = [ErrorRecoveryStrategy.ignore];
    } else if (blocError.toString().contains('Permission') ||
               blocError.toString().contains('Unauthorized')) {
      severity = ErrorSeverity.high;
      category = ErrorCategory.permission;
      userMessage = 'No tienes permisos para esta operación.';
      strategies = [ErrorRecoveryStrategy.navigation];
    } else {
      severity = ErrorSeverity.high;
      category = ErrorCategory.business;
      userMessage = 'Ocurrió un error inesperado. Intenta nuevamente.';
      strategies = [ErrorRecoveryStrategy.refresh, ErrorRecoveryStrategy.retry];
    }

    return PageError(
      severity: severity,
      category: category,
      userMessage: userMessage,
      technicalMessage: blocError.toString(),
      originalError: blocError,
      pageId: pageId,
      featureModule: featureModule,
      context: {
        'bloc_error_type': blocError.runtimeType.toString(),
        ...additionalContext,
      },
      suggestedRecoveryStrategies: strategies,
    );
  }

  /// Crea un PageError desde una excepción de widget
  factory PageError.fromWidgetException(
    FlutterErrorDetails errorDetails, {
    String? pageId,
    String? featureModule,
    Map<String, dynamic> additionalContext = const {},
  }) {
    final errorString = errorDetails.exception.toString();
    
    ErrorSeverity severity;
    String userMessage;
    List<ErrorRecoveryStrategy> strategies;

    if (errorString.contains('RenderFlex overflowed') ||
        errorString.contains('RenderBox was not laid out')) {
      severity = ErrorSeverity.low;
      userMessage = 'Problema menor de visualización.';
      strategies = [ErrorRecoveryStrategy.ignore];
    } else if (errorString.contains('NoSuchMethodError') ||
               errorString.contains('type \'Null\' is not a subtype')) {
      severity = ErrorSeverity.high;
      userMessage = 'Error interno de la aplicación.';
      strategies = [ErrorRecoveryStrategy.refresh, ErrorRecoveryStrategy.restart];
    } else {
      severity = ErrorSeverity.medium;
      userMessage = 'Problema temporal en la interfaz.';
      strategies = [ErrorRecoveryStrategy.refresh];
    }

    return PageError(
      severity: severity,
      category: ErrorCategory.widget,
      userMessage: userMessage,
      technicalMessage: errorString,
      originalError: errorDetails.exception,
      stackTrace: errorDetails.stack,
      pageId: pageId,
      featureModule: featureModule,
      context: {
        'widget_error_library': errorDetails.library,
        'widget_error_context': errorDetails.context?.toString(),
        ...additionalContext,
      },
      suggestedRecoveryStrategies: strategies,
    );
  }

  /// Convierte a Map para logging/analytics
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'severity': severity.name,
      'category': category.name,
      'user_message': userMessage,
      'technical_message': technicalMessage,
      'page_id': pageId,
      'feature_module': featureModule,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'recovery_strategies': suggestedRecoveryStrategies.map((s) => s.name).toList(),
      'has_stack_trace': stackTrace != null,
      'original_error_type': originalError?.runtimeType.toString(),
    };
  }

  @override
  String toString() {
    return 'PageError(id: $id, severity: $severity, category: $category, message: $userMessage)';
  }
}

/// Error Boundary para capturar errores a nivel de widget
class PageErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(PageError error) onError;
  final String? pageId;
  final String? featureModule;
  final bool enableAutomaticRecovery;
  final Widget Function(PageError error)? errorWidgetBuilder;

  const PageErrorBoundary({
    super.key,
    required this.child,
    required this.onError,
    this.pageId,
    this.featureModule,
    this.enableAutomaticRecovery = true,
    this.errorWidgetBuilder,
  });

  @override
  State<PageErrorBoundary> createState() => _PageErrorBoundaryState();
}

class _PageErrorBoundaryState extends State<PageErrorBoundary> {
  PageError? _lastError;
  int _errorCount = 0;
  DateTime? _lastErrorTime;

  @override
  void initState() {
    super.initState();
    
    // Capturar errores de widgets
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    final errorString = details.exception.toString();
    
    // Filtrar errores que sabemos que pueden ocurrir durante el build cycle
    if (errorString.contains('setState() or markNeedsBuild() called during build') ||
        errorString.contains('showSnackBar() method cannot be called during build') ||
        errorString.contains('cannot be marked as needing to build because the framework is already in the process')) {
      // Estos errores son manejados por nuestro sistema, no los propaguemos
      debugPrint('🔄 Error de build cycle filtrado: ${errorString.substring(0, 100)}...');
      return;
    }
    
    // Evitar loops infinitos de errores
    if (_isRecentDuplicateError(details.exception)) {
      return;
    }

    final pageError = PageError.fromWidgetException(
      details,
      pageId: widget.pageId,
      featureModule: widget.featureModule,
      additionalContext: {
        'error_count': _errorCount,
        'last_error_time': _lastErrorTime?.toIso8601String(),
      },
    );

    _updateErrorState(pageError);
    widget.onError(pageError);
  }

  bool _isRecentDuplicateError(dynamic error) {
    if (_lastError == null) return false;
    
    final now = DateTime.now();
    final timeSinceLastError = _lastErrorTime != null 
        ? now.difference(_lastErrorTime!)
        : Duration.zero;
    
    // Considerar duplicado si el mismo error ocurre en menos de 5 segundos
    return _lastError!.originalError.toString() == error.toString() &&
           timeSinceLastError < const Duration(seconds: 5);
  }

  void _updateErrorState(PageError error) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _lastError = error;
          _errorCount++;
          _lastErrorTime = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si hay un error crítico y tenemos un builder personalizado
    if (_lastError?.severity == ErrorSeverity.critical && 
        widget.errorWidgetBuilder != null) {
      return widget.errorWidgetBuilder!(_lastError!);
    }

    // Error boundary transparente - solo devuelve el child
    return widget.child;
  }
}

/// Widget de fallback para errores críticos
class ErrorFallbackWidget extends StatelessWidget {
  final PageError error;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const ErrorFallbackWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForSeverity(error.severity),
                size: 64,
                color: _getColorForSeverity(error.severity),
              ),
              const SizedBox(height: 24),
              Text(
                'Algo salió mal',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error.userMessage,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  if (onGoHome != null)
                    TextButton.icon(
                      onPressed: onGoHome,
                      icon: const Icon(Icons.home),
                      label: const Text('Ir a Inicio'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => _copyErrorDetails(context),
                child: const Text('Copiar detalles del error'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Icons.warning_amber;
      case ErrorSeverity.medium:
        return Icons.error_outline;
      case ErrorSeverity.high:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }

  Color _getColorForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.yellow.shade700;
      case ErrorSeverity.high:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }

  void _copyErrorDetails(BuildContext context) {
    final details = '''
Error ID: ${error.id}
Tiempo: ${error.timestamp}
Página: ${error.pageId ?? 'Desconocida'}
Módulo: ${error.featureModule ?? 'Desconocido'}
Categoría: ${error.category.name}
Severidad: ${error.severity.name}
Mensaje: ${error.userMessage}
Técnico: ${error.technicalMessage ?? 'No disponible'}
Contexto: ${error.context}
''';

    Clipboard.setData(ClipboardData(text: details));
    
    // Usar addPostFrameCallback para evitar problemas con el Scaffold
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Detalles del error copiados'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    });
  }
}
