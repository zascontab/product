import 'package:flutter/material.dart';
import '../../design_tokens.dart';
import '../../ranti_colors.dart';

/// Variantes de la tarjeta RantiPay
enum RantiCardVariant {
  surface,    // Superficie plana con color de fondo del tema
  elevated,   // Tarjeta elevada con sombra
  outlined,   // Tarjeta con borde y sin sombra
  filled,     // Tarjeta con fondo de color primario
  tiktok,     // Estilo TikTok (fondo negro/transparente)
}

/// Niveles de elevación para las tarjetas
enum RantiCardElevation {
  none,    // Sin elevación
  low,     // Elevación baja
  medium,  // Elevación media
  high,    // Elevación alta
}

/// Tarjeta base altamente personalizable para RantiPay
/// Soporta múltiples variantes, temas dinámicos y responsividad
class RantiCard extends StatelessWidget {
  /// Contenido de la tarjeta
  final Widget child;
  
  /// Variante visual de la tarjeta
  final RantiCardVariant variant;
  
  /// Nivel de elevación
  final RantiCardElevation elevation;
  
  /// Padding interno personalizado
  final EdgeInsetsGeometry? padding;
  
  /// Margin externo personalizado
  final EdgeInsetsGeometry? margin;
  
  /// Ancho de la tarjeta
  final double? width;
  
  /// Alto de la tarjeta
  final double? height;
  
  /// Color de fondo personalizado (anula el color del tema)
  final Color? backgroundColor;
  
  /// Color de borde personalizado
  final Color? borderColor;
  
  /// Radio de borde personalizado
  final double? borderRadius;
  
  /// Función a ejecutar cuando se toca la tarjeta
  final VoidCallback? onTap;
  
  /// Función a ejecutar cuando se mantiene presionada la tarjeta
  final VoidCallback? onLongPress;
  
  /// Clipea el contenido al borde de la tarjeta
  final bool clipContent;

  const RantiCard({
    super.key,
    required this.child,
    this.variant = RantiCardVariant.surface,
    this.elevation = RantiCardElevation.none,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.clipContent = false,
  });

  /// Constructor para tarjeta superficie
  const RantiCard.surface({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? backgroundColor,
    double? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool clipContent = false,
  }) : this(
          key: key,
          child: child,
          variant: RantiCardVariant.surface,
          elevation: RantiCardElevation.none,
          padding: padding,
          margin: margin,
          width: width,
          height: height,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          clipContent: clipContent,
        );

  /// Constructor para tarjeta elevada
  const RantiCard.elevated({
    Key? key,
    required Widget child,
    RantiCardElevation elevation = RantiCardElevation.medium,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? backgroundColor,
    double? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool clipContent = false,
  }) : this(
          key: key,
          child: child,
          variant: RantiCardVariant.elevated,
          elevation: elevation,
          padding: padding,
          margin: margin,
          width: width,
          height: height,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          clipContent: clipContent,
        );

  /// Constructor para tarjeta delineada
  const RantiCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool clipContent = false,
  }) : this(
          key: key,
          child: child,
          variant: RantiCardVariant.outlined,
          elevation: RantiCardElevation.none,
          padding: padding,
          margin: margin,
          width: width,
          height: height,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          clipContent: clipContent,
        );

  /// Constructor para tarjeta TikTok
  const RantiCard.tiktok({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool clipContent = true,
  }) : this(
          key: key,
          child: child,
          variant: RantiCardVariant.tiktok,
          elevation: RantiCardElevation.none,
          padding: padding,
          margin: margin,
          width: width,
          height: height,
          clipContent: clipContent,
          onTap: onTap,
          onLongPress: onLongPress,
        );

  /// Obtiene los estilos específicos para cada variante
  _CardStyles _getCardStyles(BuildContext context) {
    switch (variant) {
      case RantiCardVariant.surface:
        return _CardStyles(
          backgroundColor: backgroundColor ?? RantiColors.getSurface(context),
          borderColor: Colors.transparent,
          elevation: _getElevationShadows(),
        );
        
      case RantiCardVariant.elevated:
        return _CardStyles(
          backgroundColor: backgroundColor ?? RantiColors.getSurface(context),
          borderColor: Colors.transparent,
          elevation: _getElevationShadows(),
        );
        
      case RantiCardVariant.outlined:
        return _CardStyles(
          backgroundColor: backgroundColor ?? RantiColors.getSurface(context),
          borderColor: borderColor ?? RantiColors.getBorder(context),
          elevation: [],
        );
        
      case RantiCardVariant.filled:
        return _CardStyles(
          backgroundColor: backgroundColor ?? RantiColors.getPrimary(context),
          borderColor: Colors.transparent,
          elevation: _getElevationShadows(),
        );
        
      case RantiCardVariant.tiktok:
        return _CardStyles(
          backgroundColor: backgroundColor ?? RantiColors.tiktokSurface.withAlpha(128),
          borderColor: RantiColors.tiktokAction.withAlpha(64),
          elevation: RantiDesignTokens.tiktokShadow,
        );
    }
  }

  /// Obtiene las sombras de elevación según el nivel
  List<BoxShadow> _getElevationShadows() {
    switch (elevation) {
      case RantiCardElevation.none:
        return RantiDesignTokens.elevationNone;
      case RantiCardElevation.low:
        return RantiDesignTokens.elevationXS;
      case RantiCardElevation.medium:
        return RantiDesignTokens.elevationS;
      case RantiCardElevation.high:
        return RantiDesignTokens.elevationM;
    }
  }

  /// Obtiene el padding predeterminado
  EdgeInsetsGeometry _getDefaultPadding(BuildContext context) {
    if (padding != null) return padding!;
    
    return EdgeInsets.all(
      RantiDesignTokens.getResponsiveSpacing(context, RantiDesignTokens.spaceM),
    );
  }

  /// Obtiene el margin predeterminado
  EdgeInsetsGeometry _getDefaultMargin(BuildContext context) {
    if (margin != null) return margin!;
    
    return EdgeInsets.all(
      RantiDesignTokens.getResponsiveSpacing(context, RantiDesignTokens.spaceS),
    );
  }

  /// Obtiene el radio de borde
  double _getBorderRadius(BuildContext context) {
    if (borderRadius != null) return borderRadius!;
    
    return RantiDesignTokens.getResponsiveRadius(
      context,
      RantiDesignTokens.radiusL,
    );
  }

  @override
  Widget build(BuildContext context) {
    final styles = _getCardStyles(context);
    final defaultPadding = _getDefaultPadding(context);
    final defaultMargin = _getDefaultMargin(context);
    final radius = _getBorderRadius(context);
    
    final isInteractive = onTap != null || onLongPress != null;

    return Container(
      width: width,
      height: height,
      margin: defaultMargin,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          decoration: BoxDecoration(
            color: styles.backgroundColor,
            borderRadius: BorderRadius.circular(radius),
            border: styles.borderColor != Colors.transparent
                ? Border.all(
                    color: styles.borderColor,
                    width: 1.0,
                  )
                : null,
            boxShadow: styles.elevation,
          ),
          child: clipContent
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: _buildContent(context, defaultPadding, isInteractive, radius),
                )
              : _buildContent(context, defaultPadding, isInteractive, radius),
        ),
      ),
    );
  }

  /// Construye el contenido de la tarjeta
  Widget _buildContent(BuildContext context, EdgeInsetsGeometry defaultPadding, bool isInteractive, double radius) {
    if (isInteractive) {
      return InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: defaultPadding,
          child: child,
        ),
      );
    }
    
    return Container(
      padding: defaultPadding,
      child: child,
    );
  }
}

/// Clase helper para estilos de la tarjeta
class _CardStyles {
  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow> elevation;

  _CardStyles({
    required this.backgroundColor,
    required this.borderColor,
    required this.elevation,
  });
}