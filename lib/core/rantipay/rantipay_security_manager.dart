import 'dart:async';

import 'package:rantipay_app/core/config/rantipay_enviroment.dart';
import 'package:rantipay_app/core/rantipay/rantipay_biometric_service.dart';
import 'package:rantipay_app/core/rantipay/rantipay_certificate_pinning.dart';
import 'package:rantipay_app/core/rantipay/rantipay_encryption_service.dart';
import 'package:rantipay_app/core/rantipay/rantipay_jailbreak_detection.dart';
import 'package:rantipay_app/core/rantipay/rantipay_pin_service.dart';
import 'package:rantipay_app/core/rantipay/rantipay_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central security manager coordinating all security services
class RantiPaySecurityManager {
  final RantiPaySecureStorage _secureStorage;
  final RantiPayEncryptionService _encryptionService;
  final RantiPayBiometricService _biometricService;
  final RantiPayPinService _pinService;
  final RantiPayEnvironment _environment;

  // Security state
  bool _isInitialized = false;
  RantiPayDeviceSecurityStatus? _deviceSecurityStatus;
  RantiPaySecurityConfig? _securityConfig;
  Timer? _sessionTimer;

  // Session management
  static const Duration _defaultSessionTimeout = Duration(minutes: 30);
  static const Duration _securityCheckInterval = Duration(minutes: 5);

  RantiPaySecurityManager({
    required SharedPreferences preferences,
    required RantiPayEnvironment environment,
    String? masterEncryptionKey,
  })  : _environment = environment,
        _secureStorage = RantiPaySecureStorage(preferences: preferences),
        _encryptionService =
            RantiPayEncryptionService(masterKey: masterEncryptionKey),
        _biometricService = RantiPayBiometricService(),
        _pinService = RantiPayPinService(
          secureStorage: RantiPaySecureStorage(preferences: preferences),
          encryptionService:
              RantiPayEncryptionService(masterKey: masterEncryptionKey),
        );

  /// Initialize security manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check device security
      _deviceSecurityStatus =
          await RantiPayJailbreakDetection.checkDeviceSecurity();

      // Load security configuration
      _securityConfig = await _loadSecurityConfig();

      // Initialize encryption key if not exists
      await _initializeEncryptionKey();

      // Start session monitoring
      _startSessionMonitoring();

      _isInitialized = true;
    } catch (e) {
      throw RantiPaySecurityException('Failed to initialize security: $e');
    }
  }

  /// Get current security status
  /// Get current security status
  /// Get current security status
  Future<RantiPaySecurityStatus> getSecurityStatus() async {
    if (!_isInitialized) {
      return RantiPaySecurityStatus.uninitialized();
    }

    // Await the async isPinSet method
    final isPinSet = await _pinService.isPinSet();

    final securityLevel = await _calculateSecurityLevel();

    return RantiPaySecurityStatus(
      isInitialized: _isInitialized,
      deviceSecurity: _deviceSecurityStatus!,
      isPinSet: isPinSet,
      isBiometricEnabled: _secureStorage.getBiometricEnabled(),
      isSessionActive: !_secureStorage.isSessionExpired(),
      lastActivity: _secureStorage.getLastActivity(),
      securityLevel: securityLevel,
    );
  }

  /// Authenticate user
  Future<RantiPayAuthResult> authenticate({
    required RantiPayAuthMethodBio method,
    String? pin,
    String? reason,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check device security first
    if (!_shouldAllowAuthentication()) {
      return RantiPayAuthResult(
        success: false,
        error: 'Device security check failed',
        method: method,
      );
    }

    try {
      bool success = false;
      String? error;

      switch (method) {
        case RantiPayAuthMethodBio.pin:
          if (pin == null) {
            return RantiPayAuthResult(
              success: false,
              error: 'PIN is required',
              method: method,
            );
          }
          final result = await _pinService.verifyPin(pin);
          success = result.success;
          error = result.message;
          break;

        case RantiPayAuthMethodBio.biometric:
          final result = await _biometricService.authenticate(
            reason: reason ?? 'Authenticate to continue',
          );
          success = result.success;
          error = result.message;
          break;

        case RantiPayAuthMethodBio.biometricOrPin:
          // Try biometric first if enabled
          if (_secureStorage.getBiometricEnabled()) {
            final bioResult = await _biometricService.authenticate(
              reason: reason ?? 'Authenticate to continue',
            );
            if (bioResult.success) {
              success = true;
            } else if (bioResult.isCanceled && pin != null) {
              // Fall back to PIN
              final pinResult = await _pinService.verifyPin(pin);
              success = pinResult.success;
              error = pinResult.message;
            } else {
              error = bioResult.message;
            }
          } else if (pin != null) {
            // Use PIN only
            final pinResult = await _pinService.verifyPin(pin);
            success = pinResult.success;
            error = pinResult.message;
          } else {
            error = 'Authentication method not available';
          }
          break;
      }

      if (success) {
        await _secureStorage.updateLastActivity();
        _resetSessionTimer();
      }

      return RantiPayAuthResult(
        success: success,
        error: error,
        method: method,
        authenticatedAt: success ? DateTime.now() : null,
      );
    } catch (e) {
      return RantiPayAuthResult(
        success: false,
        error: 'Authentication failed: $e',
        method: method,
      );
    }
  }

  /// Setup PIN
  Future<bool> setupPin(String pin, {String? confirmPin}) async {
    final result = await _pinService.createPin(pin, confirmPin: confirmPin);
    return result.success;
  }

  /// Change PIN
  Future<bool> changePin({
    required String currentPin,
    required String newPin,
    String? confirmNewPin,
  }) async {
    final result = await _pinService.changePin(
      currentPin: currentPin,
      newPin: newPin,
      confirmNewPin: confirmNewPin,
    );
    return result.success;
  }

  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    // Check if biometric is available
    final capability = await _biometricService.getBiometricCapability();
    if (!capability.hasSecureBiometric) {
      return false;
    }

    // Authenticate first
    final result = await _biometricService.authenticate(
      reason: 'Enable biometric authentication',
    );

    if (result.success) {
      await _secureStorage.setBiometricEnabled(true);
      return true;
    }

    return false;
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    await _secureStorage.setBiometricEnabled(false);
  }

  /// Encrypt sensitive data
  String encryptData(String data, {RantiPayEncryptionStrength? strength}) {
    // Use different encryption based on strength
    switch (strength ?? RantiPayEncryptionStrength.standard) {
      case RantiPayEncryptionStrength.basic:
        // Simple encryption for non-sensitive data
        return _encryptionService.encryptString(data);

      case RantiPayEncryptionStrength.standard:
        // Standard encryption for PII
        return _encryptionService.encryptString(data);

      case RantiPayEncryptionStrength.maximum:
        // Maximum encryption for highly sensitive data
        // Could use additional layers or stronger algorithms
        final encrypted = _encryptionService.encryptString(data);
        return _encryptionService.encryptString(encrypted); // Double encryption
    }
  }

  /// Decrypt sensitive data
  String decryptData(String encryptedData,
      {RantiPayEncryptionStrength? strength}) {
    switch (strength ?? RantiPayEncryptionStrength.standard) {
      case RantiPayEncryptionStrength.basic:
        return _encryptionService.decryptString(encryptedData);

      case RantiPayEncryptionStrength.standard:
        return _encryptionService.decryptString(encryptedData);

      case RantiPayEncryptionStrength.maximum:
        // Reverse double encryption
        final decrypted = _encryptionService.decryptString(encryptedData);
        return _encryptionService.decryptString(decrypted);
    }
  }

  /// Lock application
  Future<void> lockApp() async {
    // await _secureStorage.clearSessionData();
    _sessionTimer?.cancel();
  }

  /// Unlock application
  Future<bool> unlockApp({
    required RantiPayAuthMethodBio method,
    String? pin,
  }) async {
    final result = await authenticate(method: method, pin: pin);

    if (result.success) {
      await _secureStorage.saveSessionData({
        'unlocked_at': DateTime.now().toIso8601String(),
        'auth_method': method.toString(),
      });
      _startSessionMonitoring();
    }

    return result.success;
  }

  /// Clear all security data (logout)
  Future<void> clearAllSecurityData() async {
    _sessionTimer?.cancel();
    await _secureStorage.clearAll();
    _isInitialized = false;
  }

  /// Validate certificate for API calls
  bool validateCertificate(
    dynamic certificate,
    String host,
    int port,
  ) {
    if (_environment == RantiPayEnvironment.dev) {
      // Skip certificate validation in development
      return true;
    }

    return RantiPayCertificatePinning.verifyCertificate(
      certificate,
      host,
      port,
      isProduction: _environment == RantiPayEnvironment.prod,
    );
  }

  // ==================== Private Methods ====================

  /// Initialize encryption key
  Future<void> _initializeEncryptionKey() async {
    final existingKey = await _secureStorage.readSecure(
      key: RantiPaySecureStorage.keyEncryptionKey,
    );

    if (existingKey == null) {
      // Generate new encryption key
      final newKey = _encryptionService.generateKey();
      await _secureStorage.writeSecure(
        key: RantiPaySecureStorage.keyEncryptionKey,
        value: newKey,
      );
    }
  }

  /// Load security configuration
  Future<RantiPaySecurityConfig> _loadSecurityConfig() async {
    // In a real app, this might come from remote config
    return RantiPaySecurityConfig(
      sessionTimeout: _defaultSessionTimeout,
      requirePinOnBackground: true,
      enableBiometric: true,
      enableCertificatePinning: _environment != RantiPayEnvironment.dev,
      minPinLength: 4,
      maxPinLength: 8,
      maxFailedAttempts: 5,
      lockoutDuration: const Duration(minutes: 15),
    );
  }

  /// Check if authentication should be allowed
  bool _shouldAllowAuthentication() {
    if (_deviceSecurityStatus == null) return false;

    // In production, enforce stricter security
    if (_environment == RantiPayEnvironment.prod) {
      return _deviceSecurityStatus!.securityScore >= 50;
    }

    // More lenient in development/staging
    return true;
  }

  /// Calculate overall security level
  Future<int> _calculateSecurityLevel() async {
    int level = 0;

    // Device security (0-40 points)
    if (_deviceSecurityStatus != null) {
      level += (_deviceSecurityStatus!.securityScore * 0.4).round();
    }

    // Authentication methods (0-30 points)
    final hasPinSet = await _pinService.isPinSet();
    if (hasPinSet == true) level += 15;
    if (_secureStorage.getBiometricEnabled()) level += 15;

    // Session security (0-30 points)
    if (!_secureStorage.isSessionExpired()) level += 30;

    return level.clamp(0, 100);
  }

  /// Start session monitoring
  void _startSessionMonitoring() {
    _sessionTimer?.cancel();

    _sessionTimer = Timer.periodic(_securityCheckInterval, (timer) {
      if (_secureStorage.isSessionExpired()) {
        lockApp();
      }
    });
  }

  /// Reset session timer
  void _resetSessionTimer() {
    _startSessionMonitoring();
  }

  /// Dispose resources
  void dispose() {
    _sessionTimer?.cancel();
  }
}

/// Security configuration
class RantiPaySecurityConfig {
  final Duration sessionTimeout;
  final bool requirePinOnBackground;
  final bool enableBiometric;
  final bool enableCertificatePinning;
  final int minPinLength;
  final int maxPinLength;
  final int maxFailedAttempts;
  final Duration lockoutDuration;

  const RantiPaySecurityConfig({
    required this.sessionTimeout,
    required this.requirePinOnBackground,
    required this.enableBiometric,
    required this.enableCertificatePinning,
    required this.minPinLength,
    required this.maxPinLength,
    required this.maxFailedAttempts,
    required this.lockoutDuration,
  });
}

/// Security status
class RantiPaySecurityStatus {
  final bool isInitialized;
  final RantiPayDeviceSecurityStatus deviceSecurity;
  final bool isPinSet;
  final bool isBiometricEnabled;
  final bool isSessionActive;
  final DateTime? lastActivity;
  final int securityLevel;

  const RantiPaySecurityStatus({
    required this.isInitialized,
    required this.deviceSecurity,
    required this.isPinSet,
    required this.isBiometricEnabled,
    required this.isSessionActive,
    this.lastActivity,
    required this.securityLevel,
  });

  factory RantiPaySecurityStatus.uninitialized() {
    return RantiPaySecurityStatus(
      isInitialized: false,
      deviceSecurity: RantiPayDeviceSecurityStatus.unknown(),
      isPinSet: false,
      isBiometricEnabled: false,
      isSessionActive: false,
      securityLevel: 0,
    );
  }

  bool get isSecure => securityLevel >= 70;
  bool get needsImprovement => securityLevel < 50;
}

/// Authentication methods
enum RantiPayAuthMethodBio {
  pin,
  biometric,
  biometricOrPin,
}

/// Authentication result
class RantiPayAuthResult {
  final bool success;
  final String? error;
  final RantiPayAuthMethodBio method;
  final DateTime? authenticatedAt;

  const RantiPayAuthResult({
    required this.success,
    this.error,
    required this.method,
    this.authenticatedAt,
  });
}

/// Security exception
class RantiPaySecurityException implements Exception {
  final String message;

  RantiPaySecurityException(this.message);

  @override
  String toString() => 'RantiPaySecurityException: $message';
}
