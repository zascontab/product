import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage service for sensitive data
class RantiPaySecureStorage {
  static const String _keyPrefix = 'rantipay_';

  // Storage keys
  static const String keyAccessToken = '${_keyPrefix}access_token';
  static const String keyRefreshToken = '${_keyPrefix}refresh_token';
  static const String keyUserPin = '${_keyPrefix}user_pin';
  static const String keyBiometricEnabled = '${_keyPrefix}biometric_enabled';
  static const String keyDeviceId = '${_keyPrefix}device_id';
  static const String keyEncryptionKey = '${_keyPrefix}encryption_key';
  static const String keyUserData = '${_keyPrefix}user_data';
  static const String keyCompanyData = '${_keyPrefix}company_data';
  static const String keySessionData = '${_keyPrefix}session_data';
  static const String keyLastActivity = '${_keyPrefix}last_activity';
  static const String keyFailedAttempts = '${_keyPrefix}failed_attempts';
  static const String keyLockoutTime = '${_keyPrefix}lockout_time';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _preferences;
  final bool _enableEncryption;

  RantiPaySecureStorage({
    FlutterSecureStorage? secureStorage,
    required SharedPreferences preferences,
    bool enableEncryption = true,
  })  : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
                accountName: 'RantiPaySecureStorage',
              ),
            ),
        _preferences = preferences,
        _enableEncryption = enableEncryption;

  /// Write secure value
  Future<void> writeSecure({
    required String key,
    required String value,
    bool isSensitive = true,
  }) async {
    if (isSensitive && _enableEncryption) {
      // Store in secure storage
      await _secureStorage.write(
        key: key,
        value: value,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } else {
      // Store in regular preferences
      await _preferences.setString(key, value);
    }
  }

  /// Read secure value
  Future<String?> readSecure({
    required String key,
    bool isSensitive = true,
  }) async {
    if (isSensitive && _enableEncryption) {
      return await _secureStorage.read(
        key: key,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } else {
      return _preferences.getString(key);
    }
  }

  /// Delete secure value
  Future<void> deleteSecure({
    required String key,
    bool isSensitive = true,
  }) async {
    if (isSensitive && _enableEncryption) {
      await _secureStorage.delete(
        key: key,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } else {
      await _preferences.remove(key);
    }
  }

  /// Clear all secure storage
  Future<void> clearAll() async {
    // Clear secure storage
    await _secureStorage.deleteAll(
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );

    // Clear preferences with our prefix
    final keys = _preferences
        .getKeys()
        .where((key) => key.startsWith(_keyPrefix))
        .toList();

    for (final key in keys) {
      await _preferences.remove(key);
    }
  }

  /// Check if key exists
  Future<bool> containsKey({
    required String key,
    bool isSensitive = true,
  }) async {
    if (isSensitive && _enableEncryption) {
      final value = await _secureStorage.read(
        key: key,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      return value != null;
    } else {
      return _preferences.containsKey(key);
    }
  }

  // ==================== Token Management ====================

  /// Save authentication tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    print('🔐 RantiPaySecureStorage.saveTokens: Guardando tokens...');
    
    // IMPORTANTE: Limpiar tokens antiguos antes de guardar nuevos
    print('🧹 Limpiando tokens antiguos antes de guardar nuevos...');
    await deleteSecure(key: keyAccessToken);
    await deleteSecure(key: keyRefreshToken);
    
    // Esperar un momento para asegurar que se limpiaron
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Ahora guardar los nuevos tokens
    await writeSecure(key: keyAccessToken, value: accessToken);
    await writeSecure(key: keyRefreshToken, value: refreshToken);
    
    // Verificar que se guardaron correctamente
    final savedAccess = await readSecure(key: keyAccessToken);
    final savedRefresh = await readSecure(key: keyRefreshToken);
    
    if (savedAccess == accessToken && savedRefresh == refreshToken) {
      print('✅ RantiPaySecureStorage.saveTokens: Tokens guardados correctamente en SecureStorage');
      // Debug: verificar que es el token correcto
      try {
        if (savedAccess != null && savedAccess.length > 20) {
          print('   - Token guardado empieza con: ${savedAccess.substring(0, 20)}...');
        }
      } catch (_) {}
    } else {
      print('❌ RantiPaySecureStorage.saveTokens: Error al guardar tokens en SecureStorage');
      print('   - Expected access: ${accessToken.length > 20 ? accessToken.substring(0, 20) : accessToken}...');
      print('   - Saved access: ${(savedAccess?.length ?? 0) > 20 ? savedAccess?.substring(0, 20) : savedAccess}...');
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final token = await readSecure(key: keyAccessToken);
    if (token != null) {
      print('🔍 RantiPaySecureStorage.getAccessToken: Token encontrado');
    } else {
      print('❌ RantiPaySecureStorage.getAccessToken: No se encontró token');
    }
    return token;
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await readSecure(key: keyRefreshToken);
  }

  /// Clear tokens
  Future<void> clearTokens() async {
    await deleteSecure(key: keyAccessToken);
    await deleteSecure(key: keyRefreshToken);
  }

  // ==================== User Data Management ====================

  /// Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await writeSecure(key: keyUserData, value: jsonString);
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = await readSecure(key: keyUserData);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Clear user data
  Future<void> clearUserData() async {
    await deleteSecure(key: keyUserData);
  }

  // ==================== PIN Management ====================

  /// Save user PIN (hashed)
  Future<void> savePin(String hashedPin) async {
    await writeSecure(key: keyUserPin, value: hashedPin);
  }

  /// Get user PIN (hashed)
  Future<String?> getPin() async {
    return await readSecure(key: keyUserPin);
  }

  /// Check if PIN is set
  Future<bool> isPinSet() async {
    return await containsKey(key: keyUserPin);
  }

  /// Clear PIN
  Future<void> clearPin() async {
    await deleteSecure(key: keyUserPin);
  }

  // ==================== Biometric Settings ====================

  /// Save biometric enabled state
  Future<void> setBiometricEnabled(bool enabled) async {
    await _preferences.setBool(keyBiometricEnabled, enabled);
  }

  /// Get biometric enabled state
  bool getBiometricEnabled() {
    return _preferences.getBool(keyBiometricEnabled) ?? false;
  }

  // ==================== Device Management ====================

  /// Save device ID
  Future<void> saveDeviceId(String deviceId) async {
    await writeSecure(key: keyDeviceId, value: deviceId);
  }

  /// Get device ID
  Future<String?> getDeviceId() async {
    return await readSecure(key: keyDeviceId);
  }

  // ==================== Session Management ====================

  /// Save session data
  Future<void> saveSessionData(Map<String, dynamic> sessionData) async {
    final jsonString = jsonEncode(sessionData);
    await writeSecure(key: keySessionData, value: jsonString);
    await updateLastActivity();
  }

  /// Get session data
  Future<Map<String, dynamic>?> getSessionData() async {
    final jsonString = await readSecure(key: keySessionData);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Update last activity timestamp
  Future<void> updateLastActivity() async {
    await _preferences.setInt(
      keyLastActivity,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get last activity timestamp
  DateTime? getLastActivity() {
    final timestamp = _preferences.getInt(keyLastActivity);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// Check if session is expired
  bool isSessionExpired(
      {Duration maxInactivity = const Duration(minutes: 30)}) {
    final lastActivity = getLastActivity();
    if (lastActivity == null) return true;

    return DateTime.now().difference(lastActivity) > maxInactivity;
  }

  // ==================== Security Features ====================

  /// Increment failed attempts
  Future<void> incrementFailedAttempts() async {
    final current = _preferences.getInt(keyFailedAttempts) ?? 0;
    await _preferences.setInt(keyFailedAttempts, current + 1);

    // Lock after 5 attempts
    if (current + 1 >= 5) {
      await _preferences.setInt(
        keyLockoutTime,
        DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch,
      );
    }
  }

  /// Reset failed attempts
  Future<void> resetFailedAttempts() async {
    await _preferences.remove(keyFailedAttempts);
    await _preferences.remove(keyLockoutTime);
  }

  /// Get failed attempts count
  int getFailedAttempts() {
    return _preferences.getInt(keyFailedAttempts) ?? 0;
  }

  /// Check if account is locked
  bool isAccountLocked() {
    final lockoutTime = _preferences.getInt(keyLockoutTime);
    if (lockoutTime == null) return false;

    final lockoutDateTime = DateTime.fromMillisecondsSinceEpoch(lockoutTime);
    return DateTime.now().isBefore(lockoutDateTime);
  }

  /// Get lockout remaining time
  Duration? getLockoutRemainingTime() {
    final lockoutTime = _preferences.getInt(keyLockoutTime);
    if (lockoutTime == null) return null;

    final lockoutDateTime = DateTime.fromMillisecondsSinceEpoch(lockoutTime);
    final remaining = lockoutDateTime.difference(DateTime.now());

    return remaining.isNegative ? null : remaining;
  }

  // ==================== Private Methods ====================

  AndroidOptions _getAndroidOptions() {
    return const AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    );
  }

  IOSOptions _getIOSOptions() {
    return const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'RantiPaySecureStorage',
      groupId: 'group.com.rantipay.app',
      synchronizable: false,
    );
  }

  /// Clear all authentication tokens (for debugging/logout)
  Future<void> clearAllTokens() async {
    print('🧹 RantiPaySecureStorage.clearAllTokens: Limpiando todos los tokens...');
    
    try {
      // Clear from secure storage
      await deleteSecure(key: keyAccessToken);
      await deleteSecure(key: keyRefreshToken);
      
      // Clear from preferences
      await _preferences.remove(keyAccessToken);
      await _preferences.remove(keyRefreshToken);
      
      // Clear session data
      await _preferences.remove(keyLastActivity);
      await _preferences.remove(keySessionData);
      
      // Clear user data
      await deleteSecure(key: keyUserData);
      await _preferences.remove(keyUserData);
      
      print('✅ RantiPaySecureStorage.clearAllTokens: Todos los tokens limpiados');
    } catch (e) {
      print('❌ RantiPaySecureStorage.clearAllTokens: Error limpiando tokens: $e');
      rethrow;
    }
  }
}

/// Secure storage keys enum for type safety
enum RantiPaySecureKey {
  accessToken,
  refreshToken,
  userPin,
  deviceId,
  encryptionKey,
  userData,
  companyData,
  sessionData,
}

extension RantiPaySecureKeyExtension on RantiPaySecureKey {
  String get value {
    switch (this) {
      case RantiPaySecureKey.accessToken:
        return RantiPaySecureStorage.keyAccessToken;
      case RantiPaySecureKey.refreshToken:
        return RantiPaySecureStorage.keyRefreshToken;
      case RantiPaySecureKey.userPin:
        return RantiPaySecureStorage.keyUserPin;
      case RantiPaySecureKey.deviceId:
        return RantiPaySecureStorage.keyDeviceId;
      case RantiPaySecureKey.encryptionKey:
        return RantiPaySecureStorage.keyEncryptionKey;
      case RantiPaySecureKey.userData:
        return RantiPaySecureStorage.keyUserData;
      case RantiPaySecureKey.companyData:
        return RantiPaySecureStorage.keyCompanyData;
      case RantiPaySecureKey.sessionData:
        return RantiPaySecureStorage.keySessionData;
    }
  }
}
