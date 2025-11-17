/// RantiPay: Constantes generales de la aplicación
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: Ninguna
///
/// Uso:
/// ```dart
/// // Verificar si un nivel es válido
/// if (userLevel >= RantiPayConstants.minUserLevel &&
///     userLevel <= RantiPayConstants.maxUserLevel) {
///   // Nivel válido
/// }
/// ```
class RantiPayConstants {
  // Prevenir instanciación
  RantiPayConstants._();

  // ========== Niveles de Usuario ==========
  static const int minUserLevel = 1;
  static const int maxUserLevel = 4;

  // Niveles específicos
  static const int levelBasic = 1;
  static const int levelBusiness = 2;
  static const int levelFinancial = 3;
  static const int levelEnterprise = 4;

  // ========== Tiempos y Timeouts ==========
  // Timeouts de red (en segundos)
  static const int networkTimeoutSeconds = 30;
  static const int uploadTimeoutSeconds = 120;
  static const int downloadTimeoutSeconds = 120;

  // Tiempos de sesión (en minutos)
  static const int sessionTimeoutMinutes = 30;
  static const int sessionWarningMinutes = 5;

  // Tiempos de token (en minutos)
  static const int accessTokenDurationMinutes = 60;
  static const int refreshTokenDurationDays = 30;

  // Tiempos de OTP (en segundos/minutos)
  static const int otpExpirationMinutes = 5;
  static const int otpResendCooldownSeconds = 60;

  // ========== Límites de Reintentos ==========
  static const int maxNetworkRetries = 3;
  static const int maxLoginAttempts = 5;
  static const int maxOtpAttempts = 3;
  static const int maxPinAttempts = 3;

  // Delays de reintento (en milisegundos)
  static const int retryDelayBase = 1000;
  static const int retryDelayMax = 30000;

  // ========== Límites de Transacciones ==========
  // Por nivel de usuario
  static const Map<int, double> dailyTransactionLimits = {
    levelBasic: 1000.0,
    levelBusiness: 10000.0,
    levelFinancial: 100000.0,
    levelEnterprise: -1, // Sin límite
  };

  static const Map<int, double> monthlyTransactionLimits = {
    levelBasic: 5000.0,
    levelBusiness: 50000.0,
    levelFinancial: 500000.0,
    levelEnterprise: -1, // Sin límite
  };

  // ========== Límites de Empresas ==========
  static const Map<int, int> maxCompaniesPerLevel = {
    levelBasic: 0,
    levelBusiness: 3,
    levelFinancial: 10,
    levelEnterprise: -1, // Sin límite
  };

  static const Map<int, int> maxBusinessesPerCompany = {
    levelBasic: 0,
    levelBusiness: 5,
    levelFinancial: 20,
    levelEnterprise: -1, // Sin límite
  };

  // ========== Tamaños y Límites de Archivos ==========
  static const int maxImageSizeMB = 10;
  static const int maxDocumentSizeMB = 25;
  static const int maxVideoSizeMB = 100;
  static const int maxAttachmentsPerTransaction = 5;

  // En bytes
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;
  static const int maxDocumentSizeBytes = maxDocumentSizeMB * 1024 * 1024;
  static const int maxVideoSizeBytes = maxVideoSizeMB * 1024 * 1024;

  // ========== Paginación ==========
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int initialPage = 1;

  // ========== Cache ==========
  static const int cacheExpirationHours = 24;
  static const int maxCacheEntries = 1000;
  static const int maxCacheSizeMB = 100;

  // ========== Validación de Campos ==========
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  static const int pinLength = 4;
  static const int otpLength = 6;

  // ========== Formatos de Números ==========
  static const int minLevelForCompany = 2; // Nivel mínimo para crear empresa
  static const int minLevelForBusiness = 3; // Nivel mínimo para crear negocio
  static const int minLevelForFinancial = 4; // Nivel mínimo para crear entidad financiera
  static const int minLevelForEnterprise = 4; // Nivel mínimo para crear empresa grande
  static const String currencySymbol = 'USD';
  static const String currencyCode = 'USD';
  static const String currencyFormat = '###,##0.00';
  static const String percentageFormat = '###,##0.00%';
  static const String decimalFormat = '###,##0.00';
  static const String integerFormat = '###,###';
  static const String phoneFormat = '+593 9 9999 9999'; // Formato de teléfono en Ecuador
  static const String emailFormat = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String urlFormat = r'^(https?|ftp)://[^\s/$.?#].[^\s]*$';
  static const String uuidFormat = r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$';
  static const String dateFormatIso = 'yyyy-MM-dd';
  static const String timeFormatIso = 'HH:mm:ss';
  static const String dateTimeFormatIso = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';
  static const String dateFormatLocal = 'dd/MM/yyyy';
  static const String timeFormatLocal = 'HH:mm:ss';
  static const String dateTimeFormatLocal = 'dd/MM/yyyy HH:mm:ss';
  static const String userLevelNames = 'Basic, Business, Financial, Enterprise';

  // ========== Códigos de País Ecuador ==========
  static const String ecuadorCountryCode = 'EC';
  static const String ecuadorPhoneCode = '+593';
  static const String ecuadorCurrencyCode = 'USD';
  static const String ecuadorLocale = 'es_EC';

  // ========== Formatos de Fecha/Hora ==========
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm:ss';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';

  // ========== Claves de Almacenamiento ==========
  static const String keyAccessToken = 'rantipay_access_token';
  static const String keyRefreshToken = 'rantipay_refresh_token';
  static const String keyUserId = 'rantipay_user_id';
  static const String keyUserLevel = 'rantipay_user_level';
  static const String keyBiometricEnabled = 'rantipay_biometric_enabled';
  static const String keyPinEnabled = 'rantipay_pin_enabled';
  static const String keyLastSync = 'rantipay_last_sync';
  static const String keyDeviceId = 'rantipay_device_id';
  static const String keyFcmToken = 'rantipay_fcm_token';

  // ========== Tipos MIME Permitidos ==========
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
  ];

  static const List<String> allowedDocumentTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ];

  // ========== Mensajes de Error Comunes ==========
  static const String errorGeneric =
      'Ha ocurrido un error. Por favor, intente nuevamente.';
  static const String errorNetwork =
      'Error de conexión. Verifique su internet.';
  static const String errorTimeout =
      'Tiempo de espera agotado. Intente nuevamente.';
  static const String errorUnauthorized =
      'Sesión expirada. Por favor, inicie sesión nuevamente.';
  static const String errorInsufficientLevel =
      'Nivel de usuario insuficiente para esta operación.';

  // ========== URLs de Soporte ==========
  static const String termsUrl = 'https://rantipay.com/terms';
  static const String privacyUrl = 'https://rantipay.com/privacy';
  static const String helpUrl = 'https://rantipay.com/help';
  static const String faqUrl = 'https://rantipay.com/faq';
}
