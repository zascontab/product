import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'page_error_boundary.dart';
import '../../application/blocs/base_crud_bloc.dart';

/// Manager para estrategias de recuperación automática de errores
class RecoveryStrategyManager {
  final bool enableAutoRecovery;
  final Duration autoRecoveryDelay;
  final List<ErrorRecoveryStrategy> customStrategies;
  final Function(ErrorRecoveryStrategy strategy)? onRecoveryAttempt;
  final Function(ErrorRecoveryStrategy strategy)? onRecoverySuccess;
  final Function(ErrorRecoveryStrategy strategy, String reason)? onRecoveryFailure;

  // Tracking de intentos de recuperación
  final Map<String, int> _recoveryAttempts = {};
  final Map<String, DateTime> _lastRecoveryTimes = {};
  
  static const int _maxRecoveryAttempts = 3;
  static const Duration _recoveryGracePeriod = Duration(minutes: 5);

  RecoveryStrategyManager({
    required this.enableAutoRecovery,
    required this.autoRecoveryDelay,
    this.customStrategies = const [],
    this.onRecoveryAttempt,
    this.onRecoverySuccess,
    this.onRecoveryFailure,
  });

  /// Intenta recuperación automática basada en el tipo de error
  Future<bool> attemptRecovery(
    PageError error,
    BuildContext context,
  ) async {
    if (!enableAutoRecovery) {
      onRecoveryFailure?.call(
        ErrorRecoveryStrategy.ignore,
        'Auto recovery disabled',
      );
      return false;
    }

    // Verificar si ya intentamos recuperar este error recientemente
    if (_shouldSkipRecovery(error)) {
      onRecoveryFailure?.call(
        ErrorRecoveryStrategy.ignore,
        'Too many recent recovery attempts',
      );
      return false;
    }

    // Seleccionar estrategia de recuperación
    final strategy = _selectRecoveryStrategy(error);
    if (strategy == null) {
      onRecoveryFailure?.call(
        ErrorRecoveryStrategy.ignore,
        'No suitable recovery strategy found',
      );
      return false;
    }

    // Registrar intento
    _recordRecoveryAttempt(error);
    onRecoveryAttempt?.call(strategy);

    // Esperar delay antes de intentar recuperación
    await Future.delayed(autoRecoveryDelay);

    // Ejecutar estrategia de recuperación
    try {
      final success = await _executeRecoveryStrategy(strategy, error, context);
      
      if (success) {
        onRecoverySuccess?.call(strategy);
        _clearRecoveryHistory(error);
      } else {
        onRecoveryFailure?.call(strategy, 'Recovery strategy execution failed');
      }
      
      return success;
    } catch (e) {
      onRecoveryFailure?.call(strategy, 'Recovery strategy threw exception: $e');
      return false;
    }
  }

  bool _shouldSkipRecovery(PageError error) {
    final errorKey = '${error.category.name}_${error.pageId}';
    final attempts = _recoveryAttempts[errorKey] ?? 0;
    final lastAttempt = _lastRecoveryTimes[errorKey];

    // Para errores de widget/UI, ser más permisivos
    if (error.category == ErrorCategory.widget) {
      // Permitir más intentos para errores de UI
      if (attempts >= _maxRecoveryAttempts * 2) {
        return true;
      }
      
      // Reducir tiempo de gracia para errores de UI
      if (lastAttempt != null) {
        final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
        if (timeSinceLastAttempt < const Duration(seconds: 10)) {
          return true;
        }
      }
      return false;
    }

    // Para errores de red, ser más tolerantes durante visualización de archivos
    if (error.category == ErrorCategory.network && error.pageId?.contains('attachment') == true) {
      // No bloquear intentos de recuperación para visualización de archivos
      if (attempts >= _maxRecoveryAttempts * 3) {
        return true;
      }
      
      if (lastAttempt != null) {
        final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
        if (timeSinceLastAttempt < const Duration(seconds: 5)) {
          return true;
        }
      }
      return false;
    }

    // Lógica original para otros tipos de errores
    if (attempts >= _maxRecoveryAttempts) {
      return true;
    }

    if (lastAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
      if (timeSinceLastAttempt < const Duration(seconds: 30)) {
        return true;
      }
    }

    return false;
  }

  ErrorRecoveryStrategy? _selectRecoveryStrategy(PageError error) {
    // Primero verificar estrategias personalizadas
    if (customStrategies.isNotEmpty) {
      for (final strategy in customStrategies) {
        if (_isStrategyApplicable(strategy, error)) {
          return strategy;
        }
      }
    }

    // Estrategias por defecto basadas en categoría y severidad
    switch (error.category) {
      case ErrorCategory.network:
        return _selectNetworkRecoveryStrategy(error);
      case ErrorCategory.business:
        return _selectBusinessRecoveryStrategy(error);
      case ErrorCategory.validation:
        return _selectValidationRecoveryStrategy(error);
      case ErrorCategory.widget:
        return _selectWidgetRecoveryStrategy(error);
      case ErrorCategory.permission:
        return _selectPermissionRecoveryStrategy(error);
      case ErrorCategory.system:
        return _selectSystemRecoveryStrategy(error);
    }
  }

  ErrorRecoveryStrategy _selectNetworkRecoveryStrategy(PageError error) {
    switch (error.severity) {
      case ErrorSeverity.low:
      case ErrorSeverity.medium:
        return ErrorRecoveryStrategy.retry;
      case ErrorSeverity.high:
        return ErrorRecoveryStrategy.fallback;
      case ErrorSeverity.critical:
        return ErrorRecoveryStrategy.navigation;
    }
  }

  ErrorRecoveryStrategy _selectBusinessRecoveryStrategy(PageError error) {
    switch (error.severity) {
      case ErrorSeverity.low:
        return ErrorRecoveryStrategy.ignore;
      case ErrorSeverity.medium:
        return ErrorRecoveryStrategy.refresh;
      case ErrorSeverity.high:
        return ErrorRecoveryStrategy.restart;
      case ErrorSeverity.critical:
        return ErrorRecoveryStrategy.navigation;
    }
  }

  ErrorRecoveryStrategy _selectValidationRecoveryStrategy(PageError error) {
    // Los errores de validación generalmente requieren intervención del usuario
    return ErrorRecoveryStrategy.ignore;
  }

  ErrorRecoveryStrategy _selectWidgetRecoveryStrategy(PageError error) {
    switch (error.severity) {
      case ErrorSeverity.low:
        return ErrorRecoveryStrategy.ignore;
      case ErrorSeverity.medium:
        return ErrorRecoveryStrategy.refresh;
      case ErrorSeverity.high:
      case ErrorSeverity.critical:
        return ErrorRecoveryStrategy.restart;
    }
  }

  ErrorRecoveryStrategy _selectPermissionRecoveryStrategy(PageError error) {
    // Los errores de permisos usualmente requieren navegación o re-autenticación
    return ErrorRecoveryStrategy.navigation;
  }

  ErrorRecoveryStrategy _selectSystemRecoveryStrategy(PageError error) {
    switch (error.severity) {
      case ErrorSeverity.low:
      case ErrorSeverity.medium:
        return ErrorRecoveryStrategy.retry;
      case ErrorSeverity.high:
        return ErrorRecoveryStrategy.restart;
      case ErrorSeverity.critical:
        return ErrorRecoveryStrategy.navigation;
    }
  }

  bool _isStrategyApplicable(ErrorRecoveryStrategy strategy, PageError error) {
    // Lógica para determinar si una estrategia personalizada es aplicable
    // Por ahora, todas las estrategias personalizadas se consideran aplicables
    return true;
  }

  Future<bool> _executeRecoveryStrategy(
    ErrorRecoveryStrategy strategy,
    PageError error,
    BuildContext context,
  ) async {
    if (!context.mounted) return false;

    switch (strategy) {
      case ErrorRecoveryStrategy.retry:
        return await _executeRetryStrategy(error, context);
      case ErrorRecoveryStrategy.refresh:
        return await _executeRefreshStrategy(error, context);
      case ErrorRecoveryStrategy.fallback:
        return await _executeFallbackStrategy(error, context);
      case ErrorRecoveryStrategy.navigation:
        return await _executeNavigationStrategy(error, context);
      case ErrorRecoveryStrategy.restart:
        return await _executeRestartStrategy(error, context);
      case ErrorRecoveryStrategy.ignore:
        return _executeIgnoreStrategy(error, context);
    }
  }

  Future<bool> _executeRetryStrategy(PageError error, BuildContext context) async {
    try {
      // Para errores de red, intentar recargar datos
      if (error.category == ErrorCategory.network) {
        final bloc = context.read<BaseCrudBloc>();
        bloc.add(const RefreshEntitiesEvent());
        
        // Esperar un momento para que se complete la recarga
        await Future.delayed(const Duration(seconds: 2));
        return true;
      }
      
      // Para otros tipos de error, marcar como exitoso si no hay excepción
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _executeRefreshStrategy(PageError error, BuildContext context) async {
    try {
      final bloc = context.read<BaseCrudBloc>();
      bloc.add(const RefreshEntitiesEvent());
      
      // Esperar a que se complete el refresh
      await Future.delayed(const Duration(seconds: 3));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _executeFallbackStrategy(PageError error, BuildContext context) async {
    try {
      // Intentar usar datos en caché o mostrar contenido alternativo
      final bloc = context.read<BaseCrudBloc>();
      
      // Si hay datos en caché, marcar como exitoso
      final cachedData = bloc.state.dataState.data;
      if (cachedData != null && cachedData.isNotEmpty) {
        return true;
      }
      
      // Si no hay datos en caché, intentar cargar datos básicos
      bloc.add(const LoadEntitiesEvent());
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _executeNavigationStrategy(PageError error, BuildContext context) async {
    try {
      // Navegar a una página segura
      final navigator = Navigator.of(context);
      
      if (error.severity == ErrorSeverity.critical) {
        // Para errores críticos, ir al home
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        // Para otros errores, simplemente regresar
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          navigator.pushReplacementNamed('/home');
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _executeRestartStrategy(PageError error, BuildContext context) async {
    try {
      // Reiniciar el BLoC o trigger rebuild
      final bloc = context.read<BaseCrudBloc>();
      bloc.add(const ResetStateEvent());
      
      // Esperar a que se reinicie
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Recargar datos
      bloc.add(const LoadEntitiesEvent(forceRefresh: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  bool _executeIgnoreStrategy(PageError error, BuildContext context) {
    // Para errores de baja severidad, simplemente ignorar
    return error.severity == ErrorSeverity.low;
  }

  void _recordRecoveryAttempt(PageError error) {
    final errorKey = '${error.category.name}_${error.pageId}';
    _recoveryAttempts[errorKey] = (_recoveryAttempts[errorKey] ?? 0) + 1;
    _lastRecoveryTimes[errorKey] = DateTime.now();
  }

  void _clearRecoveryHistory(PageError error) {
    final errorKey = '${error.category.name}_${error.pageId}';
    _recoveryAttempts.remove(errorKey);
    _lastRecoveryTimes.remove(errorKey);
  }

  /// Limpia el historial de recuperación para todos los errores
  void clearAllRecoveryHistory() {
    _recoveryAttempts.clear();
    _lastRecoveryTimes.clear();
  }

  /// Obtiene estadísticas de recuperación
  Map<String, dynamic> getRecoveryStats() {
    return {
      'total_recovery_attempts': _recoveryAttempts.values.fold(0, (a, b) => a + b),
      'unique_error_types': _recoveryAttempts.length,
      'recovery_attempts_by_error': Map.from(_recoveryAttempts),
      'last_recovery_times': _lastRecoveryTimes.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'grace_period_minutes': _recoveryGracePeriod.inMinutes,
      'max_attempts_per_error': _maxRecoveryAttempts,
    };
  }

  void dispose() {
    _recoveryAttempts.clear();
    _lastRecoveryTimes.clear();
  }
}

/// Eventos adicionales para BaseCrudBloc si no existen
class ResetStateEvent extends BaseCrudEvent {
  const ResetStateEvent();
  
  @override
  EventValidationResult validate() => (true, <String>[]);
  
  @override
  String get eventType => 'ResetState';
  
  @override
  Map<String, dynamic> get eventData => {};
}
