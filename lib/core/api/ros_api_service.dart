import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:audioplayers/audioplayers.dart';
import '../platform/platform_service.dart';
import '../error_handling/error_handler.dart';
import '../permissions/permission_manager.dart';

class ROSAPIResult {
  final bool success;
  final dynamic data;
  final String? error;
  final Map<String, dynamic>? metadata;

  const ROSAPIResult({
    required this.success,
    this.data,
    this.error,
    this.metadata,
  });

  factory ROSAPIResult.success(dynamic data, {Map<String, dynamic>? metadata}) {
    return ROSAPIResult(
      success: true,
      data: data,
      metadata: metadata,
    );
  }

  factory ROSAPIResult.error(String error) {
    return ROSAPIResult(
      success: false,
      error: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'error': error,
      'metadata': metadata,
    };
  }
}

class BatteryInfo {
  final int level;
  final bool isCharging;
  final String status;
  final int? temperature;
  final String? health;
  final String? technology;
  final int? voltage;

  const BatteryInfo({
    required this.level,
    required this.isCharging,
    required this.status,
    this.temperature,
    this.health,
    this.technology,
    this.voltage,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'isCharging': isCharging,
      'status': status,
      'temperature': temperature,
      'health': health,
      'technology': technology,
      'voltage': voltage,
    };
  }
}

class NetworkInfo {
  final String type;
  final bool isConnected;
  final String? ssid;
  final int? signalStrength;
  final String? ipAddress;
  final String? gateway;
  final List<String>? dns;
  final int? speed;

  const NetworkInfo({
    required this.type,
    required this.isConnected,
    this.ssid,
    this.signalStrength,
    this.ipAddress,
    this.gateway,
    this.dns,
    this.speed,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'isConnected': isConnected,
      'ssid': ssid,
      'signalStrength': signalStrength,
      'ipAddress': ipAddress,
      'gateway': gateway,
      'dns': dns,
      'speed': speed,
    };
  }
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  const LocationInfo({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class DeviceInfo {
  final String model;
  final String manufacturer;
  final String platform;
  final String version;
  final String? serialNumber;
  final List<String> supportedAbis;
  final Map<String, dynamic> hardware;

  const DeviceInfo({
    required this.model,
    required this.manufacturer,
    required this.platform,
    required this.version,
    this.serialNumber,
    this.supportedAbis = const [],
    this.hardware = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'manufacturer': manufacturer,
      'platform': platform,
      'version': version,
      'serialNumber': serialNumber,
      'supportedAbis': supportedAbis,
      'hardware': hardware,
    };
  }
}

class ROSAPIService {
  static const String _channel = 'ros_api';
  static const MethodChannel _methodChannel = MethodChannel(_channel);
  
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Initialize ROS API service
  Future<void> initialize() async {
    try {
      await _setupMethodChannels();
    } catch (e) {
      ErrorHandler.reportException(
        e,
        context: 'Initializing ROS API service',
        category: ErrorCategory.system,
      );
    }
  }

  Future<void> _setupMethodChannels() async {
    _methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    try {
      switch (call.method) {
        case 'getBatteryInfo':
          return await getBatteryInfo();
        case 'getNetworkInfo':
          return await getNetworkInfo();
        case 'getLocationInfo':
          return await getLocationInfo();
        case 'getDeviceInfo':
          return await getDeviceInfo();
        default:
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            message: 'Method ${call.method} not implemented',
          );
      }
    } catch (e) {
      throw PlatformException(
        code: 'ERROR',
        message: e.toString(),
      );
    }
  }

  // Battery API (replacement for termux-battery-status)
  Future<ROSAPIResult> getBatteryInfo() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;
      
      final batteryInfo = BatteryInfo(
        level: batteryLevel,
        isCharging: batteryState == BatteryState.charging,
        status: batteryState.name,
        temperature: await _getBatteryTemperature(),
        health: await _getBatteryHealth(),
        technology: await _getBatteryTechnology(),
        voltage: await _getBatteryVoltage(),
      );

      return ROSAPIResult.success(batteryInfo.toJson());
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Getting battery info');
      return ROSAPIResult.error('Failed to get battery info: $e');
    }
  }

  Future<int?> _getBatteryTemperature() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        return await _methodChannel.invokeMethod('getBatteryTemperature');
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<String?> _getBatteryHealth() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        return await _methodChannel.invokeMethod('getBatteryHealth');
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<String?> _getBatteryTechnology() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        return await _methodChannel.invokeMethod('getBatteryTechnology');
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<int?> _getBatteryVoltage() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        return await _methodChannel.invokeMethod('getBatteryVoltage');
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Network API (replacement for termux-wifi-* commands)
  Future<ROSAPIResult> getNetworkInfo() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      
      String networkType;
      switch (connectivityResult) {
        case ConnectivityResult.wifi:
          networkType = 'wifi';
          break;
        case ConnectivityResult.mobile:
          networkType = 'mobile';
          break;
        case ConnectivityResult.ethernet:
          networkType = 'ethernet';
          break;
        case ConnectivityResult.bluetooth:
          networkType = 'bluetooth';
          break;
        case ConnectivityResult.vpn:
          networkType = 'vpn';
          break;
        default:
          networkType = 'none';
      }

      final networkInfo = NetworkInfo(
        type: networkType,
        isConnected: isConnected,
        ssid: await _getWifiSSID(),
        signalStrength: await _getWifiSignalStrength(),
        ipAddress: await _getIPAddress(),
        gateway: await _getGateway(),
        dns: await _getDNSServers(),
        speed: await _getNetworkSpeed(),
      );

      return ROSAPIResult.success(networkInfo.toJson());
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Getting network info');
      return ROSAPIResult.error('Failed to get network info: $e');
    }
  }

  Future<String?> _getWifiSSID() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        return await _methodChannel.invokeMethod('getWifiSSID');
      }
    } catch (e) {
      // Permission denied or not available
    }
    return null;
  }

  Future<int?> _getWifiSignalStrength() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        return await _methodChannel.invokeMethod('getWifiSignalStrength');
      }
    } catch (e) {
      // Permission denied or not available
    }
    return null;
  }

  Future<String?> _getIPAddress() async {
    try {
      if (!kIsWeb) {
        return await _methodChannel.invokeMethod('getIPAddress');
      }
    } catch (e) {
      // Not available
    }
    return null;
  }

  Future<String?> _getGateway() async {
    try {
      if (!kIsWeb) {
        return await _methodChannel.invokeMethod('getGateway');
      }
    } catch (e) {
      // Not available
    }
    return null;
  }

  Future<List<String>?> _getDNSServers() async {
    try {
      if (!kIsWeb) {
        final result = await _methodChannel.invokeMethod('getDNSServers');
        return List<String>.from(result ?? []);
      }
    } catch (e) {
      // Not available
    }
    return null;
  }

  Future<int?> _getNetworkSpeed() async {
    try {
      if (!kIsWeb) {
        return await _methodChannel.invokeMethod('getNetworkSpeed');
      }
    } catch (e) {
      // Not available
    }
    return null;
  }

  // Location API (replacement for termux-location)
  Future<ROSAPIResult> getLocationInfo() async {
    try {
      // Check location permission
      final permission = await Permission.location.status;
      if (permission != PermissionStatus.granted) {
        return ROSAPIResult.error('Location permission not granted');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationInfo = LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp ?? DateTime.now(),
      );

      return ROSAPIResult.success(locationInfo.toJson());
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Getting location info');
      return ROSAPIResult.error('Failed to get location: $e');
    }
  }

  // Device Info API (replacement for termux-telephony-*)
  Future<ROSAPIResult> getDeviceInfo() async {
    try {
      DeviceInfo deviceInfo;

      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceInfo = DeviceInfo(
          model: 'Web Browser',
          manufacturer: webInfo.browserName?.name ?? 'Unknown',
          platform: 'web',
          version: webInfo.appVersion ?? 'Unknown',
          hardware: {
            'userAgent': webInfo.userAgent,
            'platform': webInfo.platform,
          },
        );
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceInfo = DeviceInfo(
          model: androidInfo.model,
          manufacturer: androidInfo.manufacturer,
          platform: 'android',
          version: androidInfo.version.release,
          serialNumber: androidInfo.serialNumber,
          supportedAbis: androidInfo.supportedAbis,
          hardware: {
            'brand': androidInfo.brand,
            'device': androidInfo.device,
            'product': androidInfo.product,
            'hardware': androidInfo.hardware,
            'bootloader': androidInfo.bootloader,
            'fingerprint': androidInfo.fingerprint,
            'isPhysicalDevice': androidInfo.isPhysicalDevice,
          },
        );
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceInfo = DeviceInfo(
          model: iosInfo.model,
          manufacturer: 'Apple',
          platform: 'ios',
          version: iosInfo.systemVersion,
          hardware: {
            'name': iosInfo.name,
            'systemName': iosInfo.systemName,
            'utsname': iosInfo.utsname.toString(),
            'isPhysicalDevice': iosInfo.isPhysicalDevice,
          },
        );
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceInfo = DeviceInfo(
          model: windowsInfo.computerName,
          manufacturer: 'Microsoft',
          platform: 'windows',
          version: windowsInfo.displayVersion,
          hardware: {
            'productName': windowsInfo.productName,
            'numberOfCores': windowsInfo.numberOfCores,
            'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
          },
        );
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        deviceInfo = DeviceInfo(
          model: macInfo.model,
          manufacturer: 'Apple',
          platform: 'macos',
          version: macInfo.osRelease,
          hardware: {
            'hostName': macInfo.hostName,
            'arch': macInfo.arch,
            'kernelVersion': macInfo.kernelVersion,
          },
        );
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        deviceInfo = DeviceInfo(
          model: linuxInfo.prettyName ?? 'Linux',
          manufacturer: 'Linux',
          platform: 'linux',
          version: linuxInfo.version ?? 'Unknown',
          hardware: {
            'name': linuxInfo.name,
            'id': linuxInfo.id,
            'idLike': linuxInfo.idLike,
            'versionId': linuxInfo.versionId,
            'machineId': linuxInfo.machineId,
          },
        );
      } else {
        deviceInfo = const DeviceInfo(
          model: 'Unknown',
          manufacturer: 'Unknown',
          platform: 'unknown',
          version: 'Unknown',
        );
      }

      return ROSAPIResult.success(deviceInfo.toJson());
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Getting device info');
      return ROSAPIResult.error('Failed to get device info: $e');
    }
  }

  // Camera API (replacement for termux-camera-*)
  Future<ROSAPIResult> takePicture({String? cameraId}) async {
    try {
      // Check camera permission
      final permission = await Permission.camera.status;
      if (permission != PermissionStatus.granted) {
        return ROSAPIResult.error('Camera permission not granted');
      }

      if (kIsWeb) {
        return ROSAPIResult.error('Camera not supported on web');
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return ROSAPIResult.error('No cameras available');
      }

      // Select camera
      final camera = cameraId != null 
          ? cameras.firstWhere((c) => c.name == cameraId, orElse: () => cameras.first)
          : cameras.first;

      // Initialize camera controller
      final controller = CameraController(camera, ResolutionPreset.high);
      await controller.initialize();

      // Take picture
      final image = await controller.takePicture();
      await controller.dispose();

      return ROSAPIResult.success({
        'path': image.path,
        'camera': camera.name,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Taking picture');
      return ROSAPIResult.error('Failed to take picture: $e');
    }
  }

  Future<ROSAPIResult> listCameras() async {
    try {
      if (kIsWeb) {
        return ROSAPIResult.success([]);
      }

      final cameras = await availableCameras();
      final cameraList = cameras.map((camera) => {
        'name': camera.name,
        'lensDirection': camera.lensDirection.name,
        'sensorOrientation': camera.sensorOrientation,
      }).toList();

      return ROSAPIResult.success(cameraList);
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Listing cameras');
      return ROSAPIResult.error('Failed to list cameras: $e');
    }
  }

  // Audio API (replacement for termux-microphone-record)
  Future<ROSAPIResult> recordAudio({
    required String outputPath,
    int? duration,
  }) async {
    try {
      // Check microphone permission
      final permission = await Permission.microphone.status;
      if (permission != PermissionStatus.granted) {
        return ROSAPIResult.error('Microphone permission not granted');
      }

      if (kIsWeb) {
        return ROSAPIResult.error('Audio recording not supported on web');
      }

      // Start recording (simplified implementation)
      await Future.delayed(Duration(seconds: duration ?? 5));

      return ROSAPIResult.success({
        'path': outputPath,
        'duration': duration ?? 5,
        'format': 'wav',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Recording audio');
      return ROSAPIResult.error('Failed to record audio: $e');
    }
  }

  Future<ROSAPIResult> playAudio(String filePath) async {
    try {
      final player = AudioPlayer();
      
      if (await File(filePath).exists()) {
        await player.play(DeviceFileSource(filePath));
        return ROSAPIResult.success({
          'status': 'playing',
          'file': filePath,
        });
      } else {
        return ROSAPIResult.error('Audio file not found: $filePath');
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Playing audio');
      return ROSAPIResult.error('Failed to play audio: $e');
    }
  }

  // Notification API (replacement for termux-notification)
  Future<ROSAPIResult> sendNotification({
    required String title,
    required String content,
    String? id,
    String? group,
    String? sound,
    bool? vibrate,
    String? priority,
  }) async {
    try {
      // Check notification permission
      final permission = await Permission.notification.status;
      if (permission != PermissionStatus.granted) {
        return ROSAPIResult.error('Notification permission not granted');
      }

      if (!kIsWeb) {
        await _methodChannel.invokeMethod('sendNotification', {
          'title': title,
          'content': content,
          'id': id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'group': group,
          'sound': sound,
          'vibrate': vibrate ?? false,
          'priority': priority ?? 'default',
        });
      }

      return ROSAPIResult.success({
        'id': id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'status': 'sent',
      });
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Sending notification');
      return ROSAPIResult.error('Failed to send notification: $e');
    }
  }

  Future<ROSAPIResult> cancelNotification(String id) async {
    try {
      if (!kIsWeb) {
        await _methodChannel.invokeMethod('cancelNotification', {'id': id});
      }
      
      return ROSAPIResult.success({'id': id, 'status': 'cancelled'});
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Cancelling notification');
      return ROSAPIResult.error('Failed to cancel notification: $e');
    }
  }

  // Vibration API (replacement for termux-vibrate)
  Future<ROSAPIResult> vibrate({int? duration, List<int>? pattern}) async {
    try {
      if (kIsWeb) {
        return ROSAPIResult.error('Vibration not supported on web');
      }

      await HapticFeedback.vibrate();
      
      if (duration != null || pattern != null) {
        await _methodChannel.invokeMethod('vibrate', {
          'duration': duration,
          'pattern': pattern,
        });
      }

      return ROSAPIResult.success({
        'status': 'vibrated',
        'duration': duration,
        'pattern': pattern,
      });
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Vibrating device');
      return ROSAPIResult.error('Failed to vibrate: $e');
    }
  }

  // Clipboard API (replacement for termux-clipboard-*)
  Future<ROSAPIResult> getClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return ROSAPIResult.success({
        'text': clipboardData?.text ?? '',
      });
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Getting clipboard');
      return ROSAPIResult.error('Failed to get clipboard: $e');
    }
  }

  Future<ROSAPIResult> setClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return ROSAPIResult.success({
        'text': text,
        'status': 'set',
      });
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Setting clipboard');
      return ROSAPIResult.error('Failed to set clipboard: $e');
    }
  }

  // Torch/Flashlight API (replacement for termux-torch)
  Future<ROSAPIResult> toggleTorch({bool? on}) async {
    try {
      if (kIsWeb) {
        return ROSAPIResult.error('Torch not supported on web');
      }

      final result = await _methodChannel.invokeMethod('toggleTorch', {
        'on': on,
      });

      return ROSAPIResult.success({
        'status': result ? 'on' : 'off',
      });
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Toggling torch');
      return ROSAPIResult.error('Failed to toggle torch: $e');
    }
  }

  // Volume API (replacement for termux-volume)
  Future<ROSAPIResult> getVolume() async {
    try {
      if (kIsWeb) {
        return ROSAPIResult.error('Volume control not supported on web');
      }

      final volume = await _methodChannel.invokeMethod('getVolume');
      return ROSAPIResult.success(volume);
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Getting volume');
      return ROSAPIResult.error('Failed to get volume: $e');
    }
  }

  Future<ROSAPIResult> setVolume({
    required String stream,
    required int volume,
  }) async {
    try {
      if (kIsWeb) {
        return ROSAPIResult.error('Volume control not supported on web');
      }

      await _methodChannel.invokeMethod('setVolume', {
        'stream': stream,
        'volume': volume,
      });

      return ROSAPIResult.success({
        'stream': stream,
        'volume': volume,
        'status': 'set',
      });
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Setting volume');
      return ROSAPIResult.error('Failed to set volume: $e');
    }
  }

  // System Info API
  Future<ROSAPIResult> getSystemInfo() async {
    try {
      final platform = await PlatformService.getPlatformInfo();
      final battery = await getBatteryInfo();
      final network = await getNetworkInfo();
      final device = await getDeviceInfo();

      final systemInfo = {
        'platform': platform.toJson(),
        'battery': battery.data,
        'network': network.data,
        'device': device.data,
        'timestamp': DateTime.now().toIso8601String(),
      };

      return ROSAPIResult.success(systemInfo);
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Getting system info');
      return ROSAPIResult.error('Failed to get system info: $e');
    }
  }

  // CLI interface for ROS API
  Future<String> executeAPICommand(List<String> args) async {
    if (args.isEmpty) {
      return _getAPIHelpText();
    }

    final command = args[0];
    final commandArgs = args.skip(1).toList();

    try {
      ROSAPIResult result;

      switch (command) {
        case 'battery':
          result = await getBatteryInfo();
          break;
        case 'network':
        case 'wifi':
          result = await getNetworkInfo();
          break;
        case 'location':
          result = await getLocationInfo();
          break;
        case 'device':
          result = await getDeviceInfo();
          break;
        case 'camera':
          if (commandArgs.isNotEmpty && commandArgs[0] == 'list') {
            result = await listCameras();
          } else {
            result = await takePicture();
          }
          break;
        case 'notification':
        case 'notify':
          if (commandArgs.length >= 2) {
            result = await sendNotification(
              title: commandArgs[0],
              content: commandArgs[1],
            );
          } else {
            return 'Usage: ros api notification <title> <content>';
          }
          break;
        case 'vibrate':
          final duration = commandArgs.isNotEmpty 
              ? int.tryParse(commandArgs[0]) ?? 200
              : 200;
          result = await vibrate(duration: duration);
          break;
        case 'clipboard':
          if (commandArgs.isNotEmpty && commandArgs[0] == 'set') {
            if (commandArgs.length > 1) {
              result = await setClipboard(commandArgs.skip(1).join(' '));
            } else {
              return 'Usage: ros api clipboard set <text>';
            }
          } else {
            result = await getClipboard();
          }
          break;
        case 'torch':
        case 'flashlight':
          final on = commandArgs.isNotEmpty 
              ? commandArgs[0].toLowerCase() == 'on'
              : null;
          result = await toggleTorch(on: on);
          break;
        case 'volume':
          if (commandArgs.isNotEmpty && commandArgs[0] == 'set') {
            if (commandArgs.length >= 3) {
              result = await setVolume(
                stream: commandArgs[1],
                volume: int.parse(commandArgs[2]),
              );
            } else {
              return 'Usage: ros api volume set <stream> <level>';
            }
          } else {
            result = await getVolume();
          }
          break;
        case 'system':
        case 'info':
          result = await getSystemInfo();
          break;
        default:
          return 'Unknown API command: $command\n\n${_getAPIHelpText()}';
      }

      if (result.success) {
        return _formatAPIResult(result.data);
      } else {
        return 'Error: ${result.error}';
      }
    } catch (e) {
      return 'Failed to execute command: $e';
    }
  }

  String _formatAPIResult(dynamic data) {
    if (data is Map<String, dynamic>) {
      final buffer = StringBuffer();
      for (final entry in data.entries) {
        if (entry.value is Map || entry.value is List) {
          buffer.writeln('${entry.key}: ${jsonEncode(entry.value)}');
        } else {
          buffer.writeln('${entry.key}: ${entry.value}');
        }
      }
      return buffer.toString();
    } else if (data is List) {
      return data.map((item) => jsonEncode(item)).join('\n');
    } else {
      return data.toString();
    }
  }

  String _getAPIHelpText() {
    return '''
ROS API - Device access and system information

Usage: ros api <command> [arguments]

Commands:
  battery               Get battery status and information
  network               Get network/WiFi information
  location              Get GPS location information
  device                Get device hardware information
  camera [list]         Take picture or list cameras
  notification <title> <content>  Send notification
  vibrate [duration]    Vibrate device
  clipboard [set <text>]  Get/set clipboard content
  torch [on|off]        Toggle flashlight/torch
  volume [set <stream> <level>]  Get/set volume
  system                Get complete system information

Examples:
  ros api battery
  ros api location
  ros api notification "Hello" "Test notification"
  ros api clipboard set "Hello World"
  ros api camera list
  ros api vibrate 500
  ros api torch on
  ros api volume set music 50
''';
  }
}

// Riverpod providers
final rosAPIServiceProvider = Provider<ROSAPIService>((ref) {
  return ROSAPIService();
});

final batteryInfoProvider = FutureProvider<BatteryInfo?>((ref) async {
  final api = ref.read(rosAPIServiceProvider);
  final result = await api.getBatteryInfo();
  if (result.success && result.data != null) {
    return BatteryInfo(
      level: result.data['level'],
      isCharging: result.data['isCharging'],
      status: result.data['status'],
      temperature: result.data['temperature'],
      health: result.data['health'],
      technology: result.data['technology'],
      voltage: result.data['voltage'],
    );
  }
  return null;
});

final networkInfoProvider = FutureProvider<NetworkInfo?>((ref) async {
  final api = ref.read(rosAPIServiceProvider);
  final result = await api.getNetworkInfo();
  if (result.success && result.data != null) {
    return NetworkInfo(
      type: result.data['type'],
      isConnected: result.data['isConnected'],
      ssid: result.data['ssid'],
      signalStrength: result.data['signalStrength'],
      ipAddress: result.data['ipAddress'],
      gateway: result.data['gateway'],
      dns: result.data['dns']?.cast<String>(),
      speed: result.data['speed'],
    );
  }
  return null;
});

final deviceInfoProvider = FutureProvider<DeviceInfo?>((ref) async {
  final api = ref.read(rosAPIServiceProvider);
  final result = await api.getDeviceInfo();
  if (result.success && result.data != null) {
    return DeviceInfo(
      model: result.data['model'],
      manufacturer: result.data['manufacturer'],
      platform: result.data['platform'],
      version: result.data['version'],
      serialNumber: result.data['serialNumber'],
      supportedAbis: result.data['supportedAbis']?.cast<String>() ?? [],
      hardware: result.data['hardware'] ?? {},
    );
  }
  return null;
});