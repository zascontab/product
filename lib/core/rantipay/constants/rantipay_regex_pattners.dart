/// RantiPay: Patrones de expresiones regulares
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: Ninguna
///
/// Uso:
/// ```dart
/// // Validar número de teléfono
/// if (RantiPayRegexPatterns.ecuadorPhoneRegex.hasMatch(phone)) {
///   // Teléfono válido
/// }
/// ```
class RantiPayRegexPatterns {
  // Prevenir instanciación
  RantiPayRegexPatterns._();

  // ========== Patrones de Teléfono Ecuador ==========

  /// Patrón para números móviles de Ecuador (09XXXXXXXX)
  /// Acepta con o sin código de país (+593)
  static final RegExp ecuadorMobileRegex = RegExp(
    r'^(?:\+593|0)?9[0-9]{8}$',
  );

  /// Patrón para números fijos de Ecuador
  /// Formato: 02, 03, 04, 05, 06, 07 + 7 dígitos
  static final RegExp ecuadorLandlineRegex = RegExp(
    r'^(?:\+593|0)?[2-7][0-9]{7}$',
  );

  /// Patrón general para cualquier número de Ecuador
  static final RegExp ecuadorPhoneRegex = RegExp(
    r'^(?:\+593|0)?(?:9[0-9]{8}|[2-7][0-9]{7})$',
  );

  /// Patrón para operadores móviles específicos
  static final RegExp claroRegex = RegExp(r'^(?:\+593|0)?9(?:3|8|9)[0-9]{7}$');
  static final RegExp movistarRegex = RegExp(r'^(?:\+593|0)?9(?:6|7)[0-9]{7}$');
  static final RegExp cntRegex = RegExp(r'^(?:\+593|0)?9(?:5|2)[0-9]{7}$');
  static final RegExp tuyoRegex = RegExp(r'^(?:\+593|0)?9(?:4)[0-9]{7}$');

  // ========== Patrones de Identificación Ecuador ==========

  /// Patrón para cédula ecuatoriana (10 dígitos)
  static final RegExp cedulaRegex = RegExp(r'^[0-9]{10}$');

  /// Patrón para RUC persona natural (13 dígitos terminados en 001)
  static final RegExp rucPersonaNaturalRegex = RegExp(r'^[0-9]{10}001$');

  /// Patrón para RUC sociedad privada (13 dígitos terminados en 001)
  static final RegExp rucSociedadPrivadaRegex = RegExp(r'^[0-9]{10}001$');

  /// Patrón para RUC sociedad pública (13 dígitos terminados en 001)
  static final RegExp rucSociedadPublicaRegex = RegExp(r'^[0-9]{10}001$');

  /// Patrón general para RUC (13 dígitos)
  static final RegExp rucRegex = RegExp(r'^[0-9]{13}$');

  /// Patrón para pasaporte
  static final RegExp passportRegex = RegExp(r'^[A-Z0-9]{5,20}$');

  // ========== Patrones de Email ==========

  /// Patrón básico de email
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Patrón de email más estricto
  static final RegExp strictEmailRegex = RegExp(r'''
^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*
@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+
[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$
''');
  // ========== Patrones de Contraseña ==========

  /// Al menos una mayúscula
  static final RegExp hasUpperCaseRegex = RegExp(r'[A-Z]');

  /// Al menos una minúscula
  static final RegExp hasLowerCaseRegex = RegExp(r'[a-z]');

  /// Al menos un número
  static final RegExp hasNumberRegex = RegExp(r'[0-9]');

  /// Al menos un carácter especial
  static final RegExp hasSpecialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  /// Contraseña fuerte: 8+ caracteres, mayúscula, minúscula, número y especial
  static final RegExp strongPasswordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // ========== Patrones de Negocio ==========

  /// Nombre de empresa (letras, números, espacios y algunos caracteres)
  static final RegExp companyNameRegex = RegExp(
    r'^[a-zA-Z0-9\s\-\.&,]+$',
  );

  /// Nombre de persona (solo letras y espacios, con tildes)
  static final RegExp personNameRegex = RegExp(
    r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$',
  );

  /// Dirección (letras, números, espacios y caracteres comunes)
  static final RegExp addressRegex = RegExp(
    r'^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\-\.,#]+$',
  );

  // ========== Patrones Financieros ==========

  /// Monto en USD (hasta 2 decimales)
  static final RegExp amountRegex = RegExp(
    r'^\d+(\.\d{1,2})?$',
  );

  /// Número de cuenta bancaria (solo dígitos, 10-20 caracteres)
  static final RegExp bankAccountRegex = RegExp(
    r'^[0-9]{10,20}$',
  );

  /// Código SWIFT/BIC
  static final RegExp swiftCodeRegex = RegExp(
    r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$',
  );

  // ========== Patrones de Validación General ==========

  /// Solo letras
  static final RegExp onlyLettersRegex = RegExp(r'^[a-zA-Z]+$');

  /// Solo números
  static final RegExp onlyNumbersRegex = RegExp(r'^[0-9]+$');

  /// Alfanumérico
  static final RegExp alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');

  /// URL válida
  static final RegExp urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// Código OTP (6 dígitos)
  static final RegExp otpRegex = RegExp(r'^[0-9]{6}$');

  /// PIN (4 dígitos)
  static final RegExp pinRegex = RegExp(r'^[0-9]{4}$');

  /// UUID v4
  static final RegExp uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  // ========== Métodos de Utilidad ==========

  /// Limpia espacios y caracteres no deseados de un string
  static String cleanString(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Extrae solo números de un string
  static String extractNumbers(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Extrae solo letras de un string
  static String extractLetters(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  /// Verifica si un string contiene solo caracteres ASCII
  static bool isAscii(String input) {
    return RegExp(r'^[\x00-\x7F]+$').hasMatch(input);
  }
}
