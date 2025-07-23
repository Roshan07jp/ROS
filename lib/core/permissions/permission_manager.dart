import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../platform/platform_service.dart';
import '../error_handling/error_handler.dart';

enum PermissionType {
  // Storage permissions
  storage,
  manageExternalStorage,
  
  // Network permissions
  internet,
  accessNetworkState,
  accessWifiState,
  
  // Camera and media
  camera,
  microphone,
  photos,
  videos,
  
  // Location
  location,
  locationWhenInUse,
  locationAlways,
  
  // Device features
  bluetooth,
  bluetoothScan,
  bluetoothConnect,
  bluetoothAdvertise,
  nfc,
  
  // System features
  systemAlertWindow,
  modifyAudioSettings,
  wakeLock,
  vibrate,
  
  // Biometric
  biometric,
  
  // Notification
  notification,
  
  // App-specific
  installUnknownApps,
  requestIgnoreBatteryOptimizations,
  
  // Terminal specific
  terminalAccess,
  rootAccess,
  
  // File system
  readExternalStorage,
  writeExternalStorage,
  
  // Advanced
  backgroundApp,
  criticalAlerts,
  speech,
  
  // Platform specific
  windowsFileSystem,
  macosFileSystem,
  linuxFileSystem,
  webLocalStorage,
  webNotifications,
  webCamera,
  webMicrophone,
}

enum PermissionStatus {
  granted,
  denied,
  restricted,
  limited,
  provisional,
  permanentlyDenied,
  notSupported,
  unknown,
}

class PermissionInfo {
  final PermissionType type;
  final String name;
  final String description;
  final String rationale;
  final bool isRequired;
  final bool isRequestedOnStartup;
  final List<PlatformType> supportedPlatforms;
  final PermissionStatus status;

  const PermissionInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.rationale,
    required this.isRequired,
    required this.isRequestedOnStartup,
    required this.supportedPlatforms,
    this.status = PermissionStatus.unknown,
  });

  PermissionInfo copyWith({PermissionStatus? status}) {
    return PermissionInfo(
      type: type,
      name: name,
      description: description,
      rationale: rationale,
      isRequired: isRequired,
      isRequestedOnStartup: isRequestedOnStartup,
      supportedPlatforms: supportedPlatforms,
      status: status ?? this.status,
    );
  }
}

class PermissionManager {
  static final Map<PermissionType, PermissionInfo> _permissions = {
    // Storage permissions
    PermissionType.storage: const PermissionInfo(
      type: PermissionType.storage,
      name: 'Storage Access',
      description: 'Access device storage to save and load files',
      rationale: 'Required to save terminal scripts, logs, and configurations',
      isRequired: true,
      isRequestedOnStartup: true,
      supportedPlatforms: [
        PlatformType.androidPhone,
        PlatformType.androidTablet,
      ],
    ),
    
    PermissionType.camera: const PermissionInfo(
      type: PermissionType.camera,
      name: 'Camera Access',
      description: 'Access camera for QR code scanning and image capture',
      rationale: 'Used for scanning QR codes for SSH keys and configurations',
      isRequired: false,
      isRequestedOnStartup: false,
      supportedPlatforms: [
        PlatformType.androidPhone,
        PlatformType.androidTablet,
        PlatformType.iPhone,
        PlatformType.iPad,
        PlatformType.webDesktop,
        PlatformType.webMobile,
        PlatformType.webTablet,
      ],
    ),
    
    PermissionType.microphone: const PermissionInfo(
      type: PermissionType.microphone,
      name: 'Microphone Access',
      description: 'Access microphone for voice commands',
      rationale: 'Enables voice-to-text terminal commands and AI interaction',
      isRequired: false,
      isRequestedOnStartup: false,
      supportedPlatforms: [
        PlatformType.androidPhone,
        PlatformType.androidTablet,
        PlatformType.iPhone,
        PlatformType.iPad,
        PlatformType.windowsPC,
        PlatformType.windowsLaptop,
        PlatformType.macBookPro,
        PlatformType.macBookAir,
        PlatformType.iMac,
        PlatformType.linuxPC,
        PlatformType.linuxLaptop,
        PlatformType.webDesktop,
        PlatformType.webMobile,
        PlatformType.webTablet,
      ],
    ),
    
    PermissionType.notification: const PermissionInfo(
      type: PermissionType.notification,
      name: 'Notifications',
      description: 'Show notifications for terminal alerts and system events',
      rationale: 'Notify about command completion, errors, and system events',
      isRequired: false,
      isRequestedOnStartup: true,
      supportedPlatforms: [
        PlatformType.androidPhone,
        PlatformType.androidTablet,
        PlatformType.iPhone,
        PlatformType.iPad,
        PlatformType.windowsPC,
        PlatformType.windowsLaptop,
        PlatformType.macBookPro,
        PlatformType.macBookAir,
        PlatformType.iMac,
        PlatformType.linuxPC,
        PlatformType.linuxLaptop,
        PlatformType.webDesktop,
        PlatformType.webMobile,
        PlatformType.webTablet,
      ],
    ),
    
    PermissionType.bluetooth: const PermissionInfo(
      type: PermissionType.bluetooth,
      name: 'Bluetooth Access',
      description: 'Access Bluetooth for device communication',
      rationale: 'Connect to external keyboards, mice, and IoT devices',
      isRequired: false,
      isRequestedOnStartup: false,
      supportedPlatforms: [
        PlatformType.androidPhone,
        PlatformType.androidTablet,
        PlatformType.iPhone,
        PlatformType.iPad,
        PlatformType.windowsPC,
        PlatformType.windowsLaptop,
        PlatformType.macBookPro,
        PlatformType.macBookAir,
        PlatformType.iMac,
        PlatformType.linuxPC,
        PlatformType.linuxLaptop,
      ],
    ),
    
    PermissionType.location: const PermissionInfo(
      type: PermissionType.location,
      name: 'Location Access',
      description: 'Access device location for network analysis',
      rationale: 'Enhance network scanning with location-based information',
      isRequired: false,
      isRequestedOnStartup: false,
      supportedPlatforms: [
        PlatformType.androidPhone,
        PlatformType.androidTablet,
        PlatformType.iPhone,
        PlatformType.iPad,
        PlatformType.webMobile,
        PlatformType.webTablet,
        PlatformType.webDesktop,
      ],
    ),
    
    PermissionType.biometric: const PermissionInfo(
      type: PermissionType.biometric,
      name: 'Biometric Authentication',
      description: 'Use fingerprint or face recognition for security',
      rationale: 'Secure access to sensitive terminal operations and settings',
      isRequired: false,
      isRequestedOnStartup: false,
      supportedPlatforms: [
        PlatformType.androidPhone,
        PlatformType.androidTablet,
        PlatformType.iPhone,
        PlatformType.iPad,
        PlatformType.windowsPC,
        PlatformType.windowsLaptop,
        PlatformType.macBookPro,
        PlatformType.macBookAir,
        PlatformType.iMac,
      ],
    ),
    
    // Web-specific permissions
    PermissionType.webLocalStorage: const PermissionInfo(
      type: PermissionType.webLocalStorage,
      name: 'Local Storage',
      description: 'Store data locally in the browser',
      rationale: 'Save terminal history and user preferences',
      isRequired: true,
      isRequestedOnStartup: true,
      supportedPlatforms: [
        PlatformType.webDesktop,
        PlatformType.webMobile,
        PlatformType.webTablet,
      ],
    ),
    
    PermissionType.webNotifications: const PermissionInfo(
      type: PermissionType.webNotifications,
      name: 'Web Notifications',
      description: 'Show browser notifications',
      rationale: 'Notify about terminal events and system alerts',
      isRequired: false,
      isRequestedOnStartup: false,
      supportedPlatforms: [
        PlatformType.webDesktop,
        PlatformType.webMobile,
        PlatformType.webTablet,
      ],
    ),
    
    // Platform-specific file system access
    PermissionType.windowsFileSystem: const PermissionInfo(
      type: PermissionType.windowsFileSystem,
      name: 'Windows File System',
      description: 'Access Windows file system',
      rationale: 'Read and write files for terminal operations',
      isRequired: true,
      isRequestedOnStartup: true,
      supportedPlatforms: [
        PlatformType.windowsPC,
        PlatformType.windowsLaptop,
      ],
    ),
    
    PermissionType.macosFileSystem: const PermissionInfo(
      type: PermissionType.macosFileSystem,
      name: 'macOS File System',
      description: 'Access macOS file system',
      rationale: 'Read and write files for terminal operations',
      isRequired: true,
      isRequestedOnStartup: true,
      supportedPlatforms: [
        PlatformType.macBookPro,
        PlatformType.macBookAir,
        PlatformType.iMac,
      ],
    ),
    
    PermissionType.linuxFileSystem: const PermissionInfo(
      type: PermissionType.linuxFileSystem,
      name: 'Linux File System',
      description: 'Access Linux file system',
      rationale: 'Read and write files for terminal operations',
      isRequired: true,
      isRequestedOnStartup: true,
      supportedPlatforms: [
        PlatformType.linuxPC,
        PlatformType.linuxLaptop,
      ],
    ),
  };

  // Get platform-specific permissions
  static Future<List<PermissionInfo>> getRequiredPermissions() async {
    final platform = await PlatformService.getPlatformInfo();
    final permissions = <PermissionInfo>[];
    
    for (final permission in _permissions.values) {
      if (permission.supportedPlatforms.contains(platform.type)) {
        permissions.add(permission);
      }
    }
    
    return permissions;
  }

  static Future<List<PermissionInfo>> getStartupPermissions() async {
    final platform = await PlatformService.getPlatformInfo();
    final permissions = <PermissionInfo>[];
    
    for (final permission in _permissions.values) {
      if (permission.supportedPlatforms.contains(platform.type) && 
          permission.isRequestedOnStartup) {
        permissions.add(permission);
      }
    }
    
    return permissions;
  }

  // Permission status checking
  static Future<PermissionStatus> checkPermission(PermissionType type) async {
    try {
      if (kIsWeb) {
        return await _checkWebPermission(type);
      }
      
      final permission = _getSystemPermission(type);
      if (permission == null) {
        return PermissionStatus.notSupported;
      }
      
      final status = await permission.status;
      return _convertPermissionStatus(status);
    } catch (e) {
      ErrorHandler.reportException(
        e,
        context: 'Checking permission: $type',
        category: ErrorCategory.permission,
      );
      return PermissionStatus.unknown;
    }
  }

  static Future<PermissionStatus> _checkWebPermission(PermissionType type) async {
    switch (type) {
      case PermissionType.webLocalStorage:
        // Always available in modern browsers
        return PermissionStatus.granted;
      case PermissionType.webNotifications:
        // Check notification permission via browser API
        return PermissionStatus.granted; // Simplified
      case PermissionType.webCamera:
      case PermissionType.webMicrophone:
        // These require user interaction to check
        return PermissionStatus.denied; // Default state
      default:
        return PermissionStatus.notSupported;
    }
  }

  // Permission requesting
  static Future<PermissionStatus> requestPermission(PermissionType type) async {
    try {
      if (kIsWeb) {
        return await _requestWebPermission(type);
      }
      
      final permission = _getSystemPermission(type);
      if (permission == null) {
        return PermissionStatus.notSupported;
      }
      
      final status = await permission.request();
      return _convertPermissionStatus(status);
    } catch (e) {
      ErrorHandler.reportException(
        e,
        context: 'Requesting permission: $type',
        category: ErrorCategory.permission,
      );
      return PermissionStatus.unknown;
    }
  }

  static Future<PermissionStatus> _requestWebPermission(PermissionType type) async {
    switch (type) {
      case PermissionType.webNotifications:
        // Request notification permission via browser API
        return PermissionStatus.granted; // Simplified
      case PermissionType.webCamera:
      case PermissionType.webMicrophone:
        // These are requested when accessing media
        return PermissionStatus.granted; // Simplified
      default:
        return PermissionStatus.notSupported;
    }
  }

  // Batch permission operations
  static Future<Map<PermissionType, PermissionStatus>> checkMultiplePermissions(
    List<PermissionType> types,
  ) async {
    final results = <PermissionType, PermissionStatus>{};
    
    for (final type in types) {
      results[type] = await checkPermission(type);
    }
    
    return results;
  }

  static Future<Map<PermissionType, PermissionStatus>> requestMultiplePermissions(
    List<PermissionType> types,
  ) async {
    final results = <PermissionType, PermissionStatus>{};
    
    if (kIsWeb) {
      // Handle web permissions individually
      for (final type in types) {
        results[type] = await requestPermission(type);
      }
    } else {
      // Convert to system permissions and request together
      final systemPermissions = <Permission>[];
      final typeMapping = <Permission, PermissionType>{};
      
      for (final type in types) {
        final permission = _getSystemPermission(type);
        if (permission != null) {
          systemPermissions.add(permission);
          typeMapping[permission] = type;
        } else {
          results[type] = PermissionStatus.notSupported;
        }
      }
      
      if (systemPermissions.isNotEmpty) {
        final statuses = await systemPermissions.request();
        for (final entry in statuses.entries) {
          final type = typeMapping[entry.key];
          if (type != null) {
            results[type] = _convertPermissionStatus(entry.value);
          }
        }
      }
    }
    
    return results;
  }

  // Permission utilities
  static Future<bool> shouldShowRationale(PermissionType type) async {
    if (kIsWeb) return false;
    
    final permission = _getSystemPermission(type);
    if (permission == null) return false;
    
    return await permission.shouldShowRequestRationale;
  }

  static Future<void> openAppSettings() async {
    if (!kIsWeb) {
      await openAppSettings();
    }
  }

  static PermissionInfo? getPermissionInfo(PermissionType type) {
    return _permissions[type];
  }

  static List<PermissionInfo> getAllPermissions() {
    return _permissions.values.toList();
  }

  // Helper methods
  static Permission? _getSystemPermission(PermissionType type) {
    switch (type) {
      case PermissionType.storage:
        return Permission.storage;
      case PermissionType.camera:
        return Permission.camera;
      case PermissionType.microphone:
        return Permission.microphone;
      case PermissionType.location:
        return Permission.location;
      case PermissionType.locationWhenInUse:
        return Permission.locationWhenInUse;
      case PermissionType.locationAlways:
        return Permission.locationAlways;
      case PermissionType.bluetooth:
        return Permission.bluetooth;
      case PermissionType.bluetoothScan:
        return Permission.bluetoothScan;
      case PermissionType.bluetoothConnect:
        return Permission.bluetoothConnect;
      case PermissionType.bluetoothAdvertise:
        return Permission.bluetoothAdvertise;
      case PermissionType.notification:
        return Permission.notification;
      case PermissionType.photos:
        return Permission.photos;
      case PermissionType.videos:
        return Permission.videos;
      case PermissionType.speech:
        return Permission.speech;
      case PermissionType.criticalAlerts:
        return Permission.criticalAlerts;
      default:
        return null;
    }
  }

  static PermissionStatus _convertPermissionStatus(Permission status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionStatus.granted;
      case PermissionStatus.denied:
        return PermissionStatus.denied;
      case PermissionStatus.restricted:
        return PermissionStatus.restricted;
      case PermissionStatus.limited:
        return PermissionStatus.limited;
      case PermissionStatus.provisional:
        return PermissionStatus.provisional;
      case PermissionStatus.permanentlyDenied:
        return PermissionStatus.permanentlyDenied;
      default:
        return PermissionStatus.unknown;
    }
  }

  // Platform-specific permission checks
  static Future<bool> hasTerminalAccess() async {
    final platform = await PlatformService.getPlatformInfo();
    
    switch (platform.type) {
      case PlatformType.androidPhone:
      case PlatformType.androidTablet:
        return await PlatformService.hasRootAccess();
      case PlatformType.iPhone:
      case PlatformType.iPad:
        // iOS has limited terminal access
        return false;
      case PlatformType.windowsPC:
      case PlatformType.windowsLaptop:
      case PlatformType.macBookPro:
      case PlatformType.macBookAir:
      case PlatformType.iMac:
      case PlatformType.linuxPC:
      case PlatformType.linuxLaptop:
        return true;
      case PlatformType.webMobile:
      case PlatformType.webTablet:
      case PlatformType.webDesktop:
        return false; // Web-based terminal simulation only
      default:
        return false;
    }
  }

  static Future<bool> hasFileSystemAccess() async {
    final platform = await PlatformService.getPlatformInfo();
    
    if (platform.isWeb) {
      return false; // Limited file system access
    }
    
    final storageStatus = await checkPermission(PermissionType.storage);
    return storageStatus == PermissionStatus.granted;
  }

  static Future<bool> hasNetworkAccess() async {
    // Network access is usually granted by default
    return true;
  }

  // Initialize permissions on app startup
  static Future<Map<PermissionType, PermissionStatus>> initializePermissions() async {
    final startupPermissions = await getStartupPermissions();
    final permissionTypes = startupPermissions.map((p) => p.type).toList();
    
    if (permissionTypes.isEmpty) {
      return {};
    }
    
    return await requestMultiplePermissions(permissionTypes);
  }
}

// Riverpod providers
final permissionManagerProvider = Provider<PermissionManager>((ref) {
  return PermissionManager();
});

final permissionStatusProvider = 
    StateNotifierProvider<PermissionStatusNotifier, Map<PermissionType, PermissionStatus>>((ref) {
  return PermissionStatusNotifier();
});

class PermissionStatusNotifier extends StateNotifier<Map<PermissionType, PermissionStatus>> {
  PermissionStatusNotifier() : super({});

  Future<void> checkPermission(PermissionType type) async {
    final status = await PermissionManager.checkPermission(type);
    state = {...state, type: status};
  }

  Future<void> requestPermission(PermissionType type) async {
    final status = await PermissionManager.requestPermission(type);
    state = {...state, type: status};
  }

  Future<void> checkAllPermissions() async {
    final permissions = await PermissionManager.getRequiredPermissions();
    final types = permissions.map((p) => p.type).toList();
    final statuses = await PermissionManager.checkMultiplePermissions(types);
    state = {...state, ...statuses};
  }

  Future<void> initializePermissions() async {
    final statuses = await PermissionManager.initializePermissions();
    state = {...state, ...statuses};
  }
}