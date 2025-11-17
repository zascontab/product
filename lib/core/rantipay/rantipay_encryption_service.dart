import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// Encryption service for data protection
class RantiPayEncryptionService {
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits
  static const int _saltLength = 32; // 256 bits
  static const int _iterations = 10000;

  final String? _masterKey;
  late final Key _encryptionKey;
  final Random _random = Random.secure();

  RantiPayEncryptionService({String? masterKey}) : _masterKey = masterKey {
    // Initialize encryption key
    if (_masterKey != null && _masterKey.isNotEmpty) {
      _encryptionKey = Key.fromBase64(_masterKey ?? '');
    } else {
      // Generate a random key if none provided
      _encryptionKey = Key.fromSecureRandom(_keyLength);
    }
  }

  /// Generate a new encryption key
  String generateKey() {
    final key = Key.fromSecureRandom(_keyLength);
    return key.base64;
  }

  /// Generate a random IV
  IV generateIV() {
    return IV.fromSecureRandom(_ivLength);
  }

  /// Generate salt for key derivation
  Uint8List generateSalt() {
    final salt = Uint8List(_saltLength);
    for (int i = 0; i < _saltLength; i++) {
      salt[i] = _random.nextInt(256);
    }
    return salt;
  }

  /// Encrypt string data
  String encryptString(String plainText, {String? key}) {
    try {
      final encryptionKey = key != null ? Key.fromBase64(key) : _encryptionKey;
      final iv = generateIV();
      final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));

      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Combine IV and encrypted data
      final combined = iv.base64 + ':' + encrypted.base64;
      return combined;
    } catch (e) {
      throw RantiPayEncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Decrypt string data
  String decryptString(String encryptedData, {String? key}) {
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw RantiPayEncryptionException('Invalid encrypted data format');
      }

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);
      final encryptionKey = key != null ? Key.fromBase64(key) : _encryptionKey;
      final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw RantiPayEncryptionException('Failed to decrypt data: $e');
    }
  }

  /// Encrypt JSON data
  String encryptJson(Map<String, dynamic> data, {String? key}) {
    final jsonString = jsonEncode(data);
    return encryptString(jsonString, key: key);
  }

  /// Decrypt JSON data
  Map<String, dynamic> decryptJson(String encryptedData, {String? key}) {
    final jsonString = decryptString(encryptedData, key: key);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Encrypt bytes
  Uint8List encryptBytes(Uint8List data, {String? key}) {
    try {
      final encryptionKey = key != null ? Key.fromBase64(key) : _encryptionKey;
      final iv = generateIV();
      final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));

      final encrypted = encrypter.encryptBytes(data, iv: iv);

      // Combine IV and encrypted data
      final combined = Uint8List(iv.bytes.length + encrypted.bytes.length);
      combined.setRange(0, iv.bytes.length, iv.bytes);
      combined.setRange(iv.bytes.length, combined.length, encrypted.bytes);

      return combined;
    } catch (e) {
      throw RantiPayEncryptionException('Failed to encrypt bytes: $e');
    }
  }

  /// Decrypt bytes
  Uint8List decryptBytes(Uint8List encryptedData, {String? key}) {
    try {
      if (encryptedData.length < _ivLength) {
        throw RantiPayEncryptionException('Invalid encrypted data length');
      }

      // Extract IV and encrypted data
      final iv = IV(encryptedData.sublist(0, _ivLength));
      final encrypted = Encrypted(encryptedData.sublist(_ivLength));

      final encryptionKey = key != null ? Key.fromBase64(key) : _encryptionKey;
      final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));

      return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
    } catch (e) {
      throw RantiPayEncryptionException('Failed to decrypt bytes: $e');
    }
  }

  /// Hash password with salt
  String hashPassword(String password, {Uint8List? salt}) {
    salt ??= generateSalt();

    final key = _deriveKey(password, salt);
    final hash = sha256.convert(key).toString();

    // Combine salt and hash
    return '${base64.encode(salt)}:$hash';
  }

  /// Verify password against hash
  bool verifyPassword(String password, String hashedPassword) {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) return false;

      final salt = base64.decode(parts[0]);
      final storedHash = parts[1];

      final key = _deriveKey(password, salt);
      final hash = sha256.convert(key).toString();

      return hash == storedHash;
    } catch (e) {
      return false;
    }
  }

  /// Hash PIN (simpler than password)
  String hashPin(String pin) {
    if (pin.length < 4 || pin.length > 8) {
      throw RantiPayEncryptionException('PIN must be between 4 and 8 digits');
    }

    // Use a fixed salt for PINs to allow easier verification
    const fixedSalt = 'RantiPayPINSalt2024';
    final bytes = utf8.encode(pin + fixedSalt);
    final hash = sha256.convert(bytes);

    return hash.toString();
  }

  /// Generate secure random string
  String generateSecureRandom({int length = 32}) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// Generate OTP
  String generateOTP({int length = 6}) {
    const digits = '0123456789';
    return List.generate(
      length,
      (index) => digits[_random.nextInt(digits.length)],
    ).join();
  }

  /// Mask sensitive data (e.g., card numbers)
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

  /// Tokenize sensitive data
  String tokenizeData(String data) {
    // Create a unique token for the data
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = generateSecureRandom(length: 16);
    final token = 'tok_${timestamp}_$random';

    // In a real implementation, you would store the mapping
    // between token and encrypted data in secure storage

    return token;
  }

  /// Calculate HMAC
  String calculateHMAC(String data, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);

    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    return digest.toString();
  }

  /// Verify HMAC
  bool verifyHMAC(String data, String secret, String hmac) {
    final calculated = calculateHMAC(data, secret);
    return calculated == hmac;
  }

  /// Derive key from password using PBKDF2
  Uint8List _deriveKey(String password, Uint8List salt) {
    // Simple implementation - in production use proper PBKDF2
    final input = utf8.encode(password) + salt;
    var hash = sha256.convert(input).bytes;

    // Iterate to increase computation time
    for (int i = 1; i < _iterations; i++) {
      hash = sha256.convert(hash + salt).bytes;
    }

    return Uint8List.fromList(hash);
  }

  /// Create encryption envelope for API requests
  Map<String, dynamic> createEncryptionEnvelope(
    Map<String, dynamic> data, {
    String? publicKey,
  }) {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final nonce = generateSecureRandom(length: 16);

    // Add metadata to data
    final payload = {
      ...data,
      '_timestamp': timestamp,
      '_nonce': nonce,
    };

    // Encrypt payload
    final encryptedPayload = encryptJson(payload);

    // Create envelope
    return {
      'encrypted': true,
      'algorithm': 'AES-256-GCM',
      'timestamp': timestamp,
      'nonce': nonce,
      'payload': encryptedPayload,
    };
  }

  /// Extract data from encryption envelope
  Map<String, dynamic> extractFromEnvelope(Map<String, dynamic> envelope) {
    if (envelope['encrypted'] != true) {
      throw RantiPayEncryptionException('Data is not encrypted');
    }

    final encryptedPayload = envelope['payload'] as String;
    final payload = decryptJson(encryptedPayload);

    // Verify timestamp (prevent replay attacks)
    final timestamp = payload['_timestamp'] as String?;
    if (timestamp != null) {
      final messageTime = DateTime.parse(timestamp);
      final now = DateTime.now().toUtc();
      final difference = now.difference(messageTime);

      // Reject messages older than 5 minutes
      if (difference.inMinutes > 5) {
        throw RantiPayEncryptionException('Message timestamp expired');
      }
    }

    // Remove metadata
    payload.remove('_timestamp');
    payload.remove('_nonce');

    return payload;
  }
}

/// Encryption exception
class RantiPayEncryptionException implements Exception {
  final String message;

  RantiPayEncryptionException(this.message);

  @override
  String toString() => 'RantiPayEncryptionException: $message';
}

/// Encryption algorithm enum
enum RantiPayEncryptionAlgorithm {
  aes256gcm,
  aes256cbc,
  rsa2048,
  rsa4096,
}

/// Encryption strength levels
enum RantiPayEncryptionStrength {
  basic, // For non-sensitive data
  standard, // For PII and financial data
  maximum, // For highly sensitive data
}
