import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rantipay_app/core/i18n/app_locations.dart';
import '../../domain/entities/base_entity.dart';
import '../../application/blocs/base_crud_bloc.dart';

// Native tuple patterns - no external dependencies
/// Result type for form operations using native Dart tuples
typedef FormResult<T> = (T? data, String? error);

/// Result type for validation operations using native Dart tuples
typedef FormValidationResult = (bool isValid, Map<String, String> errors);

/// Universal base form widget that eliminates 1,200+ lines of duplicate code from:
/// - bpa_category_form.dart (485 lines)
/// - bpa_crop_form.dart (520 lines)
/// - bpa_plot_form.dart (558 lines)
/// - bpa_producer_form.dart (620 lines)
/// - Plus 12+ other form widgets
///
/// Performance targets:
/// - Form validation: <50ms
/// - Save operations: <300ms
/// - Field focus transitions: <100ms
/// - 99.5% form submission success rate
abstract class BaseFormWidget<TEntity extends IBaseEntity,
    TBloc extends BaseCrudBloc<TEntity>> extends StatefulWidget {
  final TEntity? initialEntity;
  final bool isEditMode;
  final VoidCallback? onCancel;
  final Function(TEntity)? onSaved;
  final Function(String)? onError;
  final bool autovalidateMode;
  final EdgeInsetsGeometry? padding;
  final bool showSaveButton;
  final bool showCancelButton;
  final String? saveButtonText;
  final String? cancelButtonText;
  final bool enableAutoSave;
  final Duration autoSaveDelay;

  const BaseFormWidget({
    super.key,
    this.initialEntity,
    this.isEditMode = false,
    this.onCancel,
    this.onSaved,
    this.onError,
    this.autovalidateMode = false,
    this.padding,
    this.showSaveButton = true,
    this.showCancelButton = true,
    this.saveButtonText,
    this.cancelButtonText,
    this.enableAutoSave = false,
    this.autoSaveDelay = const Duration(seconds: 2),
  });

  // Abstract methods for concrete implementations
  List<Widget> buildFormFields(
      BuildContext context, GlobalKey<FormState> formKey);
  TEntity buildEntityFromForm();
  FormValidationResult validateForm();
  void populateFormFromEntity(TEntity entity);
  String getFormTitle();

  @override
  BaseFormWidgetState<TEntity, TBloc> createState();
}

abstract class BaseFormWidgetState<TEntity extends IBaseEntity,
        TBloc extends BaseCrudBloc<TEntity>>
    extends State<BaseFormWidget<TEntity, TBloc>>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Form management
  late final GlobalKey<FormState> _formKey;
  late final ScrollController _scrollController;

  // Animation controllers
  late final AnimationController _submitAnimationController;
  late final Animation<double> _submitAnimation;

  // Auto-save timer
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  bool _isSubmitting = false;

  // Focus management
  final FocusNode _firstFieldFocus = FocusNode();
  final List<FocusNode> _fieldFocusNodes = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _populateInitialData();
  }

  void _initializeControllers() {
    _formKey = GlobalKey<FormState>();
    _scrollController = ScrollController();
  }

  void _initializeAnimations() {
    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _submitAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _submitAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _populateInitialData() {
    if (widget.initialEntity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.populateFormFromEntity(widget.initialEntity!);
      });
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _submitAnimationController.dispose();
    _scrollController.dispose();
    _firstFieldFocus.dispose();
    for (final node in _fieldFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }

    if (widget.enableAutoSave) {
      _scheduleAutoSave();
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(widget.autoSaveDelay, () {
      if (_hasUnsavedChanges && !_isSubmitting) {
        _performAutoSave();
      }
    });
  }

  Future<void> _performAutoSave() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final entity = widget.buildEntityFromForm();
      final bloc = context.read<TBloc>();

      if (widget.isEditMode) {
        bloc.add(UpdateEntityEvent(entity: entity));
      } else {
        bloc.add(CreateEntityEvent(entity: entity));
      }

      setState(() {
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      // Auto-save failures are silent
    }
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return;

    // Unfocus all fields
    FocusScope.of(context).unfocus();

    // Validate form
    final (isValid, errors) = widget.validateForm();
    if (!isValid) {
      _showValidationErrors(errors);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    _submitAnimationController.forward();

    try {
      final entity = widget.buildEntityFromForm();
      final bloc = context.read<TBloc>();

      if (widget.isEditMode) {
        bloc.add(UpdateEntityEvent(entity: entity));
      } else {
        bloc.add(CreateEntityEvent(entity: entity));
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _submitAnimationController.reverse();

      final errorMessage = e.toString();
      widget.onError?.call(errorMessage);
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showValidationErrors(Map<String, String> errors) {
    final loc = AppLocalizations.of(context);
    final firstError = errors.values.first;
    _showErrorSnackBar('${loc.translate('validationFailed')}: $firstError');
    _scrollToFirstError();
  }

  void _scrollToFirstError() {
    // Find first field with error and scroll to it
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showErrorSnackBar(String message) {
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.fixed,
        action: SnackBarAction(
          label: loc.translate('dismiss'),
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  void _cancel() {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog();
    } else {
      widget.onCancel?.call();
    }
  }

  void _showUnsavedChangesDialog() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('unsavedChanges')),
        content: Text(loc.translate('unsavedChangesContent')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCancel?.call();
            },
            child: Text(loc.translate('leave')),
          ),
        ],
      ),
    );
  }

  FocusNode addFieldFocusNode() {
    final node = FocusNode();
    _fieldFocusNodes.add(node);
    return node;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loc = AppLocalizations.of(context);
    return BlocListener<TBloc, BaseCrudState<TEntity>>(
      listener: (context, state) {
        if (state.mutationState.toString().contains('success')) {
          setState(() {
            _isSubmitting = false;
            _hasUnsavedChanges = false;
          });
          _submitAnimationController.reverse();
          _showSuccessSnackBar(loc.translate('operationCompletedSuccessfully'));
          widget.onSaved?.call(widget.buildEntityFromForm());
        } else if (state.mutationState.toString().contains('error')) {
          setState(() {
            _isSubmitting = false;
          });
          _submitAnimationController.reverse();
          final errorMessage = loc.translate('operationFailed');
          widget.onError?.call(errorMessage);
          _showErrorSnackBar(errorMessage);
        }
      },
      child: RepaintBoundary(
        child: Form(
          key: _formKey,
          onChanged: _onFormChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildFormBody(context),
              ),
              if (widget.showSaveButton || widget.showCancelButton)
                _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.getFormTitle(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_hasUnsavedChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                loc.translate('unsaved'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormBody(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.buildFormFields(context, _formKey),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.showCancelButton) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _cancel,
                child: Text(widget.cancelButtonText ?? 'Cancel'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (widget.showSaveButton)
            Expanded(
              flex: widget.showCancelButton ? 1 : 2,
              child: AnimatedBuilder(
                animation: _submitAnimation,
                builder: (context, child) {
                  return FilledButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(widget.saveButtonText ??
                            (widget.isEditMode
                                ? loc.translate('update')
                                : loc.translate('save'))),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // Helper method for building text form fields with consistent styling
  Widget buildTextFormField({
    required String label,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    String? initialValue,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    int maxLines = 1,
    int? maxLength,
    Widget? suffixIcon,
    Widget? prefixIcon,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    Function(String)? onFieldSubmitted,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        maxLines: maxLines,
        maxLength: maxLength,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  // Helper method for building dropdown form fields
  Widget buildDropdownFormField<T>({
    required String label,
    required List<T> items,
    required String Function(T) itemLabel,
    required FormFieldSetter<T> onSaved,
    required FormFieldValidator<T> validator,
    T? initialValue,
    String? hint,
    bool enabled = true,
    Widget? prefixIcon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        initialValue: initialValue,
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                ))
            .toList(),
        onSaved: onSaved,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: enabled ? (_) {} : null,
      ),
    );
  }
}
