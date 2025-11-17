import 'package:flutter/material.dart';
import '../../design_tokens.dart';
import '../../ranti_colors.dart';

/// Variantes del botón RantiPay
enum RantiButtonVariant {
  primary,    // Acción principal (fondo de color, texto blanco)
  secondary,  // Acción secundaria (borde de color, texto de color)
  text,       // Acción terciaria (solo texto, sin fondo)
  outlined,   // Acción especial (solo borde)
  danger,     // Acciones destructivas (rojo)
  success,    // Confirmaciones (verde)
  tiktok,     // Estilo TikTok (monocromático)
}

/// Tamaños del botón
enum RantiButtonSize {
  small,      // Botones compactos
  medium,     // Tamaño estándar
  large,      // Botones prominentes
}

/// Botón base altamente personalizable para RantiPay
/// Soporta múltiples variantes, temas dinámicos y responsividad
class RantiButton extends StatefulWidget {
  /// Función a ejecutar cuando se presiona el botón
  final VoidCallback? onPressed;
  
  /// Texto del botón
  final String? text;
  
  /// Widget personalizado para el contenido (alternativa al texto)
  final Widget? child;
  
  /// Variante visual del botón
  final RantiButtonVariant variant;
  
  /// Tamaño del botón
  final RantiButtonSize size;
  
  /// Icono opcional al inicio del botón
  final IconData? leadingIcon;
  
  /// Icono opcional al final del botón
  final IconData? trailingIcon;
  
  /// Si el botón está en estado de carga
  final bool isLoading;
  
  /// Ancho del botón (null = ajustar al contenido, double.infinity = ancho completo)
  final double? width;
  
  /// Color personalizado (anula el color del tema)
  final Color? customColor;
  
  /// Elevación personalizada
  final double? elevation;
  
  const RantiButton({
    super.key,
    this.onPressed,
    this.text,
    this.child,
    this.variant = RantiButtonVariant.primary,
    this.size = RantiButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.width,
    this.customColor,
    this.elevation,
  }) : assert(text != null || child != null, 'Debe proporcionar texto o widget hijo');

  /// Constructor para botón primario
  const RantiButton.primary({
    super.key,
    required this.onPressed,
    this.text,
    this.child,
    this.size = RantiButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.width,
    this.customColor,
  }) : variant = RantiButtonVariant.primary,
       elevation = null;

  /// Constructor para botón secundario
  const RantiButton.secondary({
    super.key,
    required this.onPressed,
    this.text,
    this.child,
    this.size = RantiButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.width,
    this.customColor,
  }) : variant = RantiButtonVariant.secondary,
       elevation = null;

  /// Constructor para botón de texto
  const RantiButton.text({
    super.key,
    required this.onPressed,
    this.text,
    this.child,
    this.size = RantiButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.width,
    this.customColor,
  }) : variant = RantiButtonVariant.text,
       elevation = null;

  /// Constructor para botón TikTok
  const RantiButton.tiktok({
    super.key,
    required this.onPressed,
    this.text,
    this.child,
    this.size = RantiButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.width,
  }) : variant = RantiButtonVariant.tiktok,
       customColor = null,
       elevation = null;

  @override
  State<RantiButton> createState() => _RantiButtonState();
}

class _RantiButtonState extends State<RantiButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: RantiDesignTokens.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: RantiDesignTokens.curveFastOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Obtiene los estilos específicos para cada variante
  _ButtonStyles _getButtonStyles(BuildContext context) {
    switch (widget.variant) {
      case RantiButtonVariant.primary:
        final primaryColor = widget.customColor ?? RantiColors.getPrimary(context);
        return _ButtonStyles(
          backgroundColor: primaryColor,
          foregroundColor: RantiColors.white,
          borderColor: primaryColor,
          elevation: RantiDesignTokens.elevationS,
        );
        
      case RantiButtonVariant.secondary:
        final primaryColor = widget.customColor ?? RantiColors.getPrimary(context);
        return _ButtonStyles(
          backgroundColor: Colors.transparent,
          foregroundColor: primaryColor,
          borderColor: primaryColor,
          elevation: [],
        );
        
      case RantiButtonVariant.text:
        final primaryColor = widget.customColor ?? RantiColors.getPrimary(context);
        return _ButtonStyles(
          backgroundColor: Colors.transparent,
          foregroundColor: primaryColor,
          borderColor: Colors.transparent,
          elevation: [],
        );
        
      case RantiButtonVariant.outlined:
        final borderColor = widget.customColor ?? RantiColors.getBorder(context);
        return _ButtonStyles(
          backgroundColor: Colors.transparent,
          foregroundColor: RantiColors.getTextPrimary(context),
          borderColor: borderColor,
          elevation: [],
        );
        
      case RantiButtonVariant.danger:
        return _ButtonStyles(
          backgroundColor: RantiColors.error,
          foregroundColor: RantiColors.white,
          borderColor: RantiColors.error,
          elevation: RantiDesignTokens.elevationS,
        );
        
      case RantiButtonVariant.success:
        return _ButtonStyles(
          backgroundColor: RantiColors.success,
          foregroundColor: RantiColors.white,
          borderColor: RantiColors.success,
          elevation: RantiDesignTokens.elevationS,
        );
        
      case RantiButtonVariant.tiktok:
        return _ButtonStyles(
          backgroundColor: RantiColors.tiktokAction.withOpacity(RantiColors.opacity20),
          foregroundColor: RantiColors.tiktokText,
          borderColor: RantiColors.tiktokAction.withOpacity(RantiColors.opacity40),
          elevation: RantiDesignTokens.tiktokShadow,
        );
    }
  }

  /// Obtiene dimensiones específicas para cada tamaño
  _ButtonDimensions _getButtonDimensions(BuildContext context) {
    switch (widget.size) {
      case RantiButtonSize.small:
        return _ButtonDimensions(
          height: RantiDesignTokens.getResponsiveSpacing(context, 32),
          paddingHorizontal: RantiDesignTokens.getResponsiveSpacing(context, RantiDesignTokens.spaceM),
          fontSize: RantiDesignTokens.getResponsiveFontSize(context, RantiDesignTokens.fontSizeS),
          iconSize: RantiDesignTokens.getResponsiveIconSize(context, RantiDesignTokens.iconSizeS),
          borderRadius: RantiDesignTokens.getResponsiveRadius(context, RantiDesignTokens.radiusM),
        );
        
      case RantiButtonSize.medium:
        return _ButtonDimensions(
          height: RantiDesignTokens.getResponsiveSpacing(context, 44),
          paddingHorizontal: RantiDesignTokens.getResponsiveSpacing(context, RantiDesignTokens.spaceL),
          fontSize: RantiDesignTokens.getResponsiveFontSize(context, RantiDesignTokens.fontSizeM),
          iconSize: RantiDesignTokens.getResponsiveIconSize(context, RantiDesignTokens.iconSizeM),
          borderRadius: RantiDesignTokens.getResponsiveRadius(context, RantiDesignTokens.radiusL),
        );
        
      case RantiButtonSize.large:
        return _ButtonDimensions(
          height: RantiDesignTokens.getResponsiveSpacing(context, 56),
          paddingHorizontal: RantiDesignTokens.getResponsiveSpacing(context, RantiDesignTokens.spaceXL),
          fontSize: RantiDesignTokens.getResponsiveFontSize(context, RantiDesignTokens.fontSizeL),
          iconSize: RantiDesignTokens.getResponsiveIconSize(context, RantiDesignTokens.iconSizeL),
          borderRadius: RantiDesignTokens.getResponsiveRadius(context, RantiDesignTokens.radiusXL),
        );
    }
  }

  /// Construye el contenido del botón
  Widget _buildButtonContent(BuildContext context, _ButtonStyles styles, _ButtonDimensions dimensions) {
    if (widget.isLoading) {
      return SizedBox(
        width: dimensions.iconSize,
        height: dimensions.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(styles.foregroundColor),
        ),
      );
    }

    final List<Widget> children = [];

    // Icono inicial
    if (widget.leadingIcon != null) {
      children.add(
        Icon(
          widget.leadingIcon,
          size: dimensions.iconSize,
          color: styles.foregroundColor,
        ),
      );
      if (widget.text != null || widget.child != null) {
        children.add(SizedBox(width: RantiDesignTokens.spaceS));
      }
    }

    // Contenido principal
    if (widget.child != null) {
      children.add(widget.child!);
    } else if (widget.text != null) {
      children.add(
        Text(
          widget.text!,
          style: TextStyle(
            fontSize: dimensions.fontSize,
            fontWeight: RantiDesignTokens.weightMedium,
            color: styles.foregroundColor,
          ),
        ),
      );
    }

    // Icono final
    if (widget.trailingIcon != null) {
      if (widget.text != null || widget.child != null) {
        children.add(SizedBox(width: RantiDesignTokens.spaceS));
      }
      children.add(
        Icon(
          widget.trailingIcon,
          size: dimensions.iconSize,
          color: styles.foregroundColor,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final styles = _getButtonStyles(context);
    final dimensions = _getButtonDimensions(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.width,
        height: dimensions.height,
        decoration: BoxDecoration(
          color: isEnabled 
              ? styles.backgroundColor 
              : styles.backgroundColor.withOpacity(RantiColors.opacity40),
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
          border: styles.borderColor != Colors.transparent
              ? Border.all(
                  color: isEnabled 
                      ? styles.borderColor 
                      : styles.borderColor.withOpacity(RantiColors.opacity40),
                  width: 1.5,
                )
              : null,
          boxShadow: isEnabled ? styles.elevation : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(dimensions.borderRadius),
            onTap: isEnabled ? widget.onPressed : null,
            onTapDown: isEnabled ? (_) {
              _animationController.forward();
            } : null,
            onTapUp: isEnabled ? (_) {
              _animationController.reverse();
            } : null,
            onTapCancel: isEnabled ? () {
              _animationController.reverse();
            } : null,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: dimensions.paddingHorizontal,
              ),
              child: Center(
                child: _buildButtonContent(context, styles, dimensions),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clase helper para estilos del botón
class _ButtonStyles {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final List<BoxShadow> elevation;

  _ButtonStyles({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.elevation,
  });
}

/// Clase helper para dimensiones del botón
class _ButtonDimensions {
  final double height;
  final double paddingHorizontal;
  final double fontSize;
  final double iconSize;
  final double borderRadius;

  _ButtonDimensions({
    required this.height,
    required this.paddingHorizontal,
    required this.fontSize,
    required this.iconSize,
    required this.borderRadius,
  });
}