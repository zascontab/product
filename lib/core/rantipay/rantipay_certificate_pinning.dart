import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Certificate pinning service for secure connections
class RantiPayCertificatePinning {
  /// Production certificate pins (SHA256)
  static const List<String> productionPins = [
    // Add your actual certificate SHA256 hashes here
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
  ];

  /// Staging certificate pins (SHA256)
  static const List<String> stagingPins = [
    'sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
    'sha256/DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=',
  ];

  /// Verify certificate against pinned hashes
  static bool verifyCertificate(
    X509Certificate certificate,
    String host,
    int port, {
    required bool isProduction,
  }) {
    try {
      // Get the appropriate pins based on environment
      final pins = isProduction ? productionPins : stagingPins;

      // Calculate certificate fingerprint
      final fingerprint = calculateFingerprint(certificate);

      // Check if fingerprint matches any pinned certificate
      final isValid = pins.contains(fingerprint);

      if (!isValid) {
        _logPinningFailure(host, port, fingerprint, pins);
      }

      return isValid;
    } catch (e) {
      // Log error but don't expose details
      _logPinningError(host, e);
      return false;
    }
  }

  /// Calculate SHA256 fingerprint of certificate
  static String calculateFingerprint(X509Certificate certificate) {
    // Get DER encoded certificate
    final der = certificate.der;

    // Calculate SHA256 hash
    final digest = sha256.convert(der);

    // Convert to base64
    final base64Hash = base64.encode(digest.bytes);

    return 'sha256/$base64Hash';
  }

  /// Create HTTP client with certificate pinning
  static HttpClient createPinnedHttpClient({
    required bool isProduction,
    Duration? connectionTimeout,
  }) {
    final client = HttpClient();

    // Set certificate verification callback
    client.badCertificateCallback = (cert, host, port) {
      return verifyCertificate(cert, host, port, isProduction: isProduction);
    };

    // Set connection timeout
    if (connectionTimeout != null) {
      client.connectionTimeout = connectionTimeout;
    }

    // Additional security settings
    client.userAgent = 'RantiPay-Mobile/1.0';

    return client;
  }

  /// Verify server certificate chain
  static Future<RantiPayCertificateValidation> validateCertificateChain(
    String host,
    int port, {
    required bool isProduction,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      // Create secure socket to get certificate
      final socket = await SecureSocket.connect(
        host,
        port,
        timeout: timeout,
        onBadCertificate: (cert) {
          // Don't accept bad certificates during validation
          return false;
        },
      );

      // Get peer certificate
      final peerCertificate = socket.peerCertificate;
      if (peerCertificate == null) {
        await socket.close();
        return RantiPayCertificateValidation(
          isValid: false,
          error: 'No peer certificate found',
        );
      }

      // Verify certificate
      final isValid = verifyCertificate(
        peerCertificate,
        host,
        port,
        isProduction: isProduction,
      );

      // Get certificate details
      final fingerprint = calculateFingerprint(peerCertificate);
      final subject = peerCertificate.subject;
      final issuer = peerCertificate.issuer;
      final validFrom = peerCertificate.startValidity;
      final validTo = peerCertificate.endValidity;

      await socket.close();

      return RantiPayCertificateValidation(
        isValid: isValid,
        fingerprint: fingerprint,
        subject: subject,
        issuer: issuer,
        validFrom: validFrom,
        validTo: validTo,
        host: host,
        port: port,
      );
    } catch (e) {
      return RantiPayCertificateValidation(
        isValid: false,
        error: 'Certificate validation failed: $e',
        host: host,
        port: port,
      );
    }
  }

  /// Get certificate info for debugging
  static Map<String, dynamic> getCertificateInfo(X509Certificate certificate) {
    return {
      'fingerprint': calculateFingerprint(certificate),
      'subject': certificate.subject,
      'issuer': certificate.issuer,
      'start_validity': certificate.startValidity.toIso8601String(),
      'end_validity': certificate.endValidity.toIso8601String(),
      'sha1': certificate.sha1
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(':'),
      'der_length': certificate.der.length,
    };
  }

  /// Update certificate pins (for pin rotation)
  static Future<bool> updateCertificatePins(
    List<String> newPins, {
    required bool isProduction,
    required String updateToken,
  }) async {
    // In a real implementation, this would:
    // 1. Verify the update token
    // 2. Validate the new pins
    // 3. Securely store the new pins
    // 4. Schedule old pin removal

    // For now, just validate format
    for (final pin in newPins) {
      if (!_isValidPinFormat(pin)) {
        return false;
      }
    }

    // TODO: Implement secure pin update mechanism
    return true;
  }

  /// Validate pin format
  static bool _isValidPinFormat(String pin) {
    // Check format: sha256/base64hash=
    final regex = RegExp(r'^sha256\/[A-Za-z0-9+\/]{43}=$');
    return regex.hasMatch(pin);
  }

  /// Log pinning failure (for monitoring)
  static void _logPinningFailure(
    String host,
    int port,
    String actualFingerprint,
    List<String> expectedPins,
  ) {
    // In production, send this to monitoring service
    // Don't log sensitive details in production
    print('Certificate pinning failed for $host:$port');
  }

  /// Log pinning error
  static void _logPinningError(String host, dynamic error) {
    // In production, send this to monitoring service
    print('Certificate pinning error for $host');
  }
}

/// Certificate validation result
class RantiPayCertificateValidation {
  final bool isValid;
  final String? error;
  final String? fingerprint;
  final String? subject;
  final String? issuer;
  final DateTime? validFrom;
  final DateTime? validTo;
  final String? host;
  final int? port;

  const RantiPayCertificateValidation({
    required this.isValid,
    this.error,
    this.fingerprint,
    this.subject,
    this.issuer,
    this.validFrom,
    this.validTo,
    this.host,
    this.port,
  });

  bool get isExpired {
    if (validTo == null) return false;
    return DateTime.now().isAfter(validTo!);
  }

  bool get isNotYetValid {
    if (validFrom == null) return false;
    return DateTime.now().isBefore(validFrom!);
  }

  Duration? get remainingValidity {
    if (validTo == null) return null;
    final remaining = validTo!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'error': error,
      'fingerprint': fingerprint,
      'subject': subject,
      'issuer': issuer,
      'valid_from': validFrom?.toIso8601String(),
      'valid_to': validTo?.toIso8601String(),
      'host': host,
      'port': port,
      'is_expired': isExpired,
      'is_not_yet_valid': isNotYetValid,
      'remaining_validity_days': remainingValidity?.inDays,
    };
  }
}

/// Certificate pinning configuration
class RantiPayPinningConfig {
  final bool enabled;
  final bool enforceInProduction;
  final bool allowUserTrust;
  final Duration validationCacheDuration;
  final int maxPinAge;
  final List<String> pins;

  const RantiPayPinningConfig({
    this.enabled = true,
    this.enforceInProduction = true,
    this.allowUserTrust = false,
    this.validationCacheDuration = const Duration(hours: 24),
    this.maxPinAge = 60, // days
    required this.pins,
  });

  /// Default production configuration
  static const RantiPayPinningConfig production = RantiPayPinningConfig(
    enabled: true,
    enforceInProduction: true,
    allowUserTrust: false,
    pins: RantiPayCertificatePinning.productionPins,
  );

  /// Default staging configuration
  static const RantiPayPinningConfig staging = RantiPayPinningConfig(
    enabled: true,
    enforceInProduction: false,
    allowUserTrust: true,
    pins: RantiPayCertificatePinning.stagingPins,
  );

  /// Development configuration (pinning disabled)
  static const RantiPayPinningConfig development = RantiPayPinningConfig(
    enabled: false,
    enforceInProduction: false,
    allowUserTrust: true,
    pins: [],
  );
}
