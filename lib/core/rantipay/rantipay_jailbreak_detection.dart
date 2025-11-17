import 'dart:io';
import 'package:flutter/services.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';

/// Jailbreak/Root detection service
class RantiPayJailbreakDetection {
  static const String _channelName = 'com.rantipay/security';
  static const MethodChannel _channel = MethodChannel(_channelName);

  /// Check if device is jailbroken/rooted
  static Future<RantiPayDeviceSecurityStatus> checkDeviceSecurity() async {
    try {
      bool isJailbroken = false;
      bool isRooted = false;
      bool isDeveloperMode = false;
      bool isEmulator = false;
      bool hasHooks = false;
      bool hasSuspiciousApps = false;
      bool hasSuspiciousFiles = false;
      bool isTampered = false;
      
      // Use the jailbreak_root_detection package
      final isNotTrust = await JailbreakRootDetection.instance.isNotTrust;
      final isRealDevice = await JailbreakRootDetection.instance.isRealDevice;
      final checkForIssues = await JailbreakRootDetection.instance.checkForIssues;
      
      // Device is jailbroken/rooted if it's not trusted
      isJailbroken = isNotTrust;
      isRooted = isNotTrust;
      
      // Check if it's a real device (not emulator/simulator)
      isEmulator = !isRealDevice;
      isDeveloperMode = !isRealDevice;
      
      // Platform specific checks
      if (Platform.isAndroid) {
        try {
          // Check if app is on external storage (security risk)
          final isOnExternalStorage = await JailbreakRootDetection.instance.isOnExternalStorage;
          if (isOnExternalStorage) {
            hasSuspiciousFiles = true;
          }
        } catch (e) {
          // Handle error
        }
        
        // Additional Android checks
        final androidChecks = await _checkAndroidSecurity();
        isRooted = isRooted || androidChecks.isRooted;
        hasSuspiciousApps = androidChecks.hasSuspiciousApps;
        hasSuspiciousFiles = hasSuspiciousFiles || androidChecks.hasSuspiciousFiles;
      }
      
      if (Platform.isIOS) {
        // Check if app bundle is tampered
        const bundleId = 'com.rantipay.app'; // Replace with actual bundle ID
        try {
          isTampered = await JailbreakRootDetection.instance.isTampered(bundleId);
          if (isTampered) {
            hasHooks = true;
          }
        } catch (e) {
          // Handle error
        }
        
        // Additional iOS checks
        final iosChecks = await _checkiOSSecurity();
        isJailbroken = isJailbroken || iosChecks.isJailbroken;
        hasHooks = hasHooks || iosChecks.hasCydiaOrSileo;
        hasSuspiciousFiles = hasSuspiciousFiles || iosChecks.hasSuspiciousFiles;
      }
      
      // Process detected issues
      for (final issue in checkForIssues) {
        final issueStr = issue.toString();
        if (issueStr.contains('jailbreak') || issueStr.contains('Cydia')) {
          isJailbroken = true;
          hasHooks = true;
        }
        if (issueStr.contains('root') || issueStr.contains('su')) {
          isRooted = true;
        }
        if (issueStr.contains('suspicious')) {
          hasSuspiciousFiles = true;
        }
      }

      // Calculate security score
      int securityScore = 100;
      if (isJailbroken || isRooted) securityScore -= 50;
      if (isDeveloperMode) securityScore -= 20;
      if (isEmulator) securityScore -= 20;
      if (hasHooks) securityScore -= 10;
      if (hasSuspiciousApps) securityScore -= 10;
      if (hasSuspiciousFiles) securityScore -= 10;
      if (isTampered) securityScore -= 15;

      final riskLevel = _calculateRiskLevel(securityScore);

      return RantiPayDeviceSecurityStatus(
        isSecure: securityScore >= 70,
        isJailbroken: isJailbroken,
        isRooted: isRooted,
        isDeveloperMode: isDeveloperMode,
        isEmulator: isEmulator,
        hasHooks: hasHooks,
        hasSuspiciousApps: hasSuspiciousApps,
        hasSuspiciousFiles: hasSuspiciousFiles,
        securityScore: securityScore.clamp(0, 100),
        riskLevel: riskLevel,
        platform: Platform.operatingSystem,
        osVersion: Platform.operatingSystemVersion,
        detectedIssues: checkForIssues.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      // If detection fails, assume device is potentially compromised
      return RantiPayDeviceSecurityStatus.unknown();
    }
  }

  /// iOS specific security checks (additional)
  static Future<_iOSSecurityChecks> _checkiOSSecurity() async {
    bool isJailbroken = false;
    bool hasCydiaOrSileo = false;
    bool hasSuspiciousFiles = false;

    // Check for common jailbreak paths
    final jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Applications/Sileo.app',
      '/Applications/Zebra.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
    ];

    for (final path in jailbreakPaths) {
      if (await File(path).exists()) {
        hasSuspiciousFiles = true;
        isJailbroken = true;
        if (path.contains('Cydia') || path.contains('Sileo')) {
          hasCydiaOrSileo = true;
        }
      }
    }

    // Check if we can write to system directories
    try {
      final testFile = File('/private/test_jb.txt');
      await testFile.writeAsString('test');
      await testFile.delete();
      isJailbroken = true;
    } catch (_) {
      // Expected behavior - cannot write to system directories
    }

    return _iOSSecurityChecks(
      isJailbroken: isJailbroken,
      hasCydiaOrSileo: hasCydiaOrSileo,
      hasSuspiciousFiles: hasSuspiciousFiles,
    );
  }

  /// Android specific security checks (additional)
  static Future<_AndroidSecurityChecks> _checkAndroidSecurity() async {
    bool isRooted = false;
    bool hasSuspiciousApps = false;
    bool hasSuspiciousFiles = false;
    bool isEmulator = false;

    // Check for common root paths
    final rootPaths = [
      '/system/app/Superuser.apk',
      '/sbin/su',
      '/system/bin/su',
      '/system/xbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
      '/su/bin/su',
    ];

    for (final path in rootPaths) {
      if (await File(path).exists()) {
        hasSuspiciousFiles = true;
        isRooted = true;
      }
    }

    // Check for root apps by package name
    final rootApps = [
      'com.koushikdutta.superuser',
      'com.thirdparty.superuser',
      'eu.chainfire.supersu',
      'com.noshufou.android.su',
      'com.noshufou.android.su.elite',
      'com.yellowes.su',
      'com.topjohnwu.magisk',
      'com.kingroot.kinguser',
      'com.kingo.root',
    ];

    // Check build properties for emulator
    try {
      final result = await Process.run('getprop', ['ro.hardware']);
      if (result.exitCode == 0) {
        final hardware = result.stdout.toString().toLowerCase();
        if (hardware.contains('goldfish') || 
            hardware.contains('ranchu') ||
            hardware.contains('vbox')) {
          isEmulator = true;
        }
      }
    } catch (_) {}

    // Check for root via su command
    try {
      final result = await Process.run('su', ['-c', 'id']);
      if (result.exitCode == 0) {
        isRooted = true;
      }
    } catch (_) {}

    return _AndroidSecurityChecks(
      isRooted: isRooted,
      hasSuspiciousApps: hasSuspiciousApps,
      hasSuspiciousFiles: hasSuspiciousFiles,
      isEmulator: isEmulator,
    );
  }

  /// Calculate risk level based on security score
  static RantiPayRiskLevel _calculateRiskLevel(int securityScore) {
    if (securityScore >= 90) return RantiPayRiskLevel.low;
    if (securityScore >= 70) return RantiPayRiskLevel.medium;
    if (securityScore >= 50) return RantiPayRiskLevel.high;
    return RantiPayRiskLevel.critical;
  }

  /// Check if app should continue based on security status
  static bool shouldAllowExecution(RantiPayDeviceSecurityStatus status, {
    required int userLevel,
    bool isProduction = true,
  }) {
    // In development, allow all
    if (!isProduction) return true;

    // Critical risk - never allow
    if (status.riskLevel == RantiPayRiskLevel.critical) return false;

    // High risk - only allow for basic operations (level 1)
    if (status.riskLevel == RantiPayRiskLevel.high && userLevel > 1) return false;

    // Medium risk - allow up to level 2
    if (status.riskLevel == RantiPayRiskLevel.medium && userLevel > 2) return false;

    // Low risk - allow all levels
    return true;
  }

  /// Get security recommendations
  static List<String> getSecurityRecommendations(RantiPayDeviceSecurityStatus status) {
    final recommendations = <String>[];

    if (status.isJailbroken || status.isRooted) {
      recommendations.add('Your device appears to be jailbroken/rooted. This significantly reduces security.');
      recommendations.add('Consider using an unmodified device for financial transactions.');
    }

    if (status.isDeveloperMode) {
      recommendations.add('Developer mode is enabled. Disable it for better security.');
    }

    if (status.isEmulator) {
      recommendations.add('You are using an emulator. Real devices are more secure for financial apps.');
    }

    if (status.hasSuspiciousApps) {
      recommendations.add('Suspicious apps detected. Review and remove unauthorized apps.');
    }

    if (status.detectedIssues.isNotEmpty) {
      recommendations.add('Security issues detected: ${status.detectedIssues.join(", ")}');
    }

    if (!status.isSecure) {
      recommendations.add('Enable all security features on your device.');
      recommendations.add('Keep your operating system updated.');
      recommendations.add('Use strong authentication methods.');
    }

    return recommendations;
  }
}

/// Device security status
class RantiPayDeviceSecurityStatus {
  final bool isSecure;
  final bool isJailbroken;
  final bool isRooted;
  final bool isDeveloperMode;
  final bool isEmulator;
  final bool hasHooks;
  final bool hasSuspiciousApps;
  final bool hasSuspiciousFiles;
  final int securityScore;
  final RantiPayRiskLevel riskLevel;
  final String platform;
  final String osVersion;
  final List<String> detectedIssues;

  const RantiPayDeviceSecurityStatus({
    required this.isSecure,
    required this.isJailbroken,
    required this.isRooted,
    required this.isDeveloperMode,
    required this.isEmulator,
    required this.hasHooks,
    required this.hasSuspiciousApps,
    required this.hasSuspiciousFiles,
    required this.securityScore,
    required this.riskLevel,
    required this.platform,
    required this.osVersion,
    this.detectedIssues = const [],
  });

  factory RantiPayDeviceSecurityStatus.unknown() {
    return RantiPayDeviceSecurityStatus(
      isSecure: false,
      isJailbroken: false,
      isRooted: false,
      isDeveloperMode: false,
      isEmulator: false,
      hasHooks: false,
      hasSuspiciousApps: false,
      hasSuspiciousFiles: false,
      securityScore: 0,
      riskLevel: RantiPayRiskLevel.unknown,
      platform: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      detectedIssues: [],
    );
  }

  bool get isCompromised => isJailbroken || isRooted;
  bool get hasRisks => !isSecure || securityScore < 70;
}

/// Risk levels
enum RantiPayRiskLevel {
  low,      // 90-100 score
  medium,   // 70-89 score
  high,     // 50-69 score
  critical, // 0-49 score
  unknown,  // Cannot determine
}

/// iOS security check results
class _iOSSecurityChecks {
  final bool isJailbroken;
  final bool hasCydiaOrSileo;
  final bool hasSuspiciousFiles;

  const _iOSSecurityChecks({
    required this.isJailbroken,
    required this.hasCydiaOrSileo,
    required this.hasSuspiciousFiles,
  });
}

/// Android security check results
class _AndroidSecurityChecks {
  final bool isRooted;
  final bool hasSuspiciousApps;
  final bool hasSuspiciousFiles;
  final bool isEmulator;

  const _AndroidSecurityChecks({
    required this.isRooted,
    required this.hasSuspiciousApps,
    required this.hasSuspiciousFiles,
    required this.isEmulator,
  });
}