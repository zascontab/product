import 'package:rantipay_app/core/rantipay/constants/rantipay_app_constants.dart';

import 'rantipay_failures.dart';


/// RantiPay: Failures específicos de niveles de usuario
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: RantiPayFailures, RantiPayConstants
///
/// Uso:
/// ```dart
/// // Verificar si puede crear empresa
/// if (!canCreateCompany(userLevel)) {
///   return Left(RantiPayCompanyCreationDeniedFailure(
///     currentLevel: userLevel,
///   ));
/// }
/// ```

// ========== Failures de Funcionalidades por Nivel ==========

/// No puede crear empresas
class RantiPayCompanyCreationDeniedFailure
    extends RantiPayInsufficientLevelFailure {
  RantiPayCompanyCreationDeniedFailure({
    required super.currentLevel,
  }) : super(
          requiredLevel: RantiPayConstants.minLevelForCompany,
          feature: 'Creación de Empresas',
        );

  @override
  String get message =>
      'Para crear empresas necesitas ser Usuario Empresarial (Nivel ${RantiPayConstants.minLevelForCompany}). '
      'Tu nivel actual es $currentLevel.';
}

/// No puede acceder a reportes financieros
class RantiPayFinancialAccessDeniedFailure
    extends RantiPayInsufficientLevelFailure {
  RantiPayFinancialAccessDeniedFailure({
    required super.currentLevel,
  }) : super(
          requiredLevel: RantiPayConstants.minLevelForFinancial,
          feature: 'Reportes Financieros',
        );

  @override
  String get message =>
      'Para acceder a reportes financieros necesitas ser Usuario Financiero (Nivel ${RantiPayConstants.minLevelForFinancial}). '
      'Tu nivel actual es $currentLevel.';
}

/// No puede acceder a funciones enterprise
class RantiPayEnterpriseAccessDeniedFailure
    extends RantiPayInsufficientLevelFailure {
  RantiPayEnterpriseAccessDeniedFailure({
    required super.currentLevel,
  }) : super(
          requiredLevel: RantiPayConstants.minLevelForEnterprise,
          feature: 'Funciones Enterprise',
        );

  @override
  String get message =>
      'Para acceder a funciones enterprise necesitas ser Usuario Enterprise (Nivel ${RantiPayConstants.minLevelForEnterprise}). '
      'Tu nivel actual es $currentLevel.';
}

// ========== Failures de Actualización de Nivel ==========

/// Requisitos no cumplidos para upgrade
class RantiPayUpgradeRequirementsNotMetFailure extends RantiPayFailure {
  final int targetLevel;
  final List<String> missingRequirements;

  RantiPayUpgradeRequirementsNotMetFailure({
    required this.targetLevel,
    required this.missingRequirements,
  }) : super(
          message:
              'No cumples los requisitos para actualizar al nivel $targetLevel',
          code: 'UPGRADE001',
          details: {
            'targetLevel': targetLevel,
            'missingRequirements': missingRequirements,
          },
        );

  String get requirementsList => missingRequirements.join('\n• ');
}

/// Documentación pendiente para upgrade
class RantiPayPendingDocumentationFailure extends RantiPayFailure {
  final List<String> pendingDocuments;
  final int targetLevel;

  RantiPayPendingDocumentationFailure({
    required this.pendingDocuments,
    required this.targetLevel,
  }) : super(
          message:
              'Documentación pendiente para actualizar al nivel $targetLevel',
          code: 'UPGRADE002',
          details: {
            'pendingDocuments': pendingDocuments,
            'targetLevel': targetLevel,
          },
        );
}

/// Pago pendiente para upgrade
class RantiPayUpgradePaymentPendingFailure extends RantiPayFailure {
  final double amount;
  final int targetLevel;
  final String? paymentReference;

  RantiPayUpgradePaymentPendingFailure({
    required this.amount,
    required this.targetLevel,
    this.paymentReference,
  }) : super(
          message:
              'Pago de \$$amount pendiente para actualizar al nivel $targetLevel',
          code: 'UPGRADE003',
          details: {
            'amount': amount,
            'targetLevel': targetLevel,
            'paymentReference': paymentReference,
          },
        );
}

// ========== Failures de Límites por Nivel ==========

/// Límite diario por nivel excedido
class RantiPayDailyLimitByLevelFailure extends RantiPayTransactionLimitFailure {
  final int userLevel;

  RantiPayDailyLimitByLevelFailure({
    required super.amount, // Usar super parámetro
    required int userLevel,
  })  : userLevel = userLevel, // Inicializar userLevel
        super(
          limit: RantiPayConstants.dailyTransactionLimits[userLevel] ?? 0,
          limitType: 'diario',
        ) {
    // Guardar userLevel internamente
    (details as Map<String, dynamic>)['userLevel'] = userLevel;
  }

  @override
  String get message {
    final levelName =
        RantiPayConstants.userLevelNames[userLevel] ?? 'Nivel $userLevel';
    return 'Como $levelName, tu límite diario es de \$$limit. '
        'Intento de transacción: \$$amount';
  }
}

/// Límite mensual por nivel excedido
class RantiPayMonthlyLimitByLevelFailure extends RantiPayTransactionLimitFailure {
  final int userLevel;

  RantiPayMonthlyLimitByLevelFailure({
    required super.amount, // Usar super parámetro
    required int userLevel,
  })  : userLevel = userLevel, // Inicializar userLevel
        super(
          limit: RantiPayConstants.monthlyTransactionLimits[userLevel] ?? 0,
          limitType: 'mensual',
        ) {
    // Guardar userLevel internamente
    (details as Map<String, dynamic>)['userLevel'] = userLevel;
  }

  @override
  String get message {
    final levelName = RantiPayConstants.userLevelNames[userLevel] ?? 'Nivel $userLevel';
    return 'Como $levelName, tu límite mensual es de \$$limit. '
           'Has alcanzado este límite.';
  }
}

/// Límite de empresas por nivel excedido
/// Límite de empresas por nivel excedido
class RantiPayCompanyLimitByLevelFailure extends RantiPayCompanyLimitFailure {
  final int userLevel;

  RantiPayCompanyLimitByLevelFailure({
    required super.currentCount, // Usar super parámetro
    required int userLevel,
  })  : userLevel = userLevel, // Inicializar userLevel
        super(
          maxAllowed: RantiPayConstants.maxCompaniesPerLevel[userLevel] ?? 0,
        ) {
    // Guardar userLevel internamente
    (details as Map<String, dynamic>)['userLevel'] = userLevel;
  }

  @override
  String get message {
    final levelName =
        RantiPayConstants.userLevelNames[userLevel] ?? 'Nivel $userLevel';
    return 'Como $levelName, puedes tener máximo $maxAllowed empresa${maxAllowed == 1 ? '' : 's'}. '
        'Actualmente tienes $currentCount.';
  }
}

/// Límite de negocios por empresa excedido
class RantiPayBusinessLimitByLevelFailure extends RantiPayFailure {
  final int currentCount;
  final int maxAllowed;
  final int userLevel;
  final String companyName;

  RantiPayBusinessLimitByLevelFailure({
    required this.currentCount,
    required this.maxAllowed,
    required this.userLevel,
    required this.companyName,
  }) : super(
          message:
              _buildMessage(currentCount, maxAllowed, userLevel, companyName),
          code: 'LIMIT003',
          details: {
            'currentCount': currentCount,
            'maxAllowed': maxAllowed,
            'userLevel': userLevel,
            'companyName': companyName,
          },
        );

  static String _buildMessage(int current, int max, int level, String company) {
    final levelName = RantiPayConstants.userLevelNames[level] ?? 'Nivel $level';
    return 'Como $levelName, puedes tener máximo $max negocio${max == 1 ? '' : 's'} por empresa. '
        'La empresa "$company" ya tiene $current.';
  }
}

// ========== Helpers para verificación de niveles ==========

/// Helper para generar failures apropiados según el contexto
class RantiPayLevelFailureHelper {
  // Prevenir instanciación
  RantiPayLevelFailureHelper._();

  /// Genera el failure apropiado para una funcionalidad
  static RantiPayFailure getFailureForFeature(
    String feature,
    int currentLevel,
  ) {
    switch (feature.toLowerCase()) {
      case 'company':
      case 'empresa':
      case 'crear_empresa':
        return RantiPayCompanyCreationDeniedFailure(
          currentLevel: currentLevel,
        );

      case 'financial':
      case 'financiero':
      case 'reportes':
        return RantiPayFinancialAccessDeniedFailure(
          currentLevel: currentLevel,
        );

      case 'enterprise':
      case 'compliance':
      case 'sox':
        return RantiPayEnterpriseAccessDeniedFailure(
          currentLevel: currentLevel,
        );

      default:
        // Intentar inferir el nivel requerido
        int requiredLevel = _inferRequiredLevel(feature);
        return RantiPayInsufficientLevelFailure(
          currentLevel: currentLevel,
          requiredLevel: requiredLevel,
          feature: feature,
        );
    }
  }

  /// Infiere el nivel requerido basado en la funcionalidad
  static int _inferRequiredLevel(String feature) {
    final lowerFeature = feature.toLowerCase();

    if (lowerFeature.contains('empresa') ||
        lowerFeature.contains('company') ||
        lowerFeature.contains('negocio')) {
      return RantiPayConstants.minLevelForCompany;
    }

    if (lowerFeature.contains('financ') ||
        lowerFeature.contains('reporte') ||
        lowerFeature.contains('analisis')) {
      return RantiPayConstants.minLevelForFinancial;
    }

    if (lowerFeature.contains('enterprise') ||
        lowerFeature.contains('compliance') ||
        lowerFeature.contains('sox') ||
        lowerFeature.contains('audit')) {
      return RantiPayConstants.minLevelForEnterprise;
    }

    // Por defecto, asumir nivel básico + 1
    return RantiPayConstants.minUserLevel + 1;
  }

  /// Obtiene un mensaje descriptivo para el upgrade
  static String getUpgradeMessage(int currentLevel, int targetLevel) {
    final currentName =
        RantiPayConstants.userLevelNames[currentLevel] ?? 'Nivel $currentLevel';
    final targetName =
        RantiPayConstants.userLevelNames[targetLevel] ?? 'Nivel $targetLevel';

    return 'Para acceder a esta funcionalidad, necesitas actualizar de $currentName a $targetName.';
  }

  /// Obtiene los beneficios de un nivel
  static List<String> getLevelBenefits(int level) {
    switch (level) {
      case 1:
        return [
          'Transferencias básicas hasta \${RantiPayConstants.dailyTransactionLimits[1]}',
          'Pagos y cobros personales',
          'Historial de transacciones',
        ];

      case 2:
        return [
          'Todo lo del nivel anterior',
          'Crear hasta ${RantiPayConstants.maxCompaniesPerLevel[2]} empresas',
          'Hasta ${RantiPayConstants.maxBusinessesPerCompany[2]} negocios por empresa',
          'Límite diario de \${RantiPayConstants.dailyTransactionLimits[2]}',
          'Facturación electrónica básica',
        ];

      case 3:
        return [
          'Todo lo del nivel anterior',
          'Hasta ${RantiPayConstants.maxCompaniesPerLevel[3]} empresas',
          'Hasta ${RantiPayConstants.maxBusinessesPerCompany[3]} negocios por empresa',
          'Límite diario de \${RantiPayConstants.dailyTransactionLimits[3]}',
          'Reportes financieros avanzados',
          'Análisis de datos y métricas',
          'API para integraciones',
        ];

      case 4:
        return [
          'Todo lo del nivel anterior',
          'Sin límites de empresas o negocios',
          'Sin límites de transacción',
          'Compliance SOX',
          'Auditoría avanzada',
          'HSM dedicado',
          'Soporte prioritario 24/7',
          'Funciones enterprise personalizadas',
        ];

      default:
        return ['Nivel no válido'];
    }
  }
}
