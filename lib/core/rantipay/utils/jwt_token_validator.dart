import 'package:jwt_decoder/jwt_decoder.dart';

/// ✅ JWT Token Validator con validación UTC correcta
///
/// Este helper resuelve el bug de timezone que causaba que JwtDecoder.isExpired()
/// reportara incorrectamente tokens como válidos cuando en realidad estaban expirados.
///
/// **Problema identificado:** JwtDecoder.isExpired() usa DateTime.now() (hora local)
/// en lugar de DateTime.now().toUtc() para comparar con el claim 'exp' del JWT.
///
/// **Solución:** Validación manual usando UTC exclusivamente.
///
/// **Uso:**
/// ```dart
/// // ❌ NO usar (bug de timezone):
/// final isExpired = JwtDecoder.isExpired(token);
///
/// // ✅ Usar en su lugar:
/// final isExpired = JwtTokenValidator.isTokenExpired(token);
/// ```
class JwtTokenValidator {
  /// Validar si un token JWT ha expirado (con comparación UTC correcta)
  ///
  /// **Retorna:**
  /// - `true` si el token está expirado
  /// - `false` si el token aún es válido
  /// - `true` si hay error al decodificar (por seguridad)
  static bool isTokenExpired(String token) {
    try {
      final expirationDate = JwtDecoder.getExpirationDate(token);
      final currentTime = DateTime.now().toUtc();
      return currentTime.isAfter(expirationDate);
    } catch (e) {
      // Si hay error decodificando, asumir token inválido/expirado
      return true;
    }
  }

  /// Validar si un token JWT es válido (no expirado)
  ///
  /// Inverso de `isTokenExpired()` para conveniencia
  static bool isTokenValid(String token) {
    return !isTokenExpired(token);
  }

  /// Obtener tiempo restante antes de expiración en segundos
  ///
  /// **Retorna:**
  /// - Número de segundos restantes si token es válido
  /// - `0` si el token ya está expirado
  /// - `null` si hay error o no tiene claim 'exp'
  static int? getTimeToExpiry(String token) {
    try {
      final claims = JwtDecoder.decode(token);
      final exp = claims['exp'] as int?;

      if (exp == null) return null;

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      final now = DateTime.now().toUtc();

      if (expiryTime.isBefore(now)) {
        return 0; // Ya expirado
      }

      return expiryTime.difference(now).inSeconds;
    } catch (e) {
      return null;
    }
  }

  /// Validar si un token expirará pronto (threshold configurable)
  ///
  /// **Parámetros:**
  /// - `token`: JWT token a validar
  /// - `threshold`: Duración antes de expiración (default: 5 minutos)
  ///
  /// **Retorna:**
  /// - `true` si el token expirará dentro del threshold
  /// - `false` si aún tiene tiempo suficiente
  static bool willExpireSoon(String token, {Duration threshold = const Duration(minutes: 5)}) {
    final secondsToExpiry = getTimeToExpiry(token);

    if (secondsToExpiry == null) return true; // Error = asumir expirará pronto
    if (secondsToExpiry == 0) return true; // Ya expirado

    return secondsToExpiry < threshold.inSeconds;
  }

  /// Validar token 'nbf' (Not Before) con UTC
  ///
  /// Verifica si el token ya es válido según el claim 'nbf'
  ///
  /// **Retorna:**
  /// - `true` si el token aún no es válido (es muy temprano)
  /// - `false` si el token ya es válido
  /// - `false` si no tiene claim 'nbf' (asumimos válido)
  static bool isNotYetValid(String token) {
    try {
      final claims = JwtDecoder.decode(token);
      final nbf = claims['nbf'] as int?;

      if (nbf == null) return false; // No tiene nbf = válido

      final notBeforeTime = DateTime.fromMillisecondsSinceEpoch(nbf * 1000, isUtc: true);
      final now = DateTime.now().toUtc();

      return now.isBefore(notBeforeTime);
    } catch (e) {
      return false; // Error = asumir válido
    }
  }

  /// Validación completa de token (exp + nbf + formato)
  ///
  /// **Retorna:**
  /// - `true` si el token es completamente válido
  /// - `false` si está expirado, no válido aún, o tiene error de formato
  static bool isTokenFullyValid(String token) {
    try {
      // Verificar formato básico
      if (!_isValidFormat(token)) return false;

      // Verificar que no esté expirado
      if (isTokenExpired(token)) return false;

      // Verificar que ya sea válido (nbf)
      if (isNotYetValid(token)) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validar formato básico de JWT (3 partes separadas por puntos)
  static bool _isValidFormat(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      // Intentar decodificar para verificar formato válido
      JwtDecoder.decode(token);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener fecha de expiración del token en UTC
  static DateTime? getExpirationDateUtc(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      return null;
    }
  }

  /// Obtener fecha de emisión del token (Duration desde epoch)
  static Duration? getIssuedAtDuration(String token) {
    try {
      return JwtDecoder.getTokenTime(token);
    } catch (e) {
      return null;
    }
  }
}
