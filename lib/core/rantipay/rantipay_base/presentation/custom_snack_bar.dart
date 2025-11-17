import 'package:flutter/material.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/presentation/custom_message_service.dart';
import 'package:rantipay_app/core/rantipay_theme/ranti_colors.dart';
import 'package:rantipay_app/core/theme/app_theme_shappi.dart';


/// SnackBar personalizado con diseño TikTok-like
/// 
/// Características:
/// - Animaciones suaves y microinteracciones
/// - Gradiente de texto para truncamiento
/// - Botón expandir con iconografía moderna
/// - Colores contextuales por tipo de mensaje
class CustomSnackBar extends StatefulWidget {
  final String message;
  final String fullMessage;
  final MessageType type;
  final bool hasMore;
  final VoidCallback? onExpand;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CustomSnackBar({
    super.key,
    required this.message,
    required this.fullMessage,
    required this.type,
    required this.hasMore,
    this.onExpand,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<CustomSnackBar> createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animaciones
    _slideController.forward();
    if (widget.hasMore) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: ShappiSpacing.medium,
          vertical: ShappiSpacing.small,
        ),
        decoration: BoxDecoration(
          gradient: _getGradientForType(widget.type),
          borderRadius: BorderRadius.circular(ShappiRadius.large),
          boxShadow: [
            BoxShadow(
              color: _getColorForType(widget.type).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.hasMore ? widget.onExpand : null,
            borderRadius: BorderRadius.circular(ShappiRadius.large),
            child: Padding(
              padding: const EdgeInsets.all(ShappiSpacing.medium),
              child: Row(
                children: [
                  // Icono contextual
                  Container(
                    padding: const EdgeInsets.all(ShappiSpacing.small),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForType(widget.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: ShappiSpacing.medium),
                  
                  // Contenido del mensaje
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mensaje principal
                        _buildMessageText(),
                        
                        // Indicador de contenido adicional
                        if (widget.hasMore) ...[
                          const SizedBox(height: 4),
                          _buildMoreIndicator(),
                        ],
                      ],
                    ),
                  ),
                  
                  // Botones de acción
                  if (widget.hasMore || widget.actionLabel != null) ...[
                    const SizedBox(width: ShappiSpacing.small),
                    _buildActionButtons(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageText() {
    return ShaderMask(
      shaderCallback: widget.hasMore 
          ? (bounds) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white,
                Colors.white,
                Colors.white.withOpacity(0.3),
              ],
              stops: const [0.0, 0.7, 1.0],
            ).createShader(bounds)
          : (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.white],
            ).createShader(bounds),
      child: Text(
        widget.message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMoreIndicator() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Toca para ver más',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón expandir
        if (widget.hasMore)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.expand_more,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: widget.onExpand,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ),
          ),
        
        // Botón de acción personalizada
        if (widget.actionLabel != null) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: widget.onAction,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ShappiRadius.medium),
              ),
            ),
            child: Text(
              widget.actionLabel!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getColorForType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return RantiColors.success;
      case MessageType.warning:
        return RantiColors.warning;
      case MessageType.error:
        return RantiColors.error;
      case MessageType.info:
        return RantiColors.primary;
    }
  }

  LinearGradient _getGradientForType(MessageType type) {
    final baseColor = _getColorForType(type);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        baseColor.withOpacity(0.8),
      ],
    );
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
}