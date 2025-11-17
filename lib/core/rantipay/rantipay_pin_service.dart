import 'dart:async';
import 'rantipay_secure_storage.dart';
import 'rantipay_encryption_service.dart';

/// PIN management service
class RantiPayPinService {
  final RantiPaySecureStorage _secureStorage;
  final RantiPayEncryptionService _encryptionService;
  
  // PIN configuration
  static const int minPinLength = 4;
  static const int maxPinLength = 8;
  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // PIN validation rules
  static const bool allowSequential = false;
  static const bool allowRepeating = false;
  static const bool requireMixedDigits = true;

  RantiPayPinService({
    required RantiPaySecureStorage secureStorage,
    required RantiPayEncryptionService encryptionService,
  })  : _secureStorage = secureStorage,
        _encryptionService = encryptionService;

  /// Create a new PIN
  Future<RantiPayPinResult> createPin(String pin, {String? confirmPin}) async {
    try {
      // Validate PIN format
      final validationResult = validatePinFormat(pin);
      if (!validationResult.isValid) {
        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.invalidFormat,
          message: validationResult.message,
        );
      }

      // Check confirmation if provided
      if (confirmPin != null && pin != confirmPin) {
        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.mismatch,
          message: 'PINs do not match',
        );
      }

      // Check if PIN already exists
      final hasExistingPin = await _secureStorage.isPinSet();
      if (hasExistingPin) {
        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.alreadySet,
          message: 'PIN is already set. Please use change PIN instead',
        );
      }

      // Hash and save PIN
      final hashedPin = _encryptionService.hashPin(pin);
      await _secureStorage.savePin(hashedPin);

      // Reset any failed attempts
      await _secureStorage.resetFailedAttempts();

      return RantiPayPinResult(
        success: true,
        message: 'PIN created successfully',
      );
    } catch (e) {
      return RantiPayPinResult(
        success: false,
        error: RantiPayPinError.unknown,
        message: 'Failed to create PIN: $e',
      );
    }
  }

  /// Verify PIN
  Future<RantiPayPinResult> verifyPin(String pin) async {
    try {
      // Check if account is locked
      if (_secureStorage.isAccountLocked()) {
        final remainingTime = _secureStorage.getLockoutRemainingTime();
        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.accountLocked,
          message: 'Account is locked. Try again in ${remainingTime?.inMinutes ?? 0} minutes',
          remainingLockTime: remainingTime,
        );
      }

      // Get stored PIN
      final storedPin = await _secureStorage.getPin();
      if (storedPin == null) {
        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.notSet,
          message: 'PIN is not set',
        );
      }

      // Verify PIN
      final hashedPin = _encryptionService.hashPin(pin);
      final isValid = hashedPin == storedPin;

      if (isValid) {
        // Reset failed attempts on success
        await _secureStorage.resetFailedAttempts();
        await _secureStorage.updateLastActivity();
        
        return RantiPayPinResult(
          success: true,
          message: 'PIN verified successfully',
        );
      } else {
        // Increment failed attempts
        await _secureStorage.incrementFailedAttempts();
        final attempts = _secureStorage.getFailedAttempts();
        final remainingAttempts = maxAttempts - attempts;

        if (remainingAttempts <= 0) {
          return RantiPayPinResult(
            success: false,
            error: RantiPayPinError.accountLocked,
            message: 'Too many failed attempts. Account is locked',
            remainingAttempts: 0,
          );
        }

        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.incorrect,
          message: 'Incorrect PIN. $remainingAttempts attempts remaining',
          remainingAttempts: remainingAttempts,
        );
      }
    } catch (e) {
      return RantiPayPinResult(
        success: false,
        error: RantiPayPinError.unknown,
        message: 'Failed to verify PIN: $e',
      );
    }
  }

  /// Change PIN
  Future<RantiPayPinResult> changePin({
    required String currentPin,
    required String newPin,
    String? confirmNewPin,
  }) async {
    try {
      // Verify current PIN first
      final verifyResult = await verifyPin(currentPin);
      if (!verifyResult.success) {
        return verifyResult;
      }

      // Validate new PIN format
      final validationResult = validatePinFormat(newPin);
      if (!validationResult.isValid) {
        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.invalidFormat,
          message: validationResult.message,
        );
      }

      // Check confirmation if provided
      if (confirmNewPin != null && newPin != confirmNewPin) {
        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.mismatch,
          message: 'New PINs do not match',
        );
      }

      // Check if new PIN is same as current
      final currentHashedPin = _encryptionService.hashPin(currentPin);
      final newHashedPin = _encryptionService.hashPin(newPin);
      
      if (currentHashedPin == newHashedPin) {
        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.sameAsOld,
          message: 'New PIN must be different from current PIN',
        );
      }

      // Save new PIN
      await _secureStorage.savePin(newHashedPin);

      return RantiPayPinResult(
        success: true,
        message: 'PIN changed successfully',
      );
    } catch (e) {
      return RantiPayPinResult(
        success: false,
        error: RantiPayPinError.unknown,
        message: 'Failed to change PIN: $e',
      );
    }
  }

  /// Reset PIN (requires additional verification)
  Future<RantiPayPinResult> resetPin({
    required String verificationToken,
    required String newPin,
    String? confirmNewPin,
  }) async {
    try {
      // TODO: Verify the reset token with backend
      // This would typically involve verifying an OTP or email token

      // For now, we'll just validate the new PIN
      final validationResult = validatePinFormat(newPin);
      if (!validationResult.isValid) {
        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.invalidFormat,
          message: validationResult.message,
        );
      }

      // Check confirmation if provided
      if (confirmNewPin != null && newPin != confirmNewPin) {
        return RantiPayPinResult(
          success: false,
          error: RantiPayPinError.mismatch,
          message: 'PINs do not match',
        );
      }

      // Clear existing PIN and save new one
      await _secureStorage.clearPin();
      final hashedPin = _encryptionService.hashPin(newPin);
      await _secureStorage.savePin(hashedPin);

      // Reset failed attempts
      await _secureStorage.resetFailedAttempts();

      return RantiPayPinResult(
        success: true,
        message: 'PIN reset successfully',
      );
    } catch (e) {
      return RantiPayPinResult(
        success: false,
        error: RantiPayPinError.unknown,
        message: 'Failed to reset PIN: $e',
      );
    }
  }

  /// Check if PIN is set
  Future<bool> isPinSet() async {
    return await _secureStorage.isPinSet();
  }

  /// Get remaining attempts
  int getRemainingAttempts() {
    final failedAttempts = _secureStorage.getFailedAttempts();
    return (maxAttempts - failedAttempts).clamp(0, maxAttempts);
  }

  /// Check if account is locked
  bool isAccountLocked() {
    return _secureStorage.isAccountLocked();
  }

  /// Get lockout remaining time
  Duration? getLockoutRemainingTime() {
    return _secureStorage.getLockoutRemainingTime();
  }

  /// Validate PIN format
  RantiPayPinValidation validatePinFormat(String pin) {
    // Check if PIN is numeric
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return RantiPayPinValidation(
        isValid: false,
        message: 'PIN must contain only numbers',
      );
    }

    // Check length
    if (pin.length < minPinLength) {
      return RantiPayPinValidation(
        isValid: false,
        message: 'PIN must be at least $minPinLength digits',
      );
    }

    if (pin.length > maxPinLength) {
      return RantiPayPinValidation(
        isValid: false,
        message: 'PIN must not exceed $maxPinLength digits',
      );
    }

    // Check for sequential digits
    if (!allowSequential && _hasSequentialDigits(pin)) {
      return RantiPayPinValidation(
        isValid: false,
        message: 'PIN must not contain sequential digits (e.g., 1234, 4321)',
      );
    }

    // Check for repeating digits
    if (!allowRepeating && _hasAllSameDigits(pin)) {
      return RantiPayPinValidation(
        isValid: false,
        message: 'PIN must not contain all same digits (e.g., 1111)',
      );
    }

    // Check for mixed digits
    if (requireMixedDigits && !_hasMixedDigits(pin)) {
      return RantiPayPinValidation(
        isValid: false,
        message: 'PIN must contain at least 2 different digits',
      );
    }

    // Check for common PINs
    if (_isCommonPin(pin)) {
      return RantiPayPinValidation(
        isValid: false,
        message: 'PIN is too common. Please choose a more secure PIN',
      );
    }

    return RantiPayPinValidation(
      isValid: true,
      message: 'PIN format is valid',
    );
  }

  /// Check if PIN has sequential digits
  bool _hasSequentialDigits(String pin) {
    for (int i = 0; i < pin.length - 1; i++) {
      final current = int.parse(pin[i]);
      final next = int.parse(pin[i + 1]);
      
      // Check ascending
      if (i == 0) {
        bool isAscending = true;
        bool isDescending = true;
        
        for (int j = 0; j < pin.length - 1; j++) {
          final a = int.parse(pin[j]);
          final b = int.parse(pin[j + 1]);
          
          if (b != a + 1) isAscending = false;
          if (b != a - 1) isDescending = false;
        }
        
        if (isAscending || isDescending) return true;
      }
    }
    return false;
  }

  /// Check if all digits are the same
  bool _hasAllSameDigits(String pin) {
    return pin.split('').every((digit) => digit == pin[0]);
  }

  /// Check if PIN has mixed digits
  bool _hasMixedDigits(String pin) {
    return pin.split('').toSet().length >= 2;
  }

  /// Check if PIN is commonly used
  bool _isCommonPin(String pin) {
    const commonPins = [
      '0000', '1111', '2222', '3333', '4444', '5555', '6666', '7777', '8888', '9999',
      '1234', '4321', '1212', '2121', '0123', '3210',
      '1000', '2000', '3000', '4000', '5000', '6000', '7000', '8000', '9000',
      '1001', '2002', '3003', '4004', '5005', '6006', '7007', '8008', '9009',
      '123456', '654321', '111111', '000000',
      '123123', '456456', '789789',
      '12345678', '87654321', '11111111', '00000000',
    ];
    
    return commonPins.contains(pin);
  }

  /// Generate a secure random PIN
  String generateSecurePin({int length = 6}) {
    if (length < minPinLength || length > maxPinLength) {
      length = 6;
    }

    String pin;
    int attempts = 0;
    
    do {
      pin = _encryptionService.generateOTP(length: length);
      attempts++;
      
      // Prevent infinite loop
      if (attempts > 100) {
        throw RantiPayPinException('Failed to generate secure PIN');
      }
    } while (!validatePinFormat(pin).isValid);
    
    return pin;
  }
}

/// PIN validation result
class RantiPayPinValidation {
  final bool isValid;
  final String message;

  const RantiPayPinValidation({
    required this.isValid,
    required this.message,
  });
}

/// PIN operation result
class RantiPayPinResult {
  final bool success;
  final RantiPayPinError? error;
  final String message;
  final int? remainingAttempts;
  final Duration? remainingLockTime;

  const RantiPayPinResult({
    required this.success,
    this.error,
    required this.message,
    this.remainingAttempts,
    this.remainingLockTime,
  });

  bool get isSuccess => success;
  bool get isFailure => !success;
  bool get isLocked => error == RantiPayPinError.accountLocked;
}

/// PIN error types
enum RantiPayPinError {
  notSet,
  alreadySet,
  incorrect,
  invalidFormat,
  mismatch,
  sameAsOld,
  accountLocked,
  tooManyAttempts,
  unknown,
}

/// PIN exception
class RantiPayPinException implements Exception {
  final String message;

  RantiPayPinException(this.message);

  @override
  String toString() => 'RantiPayPinException: $message';
}

/// PIN strength levels
enum RantiPayPinStrength {
  weak,
  fair,
  good,
  strong,
}

/// PIN strength analyzer
class RantiPayPinStrengthAnalyzer {
  static RantiPayPinStrength analyze(String pin) {
    if (pin.length < 4) return RantiPayPinStrength.weak;
    
    int score = 0;
    
    // Length score
    if (pin.length >= 6) score++;
    if (pin.length >= 8) score++;
    
    // Variety score
    final uniqueDigits = pin.split('').toSet().length;
    if (uniqueDigits >= 3) score++;
    if (uniqueDigits >= 5) score++;
    
    // Pattern score
    if (!_hasPattern(pin)) score++;
    
    // Not common PIN
    if (!RantiPayPinService(
      secureStorage: throw UnimplementedError(),
      encryptionService: throw UnimplementedError(),
    )._isCommonPin(pin)) {
      score++;
    }
    
    if (score >= 5) return RantiPayPinStrength.strong;
    if (score >= 3) return RantiPayPinStrength.good;
    if (score >= 1) return RantiPayPinStrength.fair;
    return RantiPayPinStrength.weak;
  }
  
  static bool _hasPattern(String pin) {
    // Check for repeating patterns
    for (int len = 2; len <= pin.length ~/ 2; len++) {
      final pattern = pin.substring(0, len);
      final repeated = pattern * (pin.length ~/ len);
      if (repeated == pin.substring(0, repeated.length)) {
        return true;
      }
    }
    return false;
  }
}