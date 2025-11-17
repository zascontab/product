// lib/core/security/rantipay_secure_storage_manager.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/config/rantipay_enviroment.dart';
import 'package:rantipay_app/core/rantipay/rantipay_encryption_manager.dart';
import 'package:rantipay_app/core/rantipay/rantipay_logger.dart';

/// RantiPay: Gestor de almacenamiento seguro
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: FlutterSecureStorage, EncryptionManager
///
/// Uso:
/// ```dart
/// final storage = getIt<RantiPaySecureStorageManager>();
/// await storage.write('token', {'access_token': 'xxx'});
/// final token = await storage.read('token');
/// ```
@lazySingleton
class RantiPaySecureStorageManager {
  final FlutterSecureStorage _secureStorage;
  final RantiPayLogger _logger;
  final RantiPayEncryptionManager _encryptionManager;

  // Prefijo para las claves
  static const String _keyPrefix = 'rantipay_';

  // Opciones de almacenamiento seguro
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    sharedPreferencesName: 'rantipay_secure_prefs',
    preferencesKeyPrefix: 'rantipay_',
  );

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    accountName: 'com.rantipay.app',
    groupId: 'group.com.rantipay.app',
    synchronizable: false,
  );

  RantiPaySecureStorageManager(
    this._logger,
    this._encryptionManager,
  ) : _secureStorage = const FlutterSecureStorage(
          aOptions: _androidOptions,
          iOptions: _iosOptions,
        );

  // Constructor para testing
  @visibleForTesting
  RantiPaySecureStorageManager.withStorage(
    this._secureStorage,
    this._logger,
    this._encryptionManager,
  );

  /// Escribir datos seguros
  Future<void> write(String key, dynamic value) async {
    try {
      final prefixedKey = _getPrefixedKey(key);

      // Convertir a JSON si no es string
      final String stringValue;
      if (value is String) {
        stringValue = value;
      } else {
        stringValue = json.encode(value);
      }

      // Encriptar el valor si está en producción
      final String finalValue;
      if (RantiPayEnvironment.isProd) {
        finalValue = await _encryptionManager.encrypt(stringValue);
      } else {
        finalValue = stringValue;
      }

      await _secureStorage.write(
        key: prefixedKey,
        value: finalValue,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      _logger.debug('Secure storage write successful', {'key': key});
    } catch (e) {
      _logger.error('Error writing to secure storage', e);
      rethrow;
    }
  }

  /// Leer datos seguros
  Future<dynamic> read(String key) async {
    try {
      final prefixedKey = _getPrefixedKey(key);

      final encryptedValue = await _secureStorage.read(
        key: prefixedKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      if (encryptedValue == null) {
        return null;
      }

      // Desencriptar si está en producción
      String decryptedValue;
      if (RantiPayEnvironment.isProd) {
        try {
          decryptedValue = await _encryptionManager.decrypt(encryptedValue);
        } catch (e) {
          _logger.error('Error decrypting value, might be unencrypted', e);
          decryptedValue = encryptedValue;
        }
      } else {
        decryptedValue = encryptedValue;
      }

      // Intentar parsear como JSON
      try {
        return json.decode(decryptedValue);
      } catch (_) {
        // Si no es JSON, devolver como string
        return decryptedValue;
      }
    } catch (e) {
      _logger.error('Error reading from secure storage', e);
      return null;
    }
  }

  /// Eliminar un valor
  Future<void> delete(String key) async {
    try {
      final prefixedKey = _getPrefixedKey(key);

      await _secureStorage.delete(
        key: prefixedKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      _logger.debug('Secure storage delete successful', {'key': key});
    } catch (e) {
      _logger.error('Error deleting from secure storage', e);
      rethrow;
    }
  }

  /// Eliminar todos los valores
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      _logger.info('All secure storage cleared');
    } catch (e) {
      _logger.error('Error clearing secure storage', e);
      rethrow;
    }
  }

  /// Verificar si existe una clave
  Future<bool> containsKey(String key) async {
    try {
      final prefixedKey = _getPrefixedKey(key);

      return await _secureStorage.containsKey(
        key: prefixedKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      _logger.error('Error checking key existence', e);
      return false;
    }
  }

  /// Obtener todas las claves
  Future<Map<String, String>> readAll() async {
    try {
      final allValues = await _secureStorage.readAll(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      // Filtrar solo las claves con nuestro prefijo
      final Map<String, String> filteredValues = {};

      allValues.forEach((key, value) {
        if (key.startsWith(_keyPrefix)) {
          // Remover el prefijo de la clave
          final originalKey = key.substring(_keyPrefix.length);
          filteredValues[originalKey] = value;
        }
      });

      return filteredValues;
    } catch (e) {
      _logger.error('Error reading all values', e);
      return {};
    }
  }

  // Métodos específicos para tokens

  /// Guardar token de acceso
  Future<void> saveAccessToken(String token) async {
    await write('access_token', token);
  }

  /// Obtener token de acceso
  Future<String?> getAccessToken() async {
    final token = await read('access_token');
    return token as String?;
  }

  /// Guardar refresh token
  Future<void> saveRefreshToken(String token) async {
    await write('refresh_token', token);
  }

  /// Obtener refresh token
  Future<String?> getRefreshToken() async {
    final token = await read('refresh_token');
    return token as String?;
  }

  /// Guardar tokens (access y refresh)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    await write('tokens', {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt?.toIso8601String(),
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  /// Obtener tokens
  Future<Map<String, dynamic>?> getTokens() async {
    final tokens = await read('tokens');
    return tokens as Map<String, dynamic>?;
  }

  /// Limpiar tokens
  Future<void> clearTokens() async {
    await delete('access_token');
    await delete('refresh_token');
    await delete('tokens');
  }

  // Métodos específicos para usuario

  /// Guardar información del usuario
  Future<void> saveUser(Map<String, dynamic> user) async {
    await write('current_user', user);
  }

  /// Obtener información del usuario
  Future<Map<String, dynamic>?> getUser() async {
    final user = await read('current_user');
    return user as Map<String, dynamic>?;
  }

  /// Limpiar información del usuario
  Future<void> clearUser() async {
    await delete('current_user');
  }

  // Métodos para credenciales biométricas

  /// Guardar PIN
  Future<void> savePin(String pin) async {
    // El PIN debe estar hasheado antes de guardarse
    await write('user_pin', pin);
  }

  /// Verificar PIN
  Future<bool> verifyPin(String pin) async {
    final savedPin = await read('user_pin');
    return savedPin == pin;
  }

  /// Habilitar biométricos
  Future<void> enableBiometrics(bool enabled) async {
    await write('biometrics_enabled', enabled);
  }

  /// Verificar si biométricos están habilitados
  Future<bool> isBiometricsEnabled() async {
    final enabled = await read('biometrics_enabled');
    return enabled == true;
  }

  // Métodos para configuración

  /// Guardar preferencias
  Future<void> savePreferences(Map<String, dynamic> preferences) async {
    await write('user_preferences', preferences);
  }

  /// Obtener preferencias
  Future<Map<String, dynamic>?> getPreferences() async {
    final prefs = await read('user_preferences');
    return prefs as Map<String, dynamic>?;
  }

  /// Guardar último ambiente usado
  Future<void> saveLastEnvironment(String environment) async {
    await write('last_environment', environment);
  }

  /// Obtener último ambiente usado
  Future<String?> getLastEnvironment() async {
    final env = await read('last_environment');
    return env as String?;
  }

  // Métodos para sesión

  /// Guardar ID de sesión
  Future<void> saveSessionId(String sessionId) async {
    await write('session_id', sessionId);
  }

  /// Obtener ID de sesión
  Future<String?> getSessionId() async {
    final sessionId = await read('session_id');
    return sessionId as String?;
  }

  /// Guardar información de dispositivo
  Future<void> saveDeviceInfo(Map<String, dynamic> deviceInfo) async {
    await write('device_info', deviceInfo);
  }

  /// Obtener información de dispositivo
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    final info = await read('device_info');
    return info as Map<String, dynamic>?;
  }

  // Métodos de migración

  /// Migrar datos desde SharedPreferences inseguro
  Future<void> migrateFromInsecureStorage(Map<String, dynamic> data) async {
    try {
      for (final entry in data.entries) {
        await write(entry.key, entry.value);
      }
      _logger.info('Migration to secure storage completed', {
        'keys': data.keys.length,
      });
    } catch (e) {
      _logger.error('Error migrating to secure storage', e);
      rethrow;
    }
  }

  /// Backup de datos seguros
  Future<Map<String, dynamic>> createBackup() async {
    try {
      final allData = await readAll();
      final backup = <String, dynamic>{};

      for (final entry in allData.entries) {
        try {
          backup[entry.key] = json.decode(entry.value);
        } catch (_) {
          backup[entry.key] = entry.value;
        }
      }

      return {
        'version': 1,
        'created_at': DateTime.now().toIso8601String(),
        'data': backup,
      };
    } catch (e) {
      _logger.error('Error creating backup', e);
      rethrow;
    }
  }

  /// Restaurar desde backup
  Future<void> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      final data = backup['data'] as Map<String, dynamic>;

      for (final entry in data.entries) {
        await write(entry.key, entry.value);
      }

      _logger.info('Backup restored successfully', {
        'keys': data.keys.length,
      });
    } catch (e) {
      _logger.error('Error restoring from backup', e);
      rethrow;
    }
  }

  // Utilidades privadas

  String _getPrefixedKey(String key) {
    return '$_keyPrefix$key';
  }

  /// Limpiar todos los datos (logout completo)
  Future<void> clearAllUserData() async {
    await clearTokens();
    await clearUser();
    await delete('session_id');
    await delete('user_pin');
    // No eliminar preferencias ni configuración de biométricos

    _logger.info('All user data cleared from secure storage');
  }
}
