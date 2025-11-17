// lib/core/security/rantipay_encryption_manager.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as RantiPayEnvironment;
import 'package:rantipay_app/core/rantipay/rantipay_encryption_service.dart';
import 'package:rantipay_app/core/rantipay/rantipay_logger.dart';

/// RantiPay: Gestor de encriptación para protección de datos
///
/// Requisitos:
/// - User Level: N/A
/// - Dependencias: crypto, encrypt
///
/// Uso:
/// ```dart
/// final encryptionManager = getIt<RantiPayEncryptionManager>();
/// final encrypted = await encryptionManager.encrypt('sensitive data');
/// final decrypted = await encryptionManager.decrypt(encrypted);
/// ```
@lazySingleton
class RantiPayEncryptionManager {
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits
  static const int _saltLength = 32; // 256 bits
  static const int _iterations = 10000;
  static const String _pepper = 'RantiPay2024SecurityPepper';

  final RantiPayLogger _logger;
  final Random _random = Random.secure();

  late final Key _masterKey;
  final Map<String, Key> _keyCache = {};

  RantiPayEncryptionManager(this._logger) {
    _initializeMasterKey();
  }

  // Constructor para testing con key específica
  @visibleForTesting
  RantiPayEncryptionManager.withKey(this._logger, String masterKey) {
    _masterKey = Key.fromBase64(masterKey);
  }

  void _initializeMasterKey() {
    // En producción, esta key debería venir de un servicio seguro
    // Por ahora, generamos una basada en el ambiente
    final keyData =
        utf8.encode('RantiPay_${RantiPayEnvironment.current}_Master_Key_2024');
    final hash = sha256.convert(keyData);
    _masterKey = Key(Uint8List.fromList(hash.bytes));

    _logger.debug(
        'Encryption manager initialized for ${RantiPayEnvironment.current}');
  }

  /// Generar una nueva clave de encriptación
  Future<String> generateKey() async {
    try {
      final key = Key.fromSecureRandom(_keyLength);
      return key.base64;
    } catch (e) {
      _logger.error('Error generating encryption key', e);
      throw RantiPayEncryptionException('Failed to generate key: $e');
    }
  }

  /// Generar IV aleatorio
  IV _generateIV() {
    return IV.fromSecureRandom(_ivLength);
  }

  /// Generar salt para derivación de claves
  Uint8List _generateSalt() {
    final salt = Uint8List(_saltLength);
    for (int i = 0; i < _saltLength; i++) {
      salt[i] = _random.nextInt(256);
    }
    return salt;
  }

  /// Encriptar string
  Future<String> encrypt(String plainText, {String? key}) async {
    try {
      if (plainText.isEmpty) return '';

      final encryptionKey = key != null ? Key.fromBase64(key) : _masterKey;
      final iv = _generateIV();
      final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));

      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Combinar IV y datos encriptados
      final combined = '${iv.base64}:${encrypted.base64}';

      _logger.debug('Data encrypted successfully', {
        'inputLength': plainText.length,
        'outputLength': combined.length,
      });

      return combined;
    } catch (e) {
      _logger.error('Encryption failed', e);
      throw RantiPayEncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Desencriptar string
  Future<String> decrypt(String encryptedData, {String? key}) async {
    try {
      if (encryptedData.isEmpty) return '';

      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw RantiPayEncryptionException('Invalid encrypted data format');
      }

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);
      final encryptionKey = key != null ? Key.fromBase64(key) : _masterKey;
      final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));

      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      _logger.debug('Data decrypted successfully', {
        'inputLength': encryptedData.length,
        'outputLength': decrypted.length,
      });

      return decrypted;
    } catch (e) {
      _logger.error('Decryption failed', e);
      throw RantiPayEncryptionException('Failed to decrypt data: $e');
    }
  }

  /// Encriptar JSON
  Future<String> encryptJson(Map<String, dynamic> data, {String? key}) async {
    try {
      final jsonString = json.encode(data);
      return await encrypt(jsonString, key: key);
    } catch (e) {
      _logger.error('JSON encryption failed', e);
      throw RantiPayEncryptionException('Failed to encrypt JSON: $e');
    }
  }

  /// Desencriptar JSON
  Future<Map<String, dynamic>> decryptJson(String encryptedData,
      {String? key}) async {
    try {
      final jsonString = await decrypt(encryptedData, key: key);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _logger.error('JSON decryption failed', e);
      throw RantiPayEncryptionException('Failed to decrypt JSON: $e');
    }
  }

  /// Encriptar bytes
  Future<Uint8List> encryptBytes(Uint8List data, {String? key}) async {
    try {
      final encryptionKey = key != null ? Key.fromBase64(key) : _masterKey;
      final iv = _generateIV();
      final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));

      final encrypted = encrypter.encryptBytes(data, iv: iv);

      // Combinar IV y datos encriptados
      final combined = Uint8List(iv.bytes.length + encrypted.bytes.length);
      combined.setRange(0, iv.bytes.length, iv.bytes);
      combined.setRange(iv.bytes.length, combined.length, encrypted.bytes);

      return combined;
    } catch (e) {
      _logger.error('Bytes encryption failed', e);
      throw RantiPayEncryptionException('Failed to encrypt bytes: $e');
    }
  }

  /// Desencriptar bytes
  Future<Uint8List> decryptBytes(Uint8List encryptedData, {String? key}) async {
    try {
      if (encryptedData.length < _ivLength) {
        throw RantiPayEncryptionException('Invalid encrypted data length');
      }

      // Extraer IV y datos encriptados
      final iv = IV(encryptedData.sublist(0, _ivLength));
      final encrypted = Encrypted(encryptedData.sublist(_ivLength));

      final encryptionKey = key != null ? Key.fromBase64(key) : _masterKey;
      final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));

      return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
    } catch (e) {
      _logger.error('Bytes decryption failed', e);
      throw RantiPayEncryptionException('Failed to decrypt bytes: $e');
    }
  }

  /// Hash de contraseña con salt
  Future<String> hashPassword(String password, {Uint8List? salt}) async {
    try {
      salt ??= _generateSalt();

      // Añadir pepper a la contraseña
      final pepperedPassword = password + _pepper;

      // Derivar clave usando PBKDF2 simplificado
      final key = await _deriveKey(pepperedPassword, salt);
      final hash = sha256.convert(key).toString();

      // Combinar salt y hash
      final result = '${base64.encode(salt)}:$hash';

      _logger.debug('Password hashed successfully');

      return result;
    } catch (e) {
      _logger.error('Password hashing failed', e);
      throw RantiPayEncryptionException('Failed to hash password: $e');
    }
  }

  /// Verificar contraseña contra hash
  Future<bool> verifyPassword(String password, String hashedPassword) async {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) return false;

      final salt = base64.decode(parts[0]);
      final storedHash = parts[1];

      // Añadir pepper
      final pepperedPassword = password + _pepper;

      final key = await _deriveKey(pepperedPassword, salt);
      final hash = sha256.convert(key).toString();

      return _constantTimeCompare(hash, storedHash);
    } catch (e) {
      _logger.error('Password verification failed', e);
      return false;
    }
  }

  /// Hash de PIN (más simple que contraseña)
  Future<String> hashPin(String pin) async {
    try {
      if (pin.length < 4 || pin.length > 8) {
        throw RantiPayEncryptionException('PIN must be between 4 and 8 digits');
      }

      // Validar que solo contenga dígitos
      if (!RegExp(r'^\d+$').hasMatch(pin)) {
        throw RantiPayEncryptionException('PIN must contain only digits');
      }

      // Usar salt fijo para PINs para permitir verificación más fácil
      const fixedSalt = 'RantiPayPINSalt2024';
      final bytes = utf8.encode(pin + fixedSalt + _pepper);
      final hash = sha256.convert(bytes);

      return hash.toString();
    } catch (e) {
      _logger.error('PIN hashing failed', e);
      throw RantiPayEncryptionException('Failed to hash PIN: $e');
    }
  }

  /// Verificar PIN
  Future<bool> verifyPin(String pin, String hashedPin) async {
    try {
      final hash = await hashPin(pin);
      return _constantTimeCompare(hash, hashedPin);
    } catch (e) {
      _logger.error('PIN verification failed', e);
      return false;
    }
  }

  /// Generar string aleatorio seguro
  String generateSecureRandom({int length = 32}) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// Generar OTP
  String generateOTP({int length = 6}) {
    const digits = '0123456789';
    return List.generate(
      length,
      (index) => digits[_random.nextInt(digits.length)],
    ).join();
  }

  /// Enmascarar datos sensibles
  String maskData(String data, {int visibleStart = 4, int visibleEnd = 4}) {
    if (data.length <= visibleStart + visibleEnd) {
      return data;
    }

    final start = data.substring(0, visibleStart);
    final end = data.substring(data.length - visibleEnd);
    final maskLength = data.length - visibleStart - visibleEnd;
    final mask = '*' * maskLength;

    return '$start$mask$end';
  }

  /// Tokenizar datos sensibles
  Future<String> tokenizeData(String data) async {
    try {
      // Crear un token único para los datos
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = generateSecureRandom(length: 16);
      final token = 'tok_${timestamp}_$random';

      // Encriptar y almacenar el mapeo en caché
      final encrypted = await encrypt(data);
      _keyCache[token] = Key.fromBase64(encrypted);

      _logger.debug('Data tokenized', {'token': token});

      return token;
    } catch (e) {
      _logger.error('Tokenization failed', e);
      throw RantiPayEncryptionException('Failed to tokenize data: $e');
    }
  }

  /// Detokenizar datos
  Future<String?> detokenizeData(String token) async {
    try {
      final key = _keyCache[token];
      if (key == null) {
        _logger.warning('Token not found', {'token': token});
        return null;
      }

      return await decrypt(key.base64);
    } catch (e) {
      _logger.error('Detokenization failed', e);
      return null;
    }
  }

  /// Calcular HMAC
  String calculateHMAC(String data, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);

    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    return digest.toString();
  }

  /// Verificar HMAC
  bool verifyHMAC(String data, String secret, String hmac) {
    final calculated = calculateHMAC(data, secret);
    return _constantTimeCompare(calculated, hmac);
  }

  /// Crear sobre de encriptación para peticiones API
  Future<Map<String, dynamic>> createEncryptionEnvelope(
    Map<String, dynamic> data, {
    String? publicKey,
  }) async {
    try {
      final timestamp = DateTime.now().toUtc().toIso8601String();
      final nonce = generateSecureRandom(length: 16);

      // Añadir metadata a los datos
      final payload = {
        ...data,
        '_timestamp': timestamp,
        '_nonce': nonce,
      };

      // Encriptar payload
      final encryptedPayload = await encryptJson(payload, key: publicKey);

      // Crear sobre
      final envelope = {
        'encrypted': true,
        'algorithm': 'AES-256-GCM',
        'timestamp': timestamp,
        'nonce': nonce,
        'payload': encryptedPayload,
      };

      _logger.debug('Encryption envelope created', {
        'timestamp': timestamp,
        'dataSize': data.length,
      });

      return envelope;
    } catch (e) {
      _logger.error('Envelope creation failed', e);
      throw RantiPayEncryptionException('Failed to create envelope: $e');
    }
  }

  /// Extraer datos del sobre de encriptación
  Future<Map<String, dynamic>> extractFromEnvelope(
    Map<String, dynamic> envelope, {
    String? privateKey,
  }) async {
    try {
      if (envelope['encrypted'] != true) {
        throw RantiPayEncryptionException('Data is not encrypted');
      }

      final encryptedPayload = envelope['payload'] as String;
      final payload = await decryptJson(encryptedPayload, key: privateKey);

      // Verificar timestamp (prevenir ataques de replay)
      final timestamp = payload['_timestamp'] as String?;
      if (timestamp != null) {
        final messageTime = DateTime.parse(timestamp);
        final now = DateTime.now().toUtc();
        final difference = now.difference(messageTime);

        // Rechazar mensajes de más de 5 minutos
        if (difference.inMinutes > 5) {
          throw RantiPayEncryptionException('Message timestamp expired');
        }
      }

      // Remover metadata
      payload.remove('_timestamp');
      payload.remove('_nonce');

      _logger.debug('Data extracted from envelope');

      return payload;
    } catch (e) {
      _logger.error('Envelope extraction failed', e);
      throw RantiPayEncryptionException('Failed to extract from envelope: $e');
    }
  }

  /// Encriptar para nivel de usuario específico
  Future<String> encryptForUserLevel(String data, int userLevel) async {
    try {
      // Usar diferentes fortalezas de encriptación según el nivel
      final keyStrength = _getKeyStrengthForLevel(userLevel);
      final key = await _deriveKeyForLevel(userLevel, keyStrength);

      return await encrypt(data, key: key.base64);
    } catch (e) {
      _logger.error('Level-based encryption failed', e);
      throw RantiPayEncryptionException('Failed to encrypt for user level: $e');
    }
  }

  /// Desencriptar para nivel de usuario específico
  Future<String> decryptForUserLevel(
      String encryptedData, int userLevel) async {
    try {
      final keyStrength = _getKeyStrengthForLevel(userLevel);
      final key = await _deriveKeyForLevel(userLevel, keyStrength);

      return await decrypt(encryptedData, key: key.base64);
    } catch (e) {
      _logger.error('Level-based decryption failed', e);
      throw RantiPayEncryptionException('Failed to decrypt for user level: $e');
    }
  }

  // Métodos privados

  /// Derivar clave usando PBKDF2 simplificado
  Future<Uint8List> _deriveKey(String password, Uint8List salt) async {
    // Implementación simplificada - en producción usar PBKDF2 real
    final input = utf8.encode(password) + salt;
    var hash = sha256.convert(input).bytes;

    // Iterar para aumentar tiempo de cómputo
    for (int i = 1; i < _iterations; i++) {
      hash = sha256.convert(hash + salt).bytes;
    }

    return Uint8List.fromList(hash);
  }

  /// Obtener fortaleza de clave para nivel de usuario
  int _getKeyStrengthForLevel(int userLevel) {
    switch (userLevel) {
      case 1:
        return 16; // 128 bits
      case 2:
        return 24; // 192 bits
      case 3:
      case 4:
        return 32; // 256 bits
      default:
        return 16;
    }
  }

  /// Derivar clave para nivel de usuario
  Future<Key> _deriveKeyForLevel(int userLevel, int keyLength) async {
    final levelData = utf8.encode('RantiPay_Level_${userLevel}_Key');
    final salt = _generateSalt();
    final derivedKey = await _deriveKey(base64.encode(levelData), salt);

    return Key(Uint8List.fromList(derivedKey.take(keyLength).toList()));
  }

  /// Comparación de tiempo constante (previene ataques de timing)
  bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Limpiar caché de tokens
  void clearTokenCache() {
    _keyCache.clear();
    _logger.info('Token cache cleared');
  }

  /// Obtener estadísticas de encriptación
  Map<String, dynamic> getStatistics() {
    return {
      'algorithm': 'AES-256-GCM',
      'keyLength': _keyLength * 8,
      'ivLength': _ivLength * 8,
      'iterations': _iterations,
      'tokensCached': _keyCache.length,
      'environment': RantiPayEnvironment.current,
    };
  }
}
