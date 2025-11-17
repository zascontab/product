/// RantiPay: Constantes de tiempo y duración
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: Ninguna
///
/// Uso:
/// ```dart
/// // Usar duración de token
/// final tokenExpiry = DateTime.now().add(
///   RantiPayTimeConstants.accessTokenDuration
/// );
/// ```
class RantiPayTimeConstants {
  // Prevenir instanciación
  RantiPayTimeConstants._();

  // ========== Duraciones de Token ==========
  static const Duration accessTokenDuration = Duration(hours: 1);
  static const Duration refreshTokenDuration = Duration(days: 30);
  static const Duration sessionDuration = Duration(minutes: 30);
  static const Duration sessionWarningDuration = Duration(minutes: 25);

  // ========== Duraciones de OTP ==========
  static const Duration otpExpiration = Duration(minutes: 5);
  static const Duration otpResendCooldown = Duration(seconds: 60);
  static const Duration otpMaxValidity = Duration(minutes: 10);

  // ========== Timeouts de Red ==========
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);
  static const Duration downloadTimeout = Duration(minutes: 2);

  // ========== Duraciones de Cache ==========
  static const Duration defaultCacheDuration = Duration(hours: 24);
  static const Duration shortCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 7);
  static const Duration imageCacheDuration = Duration(days: 30);

  // ========== Duraciones de Sincronización ==========
  static const Duration syncInterval = Duration(minutes: 15);
  static const Duration backgroundSyncInterval = Duration(hours: 1);
  static const Duration offlineDataExpiration = Duration(days: 7);

  // ========== Duraciones de UI/Animación ==========
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 350);

  // ========== Duraciones de Notificaciones ==========
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration toastDuration = Duration(seconds: 2);
  static const Duration bannerDuration = Duration(seconds: 5);

  // ========== Duraciones de Validación ==========
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration throttleDelay = Duration(milliseconds: 300);
  static const Duration searchDelay = Duration(milliseconds: 800);

  // ========== Duraciones de Seguridad ==========
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration biometricTimeout = Duration(seconds: 30);
  static const Duration pinEntryTimeout = Duration(minutes: 1);

  // ========== Duraciones de Proceso ==========
  static const Duration splashScreenDuration = Duration(seconds: 2);
  static const Duration loadingIndicatorDelay = Duration(milliseconds: 100);
  static const Duration refreshIndicatorDuration = Duration(seconds: 1);

  // ========== Horarios de Negocio ==========
  static const int businessStartHour = 8; // 8 AM
  static const int businessEndHour = 18; // 6 PM
  static const List<int> businessDays = [1, 2, 3, 4, 5]; // Lunes a Viernes

  // ========== Zonas Horarias Ecuador ==========
  static const String ecuadorTimezone = 'America/Guayaquil';
  static const int ecuadorUtcOffset = -5; // UTC-5

  // ========== Duraciones de Backup ==========
  static const Duration statsCacheDuration = Duration(days: 30);
  static const Duration businessCacheDuration = Duration(days: 7);

  // ========== Métodos de Utilidad ==========

  /// Verifica si una fecha está dentro del horario de negocio
  static bool isBusinessHours(DateTime dateTime) {
    final hour = dateTime.hour;
    final weekday = dateTime.weekday;

    return businessDays.contains(weekday) &&
        hour >= businessStartHour &&
        hour < businessEndHour;
  }

  /// Calcula el tiempo restante hasta el próximo horario de negocio
  static Duration untilNextBusinessHour(DateTime from) {
    var next = from;

    // Si es fin de semana, avanzar al lunes
    while (!businessDays.contains(next.weekday)) {
      next = next.add(const Duration(days: 1));
      next = DateTime(next.year, next.month, next.day, businessStartHour);
    }

    // Si es día de semana pero fuera de horario
    if (next.hour < businessStartHour) {
      next = DateTime(next.year, next.month, next.day, businessStartHour);
    } else if (next.hour >= businessEndHour) {
      next = next.add(const Duration(days: 1));
      // Verificar nuevamente si es día de negocio
      while (!businessDays.contains(next.weekday)) {
        next = next.add(const Duration(days: 1));
      }
      next = DateTime(next.year, next.month, next.day, businessStartHour);
    }

    return next.difference(from);
  }

  /// Formatea una duración en formato legible
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Obtiene duración de retry con backoff exponencial
  static Duration getRetryDuration(int attemptNumber) {
    final baseDelay = 1000; // 1 segundo
    final maxDelay = 60000; // 60 segundos

    final delay = baseDelay * (1 << (attemptNumber - 1)); // 2^(n-1) * base
    return Duration(milliseconds: delay.clamp(baseDelay, maxDelay));
  }
}
