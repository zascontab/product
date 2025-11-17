// lib/core/presentation/widgets/material_context_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MaterialContextWrapper extends StatelessWidget {
  final Widget child;
  final bool useScaffold;

  const MaterialContextWrapper({
    super.key,
    required this.child,
    this.useScaffold = false,
  });

  @override
  Widget build(BuildContext context) {
    try {
      // Check if MaterialLocalizations exists
      MaterialLocalizations.of(context);

      // If we get here, we have MaterialLocalizations - return child directly
      return useScaffold ? Scaffold(body: child) : child;
    } catch (_) {
      // MaterialLocalizations not found - use minimal Material wrapper
      return Material(
        type: MaterialType.transparency,
        child: useScaffold ? SafeArea(child: child) : child,
      );
    }
  }
}
