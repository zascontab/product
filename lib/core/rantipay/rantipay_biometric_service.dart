import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
/// Biometric authentication service
class RantiPayBiometricService {
  final LocalAuthentication _localAuth;
  
  // Cache for device capabilities
  bool? _canCheckBiometrics;
  bool? _isDeviceSupported;
  List<BiometricType>? _availableBiometrics;

  RantiPayBiometricService({
    LocalAuthentication? localAuth,
  }) : _localAuth = localAuth ?? LocalAuthentication();

  /// Check if device supports biometrics
  Future<bool> isDeviceSupported() async {
    _isDeviceSupported ??= await _localAuth.isDeviceSupported();
    return _isDeviceSupported!;
  }

  /// Check if biometrics are available
  Future<bool> canCheckBiometrics() async {
    try {
      _canCheckBiometrics ??= await _localAuth.canCheckBiometrics;
      return _canCheckBiometrics!;
    } on PlatformException catch (e) {
      throw RantiPayBiometricException(
        'Failed to check biometric availability: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      _availableBiometrics ??= await _localAuth.getAvailableBiometrics();
      return _availableBiometrics!;
    } on PlatformException catch (e) {
      throw RantiPayBiometricException(
        'Failed to get available biometrics: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Check if specific biometric type is available
  Future<bool> isBiometricTypeAvailable(BiometricType type) async {
    final available = await getAvailableBiometrics();
    return available.contains(type);
  }

  /// Get biometric capability info
  Future<RantiPayBiometricCapability> getBiometricCapability() async {
    final isSupported = await isDeviceSupported();
    if (!isSupported) {
      return RantiPayBiometricCapability.notSupported();
    }

    final canCheck = await canCheckBiometrics();
    if (!canCheck) {
      return RantiPayBiometricCapability.notAvailable();
    }

    final availableTypes = await getAvailableBiometrics();
    
    return RantiPayBiometricCapability(
      isSupported: true,
      canCheckBiometrics: true,
      availableBiometrics: availableTypes,
      hasFaceId: availableTypes.contains(BiometricType.face),
      hasTouchId: availableTypes.contains(BiometricType.fingerprint),
      hasIris: availableTypes.contains(BiometricType.iris),
      hasStrongBiometric: availableTypes.contains(BiometricType.strong),
      hasWeakBiometric: availableTypes.contains(BiometricType.weak),
    );
  }

  /// Authenticate with biometrics
  Future<RantiPayBiometricResult> authenticate({
    required String reason,
    String? cancelButton,
    String? fallbackTitle,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    try {
      // Check if biometrics are available
      final canCheck = await canCheckBiometrics();
      if (!canCheck) {
        return RantiPayBiometricResult(
          success: false,
          error: RantiPayBiometricError.notAvailable,
          message: 'Biometric authentication is not available on this device',
        );
      }

      // Perform authentication
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      return RantiPayBiometricResult(
        success: isAuthenticated,
        authenticatedAt: isAuthenticated ? DateTime.now() : null,
      );
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return RantiPayBiometricResult(
        success: false,
        error: RantiPayBiometricError.unknown,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Authenticate with specific options for different security levels
  Future<RantiPayBiometricResult> authenticateForTransaction({
    required double amount,
    required String currency,
    String? recipient,
  }) async {
    final reason = recipient != null
        ? 'Authenticate to send $currency ${amount.toStringAsFixed(2)} to $recipient'
        : 'Authenticate to complete transaction of $currency ${amount.toStringAsFixed(2)}';

    return authenticate(
      reason: reason,
      biometricOnly: true, // Higher security for transactions
      stickyAuth: true,
    );
  }

  /// Authenticate for accessing sensitive data
  Future<RantiPayBiometricResult> authenticateForDataAccess({
    required String dataType,
  }) async {
    return authenticate(
      reason: 'Authenticate to access your $dataType',
      biometricOnly: false, // Allow fallback for data access
    );
  }

  /// Authenticate for settings change
  Future<RantiPayBiometricResult> authenticateForSettings() async {
    return authenticate(
      reason: 'Authenticate to change security settings',
      biometricOnly: false,
    );
  }

  /// Stop authentication
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      return false;
    }
  }

  /// Clear biometric cache
  void clearCache() {
    _canCheckBiometrics = null;
    _isDeviceSupported = null;
    _availableBiometrics = null;
  }

  /// Handle platform exceptions
  RantiPayBiometricResult _handlePlatformException(PlatformException e) {
    RantiPayBiometricError error;
    String message;

    switch (e.code) {
      case 'NotEnrolled':
        error = RantiPayBiometricError.notEnrolled;
        message = 'No biometric data is enrolled on this device';
        break;
      case 'NotAvailable':
        error = RantiPayBiometricError.notAvailable;
        message = 'Biometric authentication is not available';
        break;
      case 'OtherOperatingSystem':
        error = RantiPayBiometricError.unsupportedOS;
        message = 'Biometric authentication is not supported on this OS';
        break;
      case 'LockedOut':
        error = RantiPayBiometricError.lockedOut;
        message = 'Too many failed attempts. Biometric authentication is locked';
        break;
      case 'PermanentlyLockedOut':
        error = RantiPayBiometricError.permanentlyLockedOut;
        message = 'Biometric authentication is permanently locked. Please use PIN';
        break;
      case 'UserCanceled':
        error = RantiPayBiometricError.userCanceled;
        message = 'Authentication was canceled by the user';
        break;
      case 'Timeout':
        error = RantiPayBiometricError.timeout;
        message = 'Authentication timed out';
        break;
      default:
        error = RantiPayBiometricError.unknown;
        message = e.message ?? 'An unknown error occurred';
    }

    return RantiPayBiometricResult(
      success: false,
      error: error,
      message: message,
      platformCode: e.code,
    );
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(BiometricType type) {
    if (Platform.isIOS) {
      switch (type) {
        case BiometricType.face:
          return 'Face ID';
        case BiometricType.fingerprint:
          return 'Touch ID';
        default:
          return 'Biometric';
      }
    } else if (Platform.isAndroid) {
      switch (type) {
        case BiometricType.face:
          return 'Face Unlock';
        case BiometricType.fingerprint:
          return 'Fingerprint';
        case BiometricType.iris:
          return 'Iris Scanner';
        case BiometricType.strong:
          return 'Biometric';
        case BiometricType.weak:
          return 'Pattern/PIN';
        default:
          return 'Biometric';
      }
    }
    return 'Biometric';
  }

  /// Get icon for biometric type
  String getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return '👤';
      case BiometricType.fingerprint:
        return '👆';
      case BiometricType.iris:
        return '👁';
      default:
        return '🔐';
    }
  }
}

/// Biometric capability information
class RantiPayBiometricCapability {
  final bool isSupported;
  final bool canCheckBiometrics;
  final List<BiometricType> availableBiometrics;
  final bool hasFaceId;
  final bool hasTouchId;
  final bool hasIris;
  final bool hasStrongBiometric;
  final bool hasWeakBiometric;

  const RantiPayBiometricCapability({
    required this.isSupported,
    required this.canCheckBiometrics,
    required this.availableBiometrics,
    required this.hasFaceId,
    required this.hasTouchId,
    required this.hasIris,
    required this.hasStrongBiometric,
    required this.hasWeakBiometric,
  });

  factory RantiPayBiometricCapability.notSupported() {
    return const RantiPayBiometricCapability(
      isSupported: false,
      canCheckBiometrics: false,
      availableBiometrics: [],
      hasFaceId: false,
      hasTouchId: false,
      hasIris: false,
      hasStrongBiometric: false,
      hasWeakBiometric: false,
    );
  }

  factory RantiPayBiometricCapability.notAvailable() {
    return const RantiPayBiometricCapability(
      isSupported: true,
      canCheckBiometrics: false,
      availableBiometrics: [],
      hasFaceId: false,
      hasTouchId: false,
      hasIris: false,
      hasStrongBiometric: false,
      hasWeakBiometric: false,
    );
  }

  bool get hasAnyBiometric => availableBiometrics.isNotEmpty;
  
  bool get hasSecureBiometric => 
      hasFaceId || hasTouchId || hasIris || hasStrongBiometric;

  String get primaryBiometricName {
    if (hasFaceId) return 'Face ID';
    if (hasTouchId) return 'Touch ID';
    if (hasIris) return 'Iris Scanner';
    if (hasStrongBiometric) return 'Biometric';
    if (hasWeakBiometric) return 'Screen Lock';
    return 'None';
  }
}

/// Biometric authentication result
class RantiPayBiometricResult {
  final bool success;
  final RantiPayBiometricError? error;
  final String? message;
  final String? platformCode;
  final DateTime? authenticatedAt;

  const RantiPayBiometricResult({
    required this.success,
    this.error,
    this.message,
    this.platformCode,
    this.authenticatedAt,
  });

  bool get isSuccess => success;
  bool get isFailure => !success;
  bool get isCanceled => error == RantiPayBiometricError.userCanceled;
  bool get isLocked => error == RantiPayBiometricError.lockedOut ||
                       error == RantiPayBiometricError.permanentlyLockedOut;
}

/// Biometric error types
enum RantiPayBiometricError {
  notAvailable,
  notEnrolled,
  unsupportedOS,
  lockedOut,
  permanentlyLockedOut,
  userCanceled,
  timeout,
  unknown,
}

/// Biometric exception
class RantiPayBiometricException implements Exception {
  final String message;
  final String? code;

  RantiPayBiometricException(this.message, {this.code});

  @override
  String toString() => 'RantiPayBiometricException: $message${code != null ? ' (Code: $code)' : ''}';
}