import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlatformType {
  androidPhone,
  androidTablet,
  iPhone,
  iPad,
  windowsPC,
  windowsLaptop,
  macBookPro,
  macBookAir,
  iMac,
  linuxPC,
  linuxLaptop,
  webMobile,
  webTablet,
  webDesktop,
  unknown
}

class PlatformInfo {
  final PlatformType type;
  final String name;
  final String version;
  final bool isDesktop;
  final bool isMobile;
  final bool isTablet;
  final bool isWeb;
  final bool supportsTerminal;
  final bool supportsFileSystem;
  final bool supportsNotifications;
  final Map<String, dynamic> capabilities;

  const PlatformInfo({
    required this.type,
    required this.name,
    required this.version,
    required this.isDesktop,
    required this.isMobile,
    required this.isTablet,
    required this.isWeb,
    required this.supportsTerminal,
    required this.supportsFileSystem,
    required this.supportsNotifications,
    required this.capabilities,
  });
}

class PlatformService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  // Platform Detection
  static Future<PlatformInfo> getPlatformInfo() async {
    if (kIsWeb) {
      return await _getWebPlatformInfo();
    } else if (Platform.isAndroid) {
      return await _getAndroidPlatformInfo();
    } else if (Platform.isIOS) {
      return await _getIOSPlatformInfo();
    } else if (Platform.isWindows) {
      return await _getWindowsPlatformInfo();
    } else if (Platform.isMacOS) {
      return await _getMacOSPlatformInfo();
    } else if (Platform.isLinux) {
      return await _getLinuxPlatformInfo();
    } else {
      return _getUnknownPlatformInfo();
    }
  }

  static Future<PlatformInfo> _getWebPlatformInfo() async {
    final webInfo = await _deviceInfo.webBrowserInfo;
    final userAgent = webInfo.userAgent ?? '';
    
    PlatformType type;
    bool isMobile = false;
    bool isTablet = false;
    
    if (userAgent.contains('Mobile') || userAgent.contains('Android') && !userAgent.contains('Tablet')) {
      type = PlatformType.webMobile;
      isMobile = true;
    } else if (userAgent.contains('Tablet') || userAgent.contains('iPad')) {
      type = PlatformType.webTablet;
      isTablet = true;
    } else {
      type = PlatformType.webDesktop;
    }

    return PlatformInfo(
      type: type,
      name: '${webInfo.browserName} ${webInfo.appVersion}',
      version: webInfo.appVersion ?? 'Unknown',
      isDesktop: type == PlatformType.webDesktop,
      isMobile: isMobile,
      isTablet: isTablet,
      isWeb: true,
      supportsTerminal: true,
      supportsFileSystem: false, // Limited in web
      supportsNotifications: true,
      capabilities: {
        'browserName': webInfo.browserName,
        'userAgent': userAgent,
        'platform': webInfo.platform,
        'webGL': true,
        'localStorage': true,
        'webSockets': true,
      },
    );
  }

  static Future<PlatformInfo> _getAndroidPlatformInfo() async {
    final androidInfo = await _deviceInfo.androidInfo;
    final isTablet = _isAndroidTablet(androidInfo);
    
    return PlatformInfo(
      type: isTablet ? PlatformType.androidTablet : PlatformType.androidPhone,
      name: '${androidInfo.manufacturer} ${androidInfo.model}',
      version: 'Android ${androidInfo.version.release}',
      isDesktop: false,
      isMobile: !isTablet,
      isTablet: isTablet,
      isWeb: false,
      supportsTerminal: true,
      supportsFileSystem: true,
      supportsNotifications: true,
      capabilities: {
        'manufacturer': androidInfo.manufacturer,
        'model': androidInfo.model,
        'androidVersion': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
        'supportedAbis': androidInfo.supportedAbis,
        'hasTermux': true,
        'hasRoot': false, // Will be detected separately
      },
    );
  }

  static Future<PlatformInfo> _getIOSPlatformInfo() async {
    final iosInfo = await _deviceInfo.iosInfo;
    final isTablet = iosInfo.model.toLowerCase().contains('ipad');
    
    return PlatformInfo(
      type: isTablet ? PlatformType.iPad : PlatformType.iPhone,
      name: '${iosInfo.name} (${iosInfo.model})',
      version: 'iOS ${iosInfo.systemVersion}',
      isDesktop: false,
      isMobile: !isTablet,
      isTablet: isTablet,
      isWeb: false,
      supportsTerminal: true, // Limited but supported
      supportsFileSystem: true, // Sandboxed
      supportsNotifications: true,
      capabilities: {
        'model': iosInfo.model,
        'systemVersion': iosInfo.systemVersion,
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
        'identifierForVendor': iosInfo.identifierForVendor,
        'hasJailbreak': false, // Will be detected separately
        'sandboxed': true,
      },
    );
  }

  static Future<PlatformInfo> _getWindowsPlatformInfo() async {
    final windowsInfo = await _deviceInfo.windowsInfo;
    final isLaptop = _isWindowsLaptop();
    
    return PlatformInfo(
      type: isLaptop ? PlatformType.windowsLaptop : PlatformType.windowsPC,
      name: windowsInfo.computerName,
      version: '${windowsInfo.productName} ${windowsInfo.displayVersion}',
      isDesktop: true,
      isMobile: false,
      isTablet: false,
      isWeb: false,
      supportsTerminal: true,
      supportsFileSystem: true,
      supportsNotifications: true,
      capabilities: {
        'computerName': windowsInfo.computerName,
        'numberOfCores': windowsInfo.numberOfCores,
        'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
        'productName': windowsInfo.productName,
        'hasWSL': true, // Windows Subsystem for Linux
        'hasPowerShell': true,
        'hasCommandPrompt': true,
      },
    );
  }

  static Future<PlatformInfo> _getMacOSPlatformInfo() async {
    final macInfo = await _deviceInfo.macOsInfo;
    final isMacBook = _isMacBook(macInfo);
    
    PlatformType type;
    if (isMacBook) {
      type = macInfo.model.contains('Air') ? PlatformType.macBookAir : PlatformType.macBookPro;
    } else {
      type = PlatformType.iMac;
    }
    
    return PlatformInfo(
      type: type,
      name: '${macInfo.model} (${macInfo.hostName})',
      version: 'macOS ${macInfo.osRelease}',
      isDesktop: true,
      isMobile: false,
      isTablet: false,
      isWeb: false,
      supportsTerminal: true,
      supportsFileSystem: true,
      supportsNotifications: true,
      capabilities: {
        'model': macInfo.model,
        'hostName': macInfo.hostName,
        'osRelease': macInfo.osRelease,
        'kernelVersion': macInfo.kernelVersion,
        'hasTerminal': true,
        'hasBrew': true,
        'hasZsh': true,
      },
    );
  }

  static Future<PlatformInfo> _getLinuxPlatformInfo() async {
    final linuxInfo = await _deviceInfo.linuxInfo;
    final isLaptop = _isLinuxLaptop();
    
    return PlatformInfo(
      type: isLaptop ? PlatformType.linuxLaptop : PlatformType.linuxPC,
      name: '${linuxInfo.name} ${linuxInfo.version}',
      version: linuxInfo.versionId ?? 'Unknown',
      isDesktop: true,
      isMobile: false,
      isTablet: false,
      isWeb: false,
      supportsTerminal: true,
      supportsFileSystem: true,
      supportsNotifications: true,
      capabilities: {
        'name': linuxInfo.name,
        'version': linuxInfo.version,
        'id': linuxInfo.id,
        'prettyName': linuxInfo.prettyName,
        'hasSystemd': true,
        'hasBash': true,
        'hasApt': linuxInfo.id == 'ubuntu',
        'hasYum': linuxInfo.id == 'rhel',
        'hasSnap': true,
      },
    );
  }

  static PlatformInfo _getUnknownPlatformInfo() {
    return const PlatformInfo(
      type: PlatformType.unknown,
      name: 'Unknown Platform',
      version: 'Unknown',
      isDesktop: false,
      isMobile: false,
      isTablet: false,
      isWeb: false,
      supportsTerminal: false,
      supportsFileSystem: false,
      supportsNotifications: false,
      capabilities: {},
    );
  }

  // Helper methods for device detection
  static bool _isAndroidTablet(AndroidDeviceInfo info) {
    // Check if it's a tablet based on screen size and density
    // This is a simplified check - in reality, you'd use display metrics
    final model = info.model.toLowerCase();
    return model.contains('tablet') || 
           model.contains('tab ') ||
           model.contains('pad') ||
           info.model.contains('SM-T'); // Samsung tablets
  }

  static bool _isWindowsLaptop() {
    // In a real implementation, you'd check system info
    // For now, assume it's a laptop if battery is present
    return true; // Simplified
  }

  static bool _isMacBook(MacOsDeviceInfo info) {
    final model = info.model.toLowerCase();
    return model.contains('macbook');
  }

  static bool _isLinuxLaptop() {
    // Check for laptop indicators like battery presence
    return true; // Simplified
  }

  // Platform-specific methods
  static Future<bool> hasRootAccess() async {
    if (Platform.isAndroid) {
      try {
        final result = await Process.run('su', ['-c', 'id']);
        return result.exitCode == 0;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  static Future<bool> canRunTerminal() async {
    final platform = await getPlatformInfo();
    return platform.supportsTerminal;
  }

  static Future<Map<String, String>> getEnvironmentVariables() async {
    if (kIsWeb) {
      return {
        'PLATFORM': 'web',
        'USER_AGENT': 'web-browser',
      };
    }
    return Platform.environment;
  }

  static Future<String> getDefaultShell() async {
    final platform = await getPlatformInfo();
    
    switch (platform.type) {
      case PlatformType.androidPhone:
      case PlatformType.androidTablet:
        return '/system/bin/sh';
      case PlatformType.iPhone:
      case PlatformType.iPad:
        return '/bin/sh'; // Limited
      case PlatformType.windowsPC:
      case PlatformType.windowsLaptop:
        return 'cmd.exe';
      case PlatformType.macBookPro:
      case PlatformType.macBookAir:
      case PlatformType.iMac:
        return '/bin/zsh';
      case PlatformType.linuxPC:
      case PlatformType.linuxLaptop:
        return '/bin/bash';
      case PlatformType.webMobile:
      case PlatformType.webTablet:
      case PlatformType.webDesktop:
        return 'web-terminal';
      default:
        return '/bin/sh';
    }
  }

  // Performance optimization based on platform
  static Map<String, dynamic> getOptimalSettings(PlatformType platform) {
    switch (platform) {
      case PlatformType.androidPhone:
        return {
          'maxTerminalSessions': 3,
          'historySize': 1000,
          'enableAnimations': true,
          'fontSize': 14.0,
        };
      case PlatformType.androidTablet:
        return {
          'maxTerminalSessions': 5,
          'historySize': 2000,
          'enableAnimations': true,
          'fontSize': 16.0,
        };
      case PlatformType.iPhone:
        return {
          'maxTerminalSessions': 2,
          'historySize': 500,
          'enableAnimations': true,
          'fontSize': 12.0,
        };
      case PlatformType.iPad:
        return {
          'maxTerminalSessions': 4,
          'historySize': 1500,
          'enableAnimations': true,
          'fontSize': 16.0,
        };
      case PlatformType.windowsPC:
      case PlatformType.windowsLaptop:
      case PlatformType.macBookPro:
      case PlatformType.macBookAir:
      case PlatformType.iMac:
      case PlatformType.linuxPC:
      case PlatformType.linuxLaptop:
        return {
          'maxTerminalSessions': 10,
          'historySize': 5000,
          'enableAnimations': true,
          'fontSize': 14.0,
        };
      case PlatformType.webMobile:
        return {
          'maxTerminalSessions': 2,
          'historySize': 500,
          'enableAnimations': false, // Better performance
          'fontSize': 12.0,
        };
      case PlatformType.webTablet:
        return {
          'maxTerminalSessions': 3,
          'historySize': 1000,
          'enableAnimations': true,
          'fontSize': 14.0,
        };
      case PlatformType.webDesktop:
        return {
          'maxTerminalSessions': 8,
          'historySize': 3000,
          'enableAnimations': true,
          'fontSize': 14.0,
        };
      default:
        return {
          'maxTerminalSessions': 1,
          'historySize': 100,
          'enableAnimations': false,
          'fontSize': 12.0,
        };
    }
  }
}

// Riverpod providers
final platformServiceProvider = Provider<PlatformService>((ref) {
  return PlatformService();
});

final platformInfoProvider = FutureProvider<PlatformInfo>((ref) async {
  return await PlatformService.getPlatformInfo();
});

final platformCapabilitiesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final platform = await PlatformService.getPlatformInfo();
  return PlatformService.getOptimalSettings(platform.type);
});