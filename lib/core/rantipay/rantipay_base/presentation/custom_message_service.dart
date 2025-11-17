import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rantipay_app/core/i18n/app_locations.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/presentation/custom_snack_bar.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/presentation/message_detail_modal.dart';


enum MessageType {
  success,
  info,
  warning,
  error,
}

/// Servicio personalizado de mensajes con diseño TikTok-like
/// 
/// Características:
/// - Truncamiento inteligente de mensajes largos
/// - Botón expandir para ver contenido completo
/// - Prevención de propagación de errores al main
/// - Estilo moderno con animaciones suaves
class CustomMessageService {
  static const int _maxPreviewLength = 120;
  static const int _maxLinePreview = 2;

  /// Muestra un mensaje personalizado con truncamiento inteligente
  static void showMessage({
    required BuildContext context,
    required String message,
    MessageType type = MessageType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    try {
      final truncatedMessage = _truncateMessage(message);
      final hasMoreContent = message.length > _maxPreviewLength;
      
      // Programar el mensaje después del build cycle para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        
        try {
          // Verificar que hay un Scaffold disponible
          final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
          if (scaffoldMessenger != null) {
            scaffoldMessenger.clearSnackBars();
            scaffoldMessenger.showSnackBar(
              _buildCustomSnackBar(
                context: context,
                message: truncatedMessage,
                fullMessage: message,
                type: type,
                hasMore: hasMoreContent,
                duration: duration,
                actionLabel: actionLabel,
                onAction: onAction,
              ),
            );
          } else {
            // Fallback: usar print para debug
            debugPrint('📝 CustomMessage ($type): $truncatedMessage');
          }
        } catch (e) {
          debugPrint('⚠️ Error mostrando SnackBar: $e');
        }
      });
    } catch (e) {
      // Fallback silencioso para evitar propagación de errores
      debugPrint('⚠️ Error mostrando mensaje personalizado: $e');
    }
  }

  /// Muestra un mensaje de éxito
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showMessage(
      context: context,
      message: message,
      type: MessageType.success,
      duration: duration,
    );
  }

  /// Muestra un mensaje de error con manejo inteligente
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 6),
    String? stackTrace,
  }) {
    final fullMessage = stackTrace != null 
        ? '$message\n\n--- Stack Trace ---\n$stackTrace'
        : message;
        
    showMessage(
      context: context,
      message: fullMessage,
      type: MessageType.error,
      duration: duration,
      actionLabel: 'Reportar',
      onAction: () => _reportError(context, fullMessage),
    );
  }

  /// Muestra un mensaje de advertencia
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    showMessage(
      context: context,
      message: message,
      type: MessageType.warning,
      duration: duration,
    );
  }

  /// Muestra un mensaje informativo
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showMessage(
      context: context,
      message: message,
      type: MessageType.info,
      duration: duration,
    );
  }

  /// Trunca el mensaje de manera inteligente
  static String _truncateMessage(String message) {
    if (message.length <= _maxPreviewLength) {
      return message;
    }

    // Buscar un punto de corte natural (punto, coma, espacio)
    String truncated = message.substring(0, _maxPreviewLength);
    final lastPunctuation = _findLastPunctuation(truncated);
    
    if (lastPunctuation > _maxPreviewLength * 0.7) {
      truncated = message.substring(0, lastPunctuation + 1);
    }
    
    return '$truncated...';
  }

  /// Encuentra la última puntuación para un corte natural
  static int _findLastPunctuation(String text) {
    final punctuations = ['.', '!', '?', ',', ';', ':'];
    int lastIndex = -1;
    
    for (final punct in punctuations) {
      final index = text.lastIndexOf(punct);
      if (index > lastIndex) {
        lastIndex = index;
      }
    }
    
    // Si no hay puntuación, buscar el último espacio
    if (lastIndex == -1) {
      lastIndex = text.lastIndexOf(' ');
    }
    
    return lastIndex;
  }

  /// Construye el SnackBar personalizado
  static SnackBar _buildCustomSnackBar({
    required BuildContext context,
    required String message,
    required String fullMessage,
    required MessageType type,
    required bool hasMore,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.fixed,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: CustomSnackBar(
        message: message,
        fullMessage: fullMessage,
        type: type,
        hasMore: hasMore,
        onExpand: hasMore ? () => _showDetailModal(context, fullMessage, type) : null,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  /// Muestra el modal detallado con el mensaje completo
  static void _showDetailModal(
    BuildContext context,
    String fullMessage,
    MessageType type,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageDetailModal(
        message: fullMessage,
        type: type,
      ),
    );
  }

  /// Reporta un error copiándolo al clipboard
  static void _reportError(BuildContext context, String errorMessage) {
    try {
      Clipboard.setData(ClipboardData(text: errorMessage));
      final loc = AppLocalizations.of(context);
      
      // Usar addPostFrameCallback para evitar problemas con el Scaffold
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showInfo(
            context: context,
            message: loc.translate('errorCopiedToClipboard') ?? 
                    'Error copiado al portapapeles. Compártelo con soporte técnico.',
            duration: const Duration(seconds: 2),
          );
        }
      });
    } catch (e) {
      debugPrint('Error copiando al clipboard: $e');
    }
  }

  /// Interceptor global para prevenir propagación de errores
  static void interceptError(Object error, StackTrace? stackTrace) {
    try {
      debugPrint('🔴 Error interceptado: $error');
      if (stackTrace != null) {
        debugPrint('Stack: $stackTrace');
      }
      
      // Aquí puedes agregar lógica adicional como:
      // - Envío a analytics
      // - Logging específico
      // - Filtrado de errores conocidos
      
    } catch (e) {
      // Fallback final para evitar loops infinitos
      debugPrint('⚠️ Error en interceptor: $e');
    }
  }
}
