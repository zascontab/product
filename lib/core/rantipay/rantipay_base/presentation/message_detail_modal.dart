import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rantipay_app/core/i18n/app_locations.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/presentation/custom_message_service.dart';
import 'package:rantipay_app/core/theme/app_theme_shappi.dart';


/// Modal detallado para mostrar mensajes completos con estilo TikTok
/// 
/// Características:
/// - Scroll suave para contenido extenso
/// - Syntax highlighting para stack traces
/// - Botones de acción (copiar, reportar, compartir)
/// - Animaciones y transiciones fluidas
class MessageDetailModal extends StatefulWidget {
  final String message;
  final MessageType type;

  const MessageDetailModal({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  State<MessageDetailModal> createState() => _MessageDetailModalState();
}

class _MessageDetailModalState extends State<MessageDetailModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isStackTrace = false;
  String _displayMessage = '';
  String? _stackTraceContent;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _parseMessage();
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _parseMessage() {
    final stackTraceMarker = '--- Stack Trace ---';
    if (widget.message.contains(stackTraceMarker)) {
      final parts = widget.message.split(stackTraceMarker);
      _displayMessage = parts[0].trim();
      _stackTraceContent = parts.length > 1 ? parts[1].trim() : null;
      _isStackTrace = _stackTraceContent != null;
    } else {
      _displayMessage = widget.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ShappiRadius.large),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  _buildHandleBar(),
                  
                  // Header
                  _buildHeader(),
                  
                  // Content
                  Expanded(
                    child: _buildContent(scrollController),
                  ),
                  
                  // Actions
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(ShappiSpacing.large),
      decoration: BoxDecoration(
        color: _getColorForType(widget.type).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ShappiSpacing.small),
            decoration: BoxDecoration(
              color: _getColorForType(widget.type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForType(widget.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: ShappiSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitleForType(widget.type),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getColorForType(widget.type),
                  ),
                ),
                Text(
                  'Toca para seleccionar y copiar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(ShappiSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mensaje principal
          _buildMessageSection(),
          
          // Stack trace si existe
          if (_isStackTrace && _stackTraceContent != null) ...[
            const SizedBox(height: ShappiSpacing.large),
            _buildStackTraceSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ShappiSpacing.medium),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(ShappiRadius.medium),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: SelectableText(
        _displayMessage,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildStackTraceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.code,
              color: Colors.grey.shade600,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Stack Trace',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _copyStackTrace(),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copiar'),
              style: TextButton.styleFrom(
                foregroundColor: ShappiColors.primary,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxHeight: 300,
          ),
          padding: const EdgeInsets.all(ShappiSpacing.medium),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(ShappiRadius.medium),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              _stackTraceContent!,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: Colors.green,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final loc = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(ShappiSpacing.large),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _copyFullMessage,
              icon: const Icon(Icons.copy),
              label: Text(loc.translate('copy') ?? 'Copiar Todo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey.shade700,
                elevation: 0,
                side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ShappiRadius.medium),
                ),
              ),
            ),
          ),
          const SizedBox(width: ShappiSpacing.medium),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _reportIssue,
              icon: const Icon(Icons.bug_report),
              label: Text(loc.translate('report') ?? 'Reportar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getColorForType(widget.type),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ShappiRadius.medium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyFullMessage() {
    Clipboard.setData(ClipboardData(text: widget.message));
    _showFeedback('Mensaje completo copiado');
  }

  void _copyStackTrace() {
    if (_stackTraceContent != null) {
      Clipboard.setData(ClipboardData(text: _stackTraceContent!));
      _showFeedback('Stack trace copiado');
    }
  }

  void _reportIssue() {
    _copyFullMessage();
    _showFeedback('Error copiado. Compártelo con soporte técnico.');
    Navigator.of(context).pop();
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ShappiColors.success,
      ),
    );
  }

  Color _getColorForType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return ShappiColors.success;
      case MessageType.warning:
        return ShappiColors.warning;
      case MessageType.error:
        return ShappiColors.error;
      case MessageType.info:
        return ShappiColors.primary;
    }
  }

  IconData _getIconForType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.warning:
        return Icons.warning_amber_outlined;
      case MessageType.error:
        return Icons.error_outline;
      case MessageType.info:
        return Icons.info_outline;
    }
  }

  String _getTitleForType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return 'Operación Exitosa';
      case MessageType.warning:
        return 'Advertencia';
      case MessageType.error:
        return 'Error Detallado';
      case MessageType.info:
        return 'Información';
    }
  }
}