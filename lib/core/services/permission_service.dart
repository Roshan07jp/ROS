import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_constants.dart';

class PermissionService {
  static PermissionService? _instance;
  static PermissionService get instance => _instance ??= PermissionService._();
  PermissionService._();

  // Request initial permissions needed for the app
  static Future<bool> requestInitialPermissions() async {
    try {
      debugPrint('Requesting initial permissions...');

      // Request storage permissions for file operations
      final storageStatus = await Permission.storage.request();
      final externalStorageStatus = await Permission.manageExternalStorage.request();

      // Request other optional permissions
      await _requestOptionalPermissions();

      final hasBasicPermissions = storageStatus.isGranted || storageStatus.isLimited;
      
      debugPrint('Initial permissions status: $hasBasicPermissions');
      return hasBasicPermissions;
    } catch (e) {
      debugPrint('Failed to request permissions: $e');
      return false;
    }
  }

  static Future<void> _requestOptionalPermissions() async {
    try {
      // Request camera permission for QR code scanning
      await Permission.camera.request();
      
      // Request microphone permission for voice commands (future feature)
      await Permission.microphone.request();
      
      // Request notification permission
      await Permission.notification.request();
      
      // Request location permission for network scanning
      await Permission.location.request();
    } catch (e) {
      debugPrint('Failed to request optional permissions: $e');
    }
  }

  // Check if specific permission is granted
  static Future<bool> hasPermission(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Failed to check permission ${permission.toString()}: $e');
      return false;
    }
  }

  // Request specific permission
  static Future<bool> requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Failed to request permission ${permission.toString()}: $e');
      return false;
    }
  }

  // Check storage permission
  static Future<bool> hasStoragePermission() async {
    return await hasPermission(Permission.storage);
  }

  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    return await requestPermission(Permission.storage);
  }

  // Check camera permission
  static Future<bool> hasCameraPermission() async {
    return await hasPermission(Permission.camera);
  }

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    return await requestPermission(Permission.camera);
  }

  // Check microphone permission
  static Future<bool> hasMicrophonePermission() async {
    return await hasPermission(Permission.microphone);
  }

  // Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    return await requestPermission(Permission.microphone);
  }

  // Check location permission
  static Future<bool> hasLocationPermission() async {
    return await hasPermission(Permission.location);
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    return await requestPermission(Permission.location);
  }

  // Check notification permission
  static Future<bool> hasNotificationPermission() async {
    return await hasPermission(Permission.notification);
  }

  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    return await requestPermission(Permission.notification);
  }

  // Get all permission statuses
  static Future<Map<Permission, PermissionStatus>> getAllPermissionStatuses() async {
    final permissions = [
      Permission.storage,
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.notification,
    ];

    final statuses = <Permission, PermissionStatus>{};
    
    for (final permission in permissions) {
      try {
        statuses[permission] = await permission.status;
      } catch (e) {
        debugPrint('Failed to get status for permission ${permission.toString()}: $e');
        statuses[permission] = PermissionStatus.denied;
      }
    }

    return statuses;
  }

  // Check if all required permissions are granted
  static Future<bool> hasAllRequiredPermissions() async {
    try {
      final storageGranted = await hasStoragePermission();
      
      // Add other required permissions here
      return storageGranted;
    } catch (e) {
      debugPrint('Failed to check required permissions: $e');
      return false;
    }
  }

  // Request all required permissions
  static Future<bool> requestAllRequiredPermissions() async {
    try {
      final storageGranted = await requestStoragePermission();
      
      // Add other required permissions here
      return storageGranted;
    } catch (e) {
      debugPrint('Failed to request required permissions: $e');
      return false;
    }
  }

  // Open app settings
  static Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('Failed to open app settings: $e');
      return false;
    }
  }

  // Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      debugPrint('Failed to check if permission is permanently denied: $e');
      return false;
    }
  }

  // Get permission status text
  static String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
  }

  // Get permission importance text
  static String getPermissionImportanceText(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return 'Required for file operations, script saving, and data storage';
      case Permission.camera:
        return 'Optional for QR code scanning and SSH key sharing';
      case Permission.microphone:
        return 'Optional for voice commands (future feature)';
      case Permission.location:
        return 'Optional for network scanning and location-based features';
      case Permission.notification:
        return 'Optional for background process notifications';
      default:
        return 'Used for enhanced app functionality';
    }
  }

  // Get permission icon
  static String getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return '📁';
      case Permission.camera:
        return '📷';
      case Permission.microphone:
        return '🎤';
      case Permission.location:
        return '📍';
      case Permission.notification:
        return '🔔';
      default:
        return '⚙️';
    }
  }

  // Check and request permissions with user explanation
  static Future<bool> checkAndRequestPermissionWithExplanation(
    Permission permission,
    String title,
    String explanation,
  ) async {
    try {
      // Check current status
      final status = await permission.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        debugPrint('Permission $permission is permanently denied. User needs to enable it manually.');
        return false;
      }

      // Request permission
      final newStatus = await permission.request();
      return newStatus.isGranted;
    } catch (e) {
      debugPrint('Failed to check and request permission: $e');
      return false;
    }
  }

  // Get permission summary for settings screen
  static Future<Map<String, dynamic>> getPermissionSummary() async {
    final statuses = await getAllPermissionStatuses();
    
    int granted = 0;
    int total = statuses.length;
    
    for (final status in statuses.values) {
      if (status.isGranted) {
        granted++;
      }
    }

    return {
      'granted': granted,
      'total': total,
      'percentage': total > 0 ? (granted / total * 100).round() : 0,
      'statuses': statuses,
    };
  }
}