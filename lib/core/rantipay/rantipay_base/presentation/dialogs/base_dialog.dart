import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Native tuple patterns - no external dependencies
/// Result type for dialog operations using native Dart tuples
typedef DialogResult<T> = (T? result, bool cancelled);

/// Universal base dialog that eliminates 300+ lines of duplicate code from:
/// - bpa_confirmation_dialog.dart (95 lines)
/// - bpa_error_dialog.dart (78 lines)
/// - bpa_loading_dialog.dart (68 lines)
/// - bpa_input_dialog.dart (125 lines)
/// - Plus 6+ other dialog widgets
/// 
/// Performance targets:
/// - Dialog animations: <250ms
/// - Input validation: <50ms
/// - Memory footprint: <1MB per dialog
/// - Touch responsiveness: <100ms
abstract class BaseDialog<T> extends StatefulWidget {
  
  final String? title;
  final Widget? titleIcon;
  final String? content;
  final Widget? contentWidget;
  final List<DialogAction>? actions;
  final bool dismissible;
  final bool useRootNavigator;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsetsGeometry? titlePadding;
  final TextAlign? contentTextAlign;
  final MainAxisAlignment? actionsAlignment;
  final VerticalDirection? actionsOverflowDirection;
  final double? actionsOverflowButtonSpacing;
  final Duration? insetAnimationDuration;
  final Curve? insetAnimationCurve;
  final bool enableAutoFocus;
  final bool enableHapticFeedback;
  final SystemUiOverlayStyle? systemOverlayStyle;
  
  const BaseDialog({
    super.key,
    this.title,
    this.titleIcon,
    this.content,
    this.contentWidget,
    this.actions,
    this.dismissible = true,
    this.useRootNavigator = true,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.contentPadding,
    this.actionsPadding,
    this.titlePadding,
    this.contentTextAlign,
    this.actionsAlignment,
    this.actionsOverflowDirection,
    this.actionsOverflowButtonSpacing,
    this.insetAnimationDuration,
    this.insetAnimationCurve,
    this.enableAutoFocus = true,
    this.enableHapticFeedback = true,
    this.systemOverlayStyle,
  });
  
  // Abstract methods for concrete implementations
  Widget buildDialogContent(BuildContext context);
  List<DialogAction> buildDialogActions(BuildContext context);
  void onDialogResult(T? result);
  
  @override
  BaseDialogState<T> createState();
  
  /// Static helper methods for common dialog types
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
  }
  
  static Future<String?> showInput({
    required BuildContext context,
    required String title,
    String? content,
    String? hintText,
    String? initialValue,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    String? Function(String?)? validator,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => InputDialog(
        title: title,
        content: content,
        hintText: hintText,
        initialValue: initialValue,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        validator: validator,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }
  
  static void showError({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        content: content,
        buttonText: buttonText,
        onDismiss: onDismiss,
      ),
    );
  }
  
  static void showLoading({
    required BuildContext context,
    String? message,
    bool dismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => LoadingDialog(
        message: message,
      ),
    );
  }
}

abstract class BaseDialogState<T> extends State<BaseDialog<T>>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupSystemUI();
    _triggerHapticFeedback();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: widget.insetAnimationDuration ?? const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.insetAnimationCurve ?? Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.insetAnimationCurve ?? Curves.easeOut,
    ));
    
    _animationController.forward();
  }
  
  void _setupSystemUI() {
    if (widget.systemOverlayStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(widget.systemOverlayStyle!);
    }
  }
  
  void _triggerHapticFeedback() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void dismissDialog([T? result]) {
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    
    widget.onDialogResult(result);
    Navigator.of(context, rootNavigator: widget.useRootNavigator).pop(result);
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildDialog(context),
          ),
        );
      },
    );
  }
  
  Widget _buildDialog(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(context),
      content: _buildContent(context),
      actions: _buildActions(context),
      backgroundColor: widget.backgroundColor,
      elevation: widget.elevation,
      shape: widget.shape,
      contentPadding: widget.contentPadding,
      actionsPadding: widget.actionsPadding,
      titlePadding: widget.titlePadding,
      actionsAlignment: widget.actionsAlignment,
      actionsOverflowDirection: widget.actionsOverflowDirection,
      actionsOverflowButtonSpacing: widget.actionsOverflowButtonSpacing,
    );
  }
  
  Widget? _buildTitle(BuildContext context) {
    if (widget.title == null && widget.titleIcon == null) return null;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.titleIcon != null) ...[
          widget.titleIcon!,
          const SizedBox(width: 8),
        ],
        if (widget.title != null)
          Expanded(
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
      ],
    );
  }
  
  Widget? _buildContent(BuildContext context) {
    if (widget.contentWidget != null) {
      return widget.contentWidget;
    }
    
    if (widget.content != null) {
      return Text(
        widget.content!,
        textAlign: widget.contentTextAlign,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    
    return widget.buildDialogContent(context);
  }
  
  List<Widget>? _buildActions(BuildContext context) {
    final actions = widget.actions ?? widget.buildDialogActions(context);
    
    if (actions.isEmpty) return null;
    
    return actions.map((action) => action.build(context, this)).toList();
  }
}

/// Dialog action configuration
class DialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isDefault;
  final bool isDestructive;
  final bool isEnabled;
  final IconData? icon;
  final ButtonStyle? style;
  
  const DialogAction({
    required this.text,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
    this.isEnabled = true,
    this.icon,
    this.style,
  });
  
  Widget build(BuildContext context, BaseDialogState state) {
    if (isDefault) {
      return FilledButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
        style: isDestructive
            ? FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              )
            : style,
      );
    }
    
    return TextButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(text),
      style: isDestructive
          ? TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            )
          : style,
    );
  }
}

// ===== CONCRETE DIALOG IMPLEMENTATIONS =====

class ConfirmationDialog extends BaseDialog<bool> {
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final IconData? icon;
  
  const ConfirmationDialog({
    super.key,
    required String title,
    required String content,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.icon,
  }) : super(
    title: title,
    content: content,
  );
  
  @override
  Widget buildDialogContent(BuildContext context) => const SizedBox.shrink();
  
  @override
  Widget? buildTitleIcon(BuildContext context) {
    return icon != null ? Icon(icon) : null;
  }
  
  @override
  List<DialogAction> buildDialogActions(BuildContext context) {
    return [
      DialogAction(
        text: cancelText,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      DialogAction(
        text: confirmText,
        isDefault: true,
        isDestructive: isDestructive,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ];
  }
  
  @override
  void onDialogResult(bool? result) {}
  
  @override
  BaseDialogState<bool> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends BaseDialogState<bool> {}

class InputDialog extends BaseDialog<String> {
  final String? hintText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final String? Function(String?)? validator;
  final String confirmText;
  final String cancelText;
  
  const InputDialog({
    super.key,
    required String super.title,
    super.content,
    this.hintText,
    this.initialValue,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.validator,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
  });
  
  @override
  Widget buildDialogContent(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      autofocus: true,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
  
  @override
  List<DialogAction> buildDialogActions(BuildContext context) {
    return [
      DialogAction(
        text: cancelText,
        onPressed: () => Navigator.of(context).pop(null),
      ),
      DialogAction(
        text: confirmText,
        isDefault: true,
        onPressed: () {
          // Get text from TextField and validate
          final text = ''; // TODO: Get actual text from TextField
          Navigator.of(context).pop(text);
        },
      ),
    ];
  }
  
  @override
  void onDialogResult(String? result) {}
  
  @override
  BaseDialogState<String> createState() => _InputDialogState();
}

class _InputDialogState extends BaseDialogState<String> {}

class ErrorDialog extends BaseDialog<void> {
  final String buttonText;
  final VoidCallback? onDismiss;
  
  const ErrorDialog({
    super.key,
    required String title,
    required String content,
    this.buttonText = 'OK',
    this.onDismiss,
  }) : super(
    title: title,
    content: content,
    titleIcon: const Icon(Icons.error, color: Colors.red),
  );
  
  @override
  Widget buildDialogContent(BuildContext context) => const SizedBox.shrink();
  
  @override
  List<DialogAction> buildDialogActions(BuildContext context) {
    return [
      DialogAction(
        text: buttonText,
        isDefault: true,
        onPressed: () {
          Navigator.of(context).pop();
          onDismiss?.call();
        },
      ),
    ];
  }
  
  @override
  void onDialogResult(void result) {}
  
  @override
  BaseDialogState<void> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends BaseDialogState<void> {}

class LoadingDialog extends BaseDialog<void> {
  final String? message;
  
  const LoadingDialog({
    super.key,
    this.message,
  }) : super(
    dismissible: false,
  );
  
  @override
  Widget buildDialogContent(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(width: 16),
        Text(message ?? 'Loading...'),
      ],
    );
  }
  
  @override
  List<DialogAction> buildDialogActions(BuildContext context) => [];
  
  @override
  void onDialogResult(void result) {}
  
  @override
  BaseDialogState<void> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends BaseDialogState<void> {}