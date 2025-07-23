import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../platform/platform_service.dart';
import '../error_handling/error_handler.dart';

class SystemMetrics {
  final double cpuUsage;
  final double memoryUsage;
  final int totalMemory;
  final int availableMemory;
  final int usedMemory;
  final double diskUsage;
  final int totalDisk;
  final int availableDisk;
  final int usedDisk;
  final double networkUpload;
  final double networkDownload;
  final int processCount;
  final double temperature;
  final DateTime timestamp;

  const SystemMetrics({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.totalMemory,
    required this.availableMemory,
    required this.usedMemory,
    required this.diskUsage,
    required this.totalDisk,
    required this.availableDisk,
    required this.usedDisk,
    required this.networkUpload,
    required this.networkDownload,
    required this.processCount,
    required this.temperature,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'totalMemory': totalMemory,
      'availableMemory': availableMemory,
      'usedMemory': usedMemory,
      'diskUsage': diskUsage,
      'totalDisk': totalDisk,
      'availableDisk': availableDisk,
      'usedDisk': usedDisk,
      'networkUpload': networkUpload,
      'networkDownload': networkDownload,
      'processCount': processCount,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ProcessInfo {
  final int pid;
  final String name;
  final String command;
  final double cpuUsage;
  final int memoryUsage;
  final String status;
  final String? user;
  final DateTime startTime;
  final int threads;
  final int priority;

  const ProcessInfo({
    required this.pid,
    required this.name,
    required this.command,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.status,
    this.user,
    required this.startTime,
    required this.threads,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'name': name,
      'command': command,
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'status': status,
      'user': user,
      'startTime': startTime.toIso8601String(),
      'threads': threads,
      'priority': priority,
    };
  }
}

class NetworkInterface {
  final String name;
  final String type;
  final bool isUp;
  final int bytesReceived;
  final int bytesSent;
  final int packetsReceived;
  final int packetsSent;
  final double downloadSpeed;
  final double uploadSpeed;
  final String? ipAddress;
  final String? macAddress;

  const NetworkInterface({
    required this.name,
    required this.type,
    required this.isUp,
    required this.bytesReceived,
    required this.bytesSent,
    required this.packetsReceived,
    required this.packetsSent,
    required this.downloadSpeed,
    required this.uploadSpeed,
    this.ipAddress,
    this.macAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'isUp': isUp,
      'bytesReceived': bytesReceived,
      'bytesSent': bytesSent,
      'packetsReceived': packetsReceived,
      'packetsSent': packetsSent,
      'downloadSpeed': downloadSpeed,
      'uploadSpeed': uploadSpeed,
      'ipAddress': ipAddress,
      'macAddress': macAddress,
    };
  }
}

class DiskInfo {
  final String device;
  final String mountPoint;
  final String filesystem;
  final int totalSize;
  final int usedSize;
  final int availableSize;
  final double usagePercent;
  final int readOperations;
  final int writeOperations;
  final int readBytes;
  final int writeBytes;

  const DiskInfo({
    required this.device,
    required this.mountPoint,
    required this.filesystem,
    required this.totalSize,
    required this.usedSize,
    required this.availableSize,
    required this.usagePercent,
    required this.readOperations,
    required this.writeOperations,
    required this.readBytes,
    required this.writeBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'mountPoint': mountPoint,
      'filesystem': filesystem,
      'totalSize': totalSize,
      'usedSize': usedSize,
      'availableSize': availableSize,
      'usagePercent': usagePercent,
      'readOperations': readOperations,
      'writeOperations': writeOperations,
      'readBytes': readBytes,
      'writeBytes': writeBytes,
    };
  }
}

class ROSPerformanceMonitor {
  static const String _metricsHistoryFile = 'ros_metrics_history.json';
  
  Timer? _monitoringTimer;
  final List<SystemMetrics> _metricsHistory = [];
  final Map<int, ProcessInfo> _processes = {};
  final Map<String, NetworkInterface> _networkInterfaces = {};
  final Map<String, DiskInfo> _disks = {};
  final List<Function(SystemMetrics)> _metricsListeners = [];
  
  bool _isMonitoring = false;
  int _updateInterval = 2000; // milliseconds
  int _maxHistoryEntries = 100;

  // Initialize performance monitor
  Future<void> initialize() async {
    await _loadMetricsHistory();
  }

  // Start/Stop monitoring
  Future<void> startMonitoring({int? intervalMs}) async {
    if (_isMonitoring) return;
    
    _updateInterval = intervalMs ?? _updateInterval;
    _isMonitoring = true;
    
    _monitoringTimer = Timer.periodic(
      Duration(milliseconds: _updateInterval),
      (_) => _collectMetrics(),
    );
    
    // Initial collection
    await _collectMetrics();
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  // Metrics collection
  Future<void> _collectMetrics() async {
    try {
      final cpuUsage = await _getCPUUsage();
      final memoryInfo = await _getMemoryInfo();
      final diskInfo = await _getDiskInfo();
      final networkInfo = await _getNetworkInfo();
      final processCount = await _getProcessCount();
      final temperature = await _getTemperature();

      final metrics = SystemMetrics(
        cpuUsage: cpuUsage,
        memoryUsage: memoryInfo['usage'],
        totalMemory: memoryInfo['total'],
        availableMemory: memoryInfo['available'],
        usedMemory: memoryInfo['used'],
        diskUsage: diskInfo['usage'],
        totalDisk: diskInfo['total'],
        availableDisk: diskInfo['available'],
        usedDisk: diskInfo['used'],
        networkUpload: networkInfo['upload'],
        networkDownload: networkInfo['download'],
        processCount: processCount,
        temperature: temperature,
        timestamp: DateTime.now(),
      );

      _addToHistory(metrics);
      _notifyListeners(metrics);
    } catch (e) {
      ErrorHandler.reportException(
        e,
        context: 'Collecting performance metrics',
        category: ErrorCategory.system,
      );
    }
  }

  Future<double> _getCPUUsage() async {
    if (kIsWeb) return 0.0;

    try {
      if (Platform.isLinux || Platform.isMacOS) {
        // Use /proc/stat on Linux, top on macOS
        if (Platform.isLinux) {
          return await _getLinuxCPUUsage();
        } else {
          return await _getMacOSCPUUsage();
        }
      } else if (Platform.isWindows) {
        return await _getWindowsCPUUsage();
      } else if (Platform.isAndroid) {
        return await _getAndroidCPUUsage();
      }
    } catch (e) {
      // Fallback to simulated data
    }
    
    return 0.0;
  }

  Future<double> _getLinuxCPUUsage() async {
    try {
      // Read /proc/stat twice with a small interval
      final stat1 = await _readProcStat();
      await Future.delayed(const Duration(milliseconds: 100));
      final stat2 = await _readProcStat();
      
      final idle1 = stat1['idle'] + stat1['iowait'];
      final total1 = stat1.values.reduce((a, b) => a + b);
      
      final idle2 = stat2['idle'] + stat2['iowait'];
      final total2 = stat2.values.reduce((a, b) => a + b);
      
      final idleDiff = idle2 - idle1;
      final totalDiff = total2 - total1;
      
      final usage = (totalDiff - idleDiff) / totalDiff * 100;
      return usage.clamp(0.0, 100.0);
    } catch (e) {
      return 0.0;
    }
  }

  Future<Map<String, int>> _readProcStat() async {
    final file = File('/proc/stat');
    final lines = await file.readAsLines();
    final cpuLine = lines.first.split(' ').skip(1).where((s) => s.isNotEmpty);
    final values = cpuLine.map(int.parse).toList();
    
    return {
      'user': values[0],
      'nice': values[1],
      'system': values[2],
      'idle': values[3],
      'iowait': values[4],
      'irq': values[5],
      'softirq': values[6],
      'steal': values.length > 7 ? values[7] : 0,
    };
  }

  Future<double> _getMacOSCPUUsage() async {
    try {
      final result = await Process.run('top', ['-l', '1', '-n', '0']);
      final output = result.stdout as String;
      
      final cpuLine = output.split('\n').firstWhere(
        (line) => line.contains('CPU usage'),
        orElse: () => '',
      );
      
      final match = RegExp(r'(\d+\.\d+)%').firstMatch(cpuLine);
      if (match != null) {
        return double.parse(match.group(1)!);
      }
    } catch (e) {
      // Fallback
    }
    return 0.0;
  }

  Future<double> _getWindowsCPUUsage() async {
    try {
      final result = await Process.run('wmic', [
        'cpu', 'get', 'loadpercentage', '/value'
      ]);
      
      final output = result.stdout as String;
      final match = RegExp(r'LoadPercentage=(\d+)').firstMatch(output);
      
      if (match != null) {
        return double.parse(match.group(1)!);
      }
    } catch (e) {
      // Fallback
    }
    return 0.0;
  }

  Future<double> _getAndroidCPUUsage() async {
    try {
      // Read /proc/stat on Android (if available)
      return await _getLinuxCPUUsage();
    } catch (e) {
      return 0.0;
    }
  }

  Future<Map<String, dynamic>> _getMemoryInfo() async {
    if (kIsWeb) {
      return {
        'total': 8589934592, // 8GB default
        'used': 4294967296, // 4GB default
        'available': 4294967296,
        'usage': 50.0,
      };
    }

    try {
      if (Platform.isLinux || Platform.isAndroid) {
        return await _getLinuxMemoryInfo();
      } else if (Platform.isMacOS) {
        return await _getMacOSMemoryInfo();
      } else if (Platform.isWindows) {
        return await _getWindowsMemoryInfo();
      }
    } catch (e) {
      // Fallback
    }

    return {
      'total': 0,
      'used': 0,
      'available': 0,
      'usage': 0.0,
    };
  }

  Future<Map<String, dynamic>> _getLinuxMemoryInfo() async {
    try {
      final file = File('/proc/meminfo');
      final lines = await file.readAsLines();
      
      int total = 0, available = 0, free = 0, buffers = 0, cached = 0;
      
      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = int.tryParse(
            parts[1].replaceAll(RegExp(r'[^\d]'), '')
          ) ?? 0;
          
          switch (key) {
            case 'MemTotal':
              total = value * 1024; // Convert from KB to bytes
              break;
            case 'MemAvailable':
              available = value * 1024;
              break;
            case 'MemFree':
              free = value * 1024;
              break;
            case 'Buffers':
              buffers = value * 1024;
              break;
            case 'Cached':
              cached = value * 1024;
              break;
          }
        }
      }
      
      // If MemAvailable is not available, estimate it
      if (available == 0) {
        available = free + buffers + cached;
      }
      
      final used = total - available;
      final usage = total > 0 ? (used / total * 100) : 0.0;
      
      return {
        'total': total,
        'used': used,
        'available': available,
        'usage': usage,
      };
    } catch (e) {
      throw Exception('Failed to read memory info: $e');
    }
  }

  Future<Map<String, dynamic>> _getMacOSMemoryInfo() async {
    try {
      final result = await Process.run('vm_stat', []);
      final output = result.stdout as String;
      
      int pageSize = 4096; // Default page size
      int freePages = 0, activePages = 0, inactivePages = 0, wiredPages = 0;
      
      for (final line in output.split('\n')) {
        if (line.contains('page size of')) {
          final match = RegExp(r'(\d+)').firstMatch(line);
          if (match != null) pageSize = int.parse(match.group(1)!);
        } else if (line.contains('Pages free:')) {
          final match = RegExp(r'(\d+)').firstMatch(line);
          if (match != null) freePages = int.parse(match.group(1)!);
        } else if (line.contains('Pages active:')) {
          final match = RegExp(r'(\d+)').firstMatch(line);
          if (match != null) activePages = int.parse(match.group(1)!);
        } else if (line.contains('Pages inactive:')) {
          final match = RegExp(r'(\d+)').firstMatch(line);
          if (match != null) inactivePages = int.parse(match.group(1)!);
        } else if (line.contains('Pages wired down:')) {
          final match = RegExp(r'(\d+)').firstMatch(line);
          if (match != null) wiredPages = int.parse(match.group(1)!);
        }
      }
      
      final totalPages = freePages + activePages + inactivePages + wiredPages;
      final total = totalPages * pageSize;
      final available = freePages * pageSize;
      final used = total - available;
      final usage = total > 0 ? (used / total * 100) : 0.0;
      
      return {
        'total': total,
        'used': used,
        'available': available,
        'usage': usage,
      };
    } catch (e) {
      throw Exception('Failed to get macOS memory info: $e');
    }
  }

  Future<Map<String, dynamic>> _getWindowsMemoryInfo() async {
    try {
      final result = await Process.run('wmic', [
        'OS', 'get', 'TotalVisibleMemorySize,AvailableMemorySize', '/value'
      ]);
      
      final output = result.stdout as String;
      
      int total = 0, available = 0;
      
      for (final line in output.split('\n')) {
        if (line.contains('TotalVisibleMemorySize=')) {
          total = int.tryParse(line.split('=')[1].trim()) ?? 0;
          total *= 1024; // Convert from KB to bytes
        } else if (line.contains('AvailableMemorySize=')) {
          available = int.tryParse(line.split('=')[1].trim()) ?? 0;
          available *= 1024; // Convert from KB to bytes
        }
      }
      
      final used = total - available;
      final usage = total > 0 ? (used / total * 100) : 0.0;
      
      return {
        'total': total,
        'used': used,
        'available': available,
        'usage': usage,
      };
    } catch (e) {
      throw Exception('Failed to get Windows memory info: $e');
    }
  }

  Future<Map<String, dynamic>> _getDiskInfo() async {
    if (kIsWeb) {
      return {
        'total': 1099511627776, // 1TB default
        'used': 549755813888, // 512GB default
        'available': 549755813888,
        'usage': 50.0,
      };
    }

    try {
      if (Platform.isLinux || Platform.isMacOS || Platform.isAndroid) {
        return await _getUnixDiskInfo();
      } else if (Platform.isWindows) {
        return await _getWindowsDiskInfo();
      }
    } catch (e) {
      // Fallback
    }

    return {
      'total': 0,
      'used': 0,
      'available': 0,
      'usage': 0.0,
    };
  }

  Future<Map<String, dynamic>> _getUnixDiskInfo() async {
    try {
      final result = await Process.run('df', ['-B1', '/']);
      final lines = result.stdout.toString().split('\n');
      
      if (lines.length > 1) {
        final parts = lines[1].split(RegExp(r'\s+'));
        if (parts.length >= 4) {
          final total = int.parse(parts[1]);
          final used = int.parse(parts[2]);
          final available = int.parse(parts[3]);
          final usage = total > 0 ? (used / total * 100) : 0.0;
          
          return {
            'total': total,
            'used': used,
            'available': available,
            'usage': usage,
          };
        }
      }
    } catch (e) {
      // Fallback
    }
    
    return {
      'total': 0,
      'used': 0,
      'available': 0,
      'usage': 0.0,
    };
  }

  Future<Map<String, dynamic>> _getWindowsDiskInfo() async {
    try {
      final result = await Process.run('wmic', [
        'logicaldisk', 'where', 'caption="C:"', 'get', 'size,freespace', '/value'
      ]);
      
      final output = result.stdout as String;
      
      int total = 0, free = 0;
      
      for (final line in output.split('\n')) {
        if (line.contains('Size=')) {
          total = int.tryParse(line.split('=')[1].trim()) ?? 0;
        } else if (line.contains('FreeSpace=')) {
          free = int.tryParse(line.split('=')[1].trim()) ?? 0;
        }
      }
      
      final used = total - free;
      final usage = total > 0 ? (used / total * 100) : 0.0;
      
      return {
        'total': total,
        'used': used,
        'available': free,
        'usage': usage,
      };
    } catch (e) {
      throw Exception('Failed to get Windows disk info: $e');
    }
  }

  Future<Map<String, dynamic>> _getNetworkInfo() async {
    // Simplified network info - return default values
    return {
      'upload': 0.0,
      'download': 0.0,
    };
  }

  Future<int> _getProcessCount() async {
    if (kIsWeb) return 50;

    try {
      if (Platform.isLinux || Platform.isMacOS || Platform.isAndroid) {
        final result = await Process.run('ps', ['aux']);
        final lines = result.stdout.toString().split('\n');
        return lines.length - 1; // Subtract header line
      } else if (Platform.isWindows) {
        final result = await Process.run('tasklist', []);
        final lines = result.stdout.toString().split('\n');
        return lines.length - 3; // Subtract header lines
      }
    } catch (e) {
      // Fallback
    }
    
    return 0;
  }

  Future<double> _getTemperature() async {
    if (kIsWeb) return 45.0;

    try {
      if (Platform.isLinux) {
        // Try to read temperature from thermal zones
        final thermalPath = '/sys/class/thermal/thermal_zone0/temp';
        final file = File(thermalPath);
        
        if (await file.exists()) {
          final tempStr = await file.readAsString();
          final temp = int.parse(tempStr.trim()) / 1000.0; // Convert from millidegrees
          return temp;
        }
      } else if (Platform.isMacOS) {
        // macOS temperature monitoring requires additional tools
        return 45.0;
      }
    } catch (e) {
      // Fallback
    }
    
    return 45.0; // Default temperature
  }

  // Process monitoring
  Future<List<ProcessInfo>> getProcessList() async {
    if (kIsWeb) return [];

    try {
      if (Platform.isLinux || Platform.isMacOS || Platform.isAndroid) {
        return await _getUnixProcessList();
      } else if (Platform.isWindows) {
        return await _getWindowsProcessList();
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Getting process list');
    }
    
    return [];
  }

  Future<List<ProcessInfo>> _getUnixProcessList() async {
    try {
      final result = await Process.run('ps', [
        'aux', '--sort=-pcpu'
      ]);
      
      final lines = result.stdout.toString().split('\n');
      final processes = <ProcessInfo>[];
      
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 11) {
          try {
            final pid = int.parse(parts[1]);
            final cpuUsage = double.parse(parts[2]);
            final memUsage = double.parse(parts[3]);
            final command = parts.skip(10).join(' ');
            
            processes.add(ProcessInfo(
              pid: pid,
              name: parts[10].split('/').last,
              command: command,
              cpuUsage: cpuUsage,
              memoryUsage: (memUsage * 1024 * 1024).round(), // Convert % to approximate bytes
              status: parts[7],
              user: parts[0],
              startTime: DateTime.now(), // Simplified
              threads: 1,
              priority: 0,
            ));
          } catch (e) {
            // Skip malformed lines
          }
        }
      }
      
      return processes.take(50).toList(); // Limit to top 50 processes
    } catch (e) {
      throw Exception('Failed to get Unix process list: $e');
    }
  }

  Future<List<ProcessInfo>> _getWindowsProcessList() async {
    try {
      final result = await Process.run('tasklist', ['/fo', 'csv']);
      final lines = result.stdout.toString().split('\n');
      final processes = <ProcessInfo>[];
      
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final parts = line.split(',');
        if (parts.length >= 5) {
          try {
            final name = parts[0].replaceAll('"', '');
            final pid = int.parse(parts[1].replaceAll('"', ''));
            final memStr = parts[4].replaceAll('"', '').replaceAll(',', '');
            final memUsage = int.parse(memStr.replaceAll(' K', '')) * 1024;
            
            processes.add(ProcessInfo(
              pid: pid,
              name: name,
              command: name,
              cpuUsage: 0.0, // Windows tasklist doesn't provide CPU %
              memoryUsage: memUsage,
              status: 'Running',
              user: null,
              startTime: DateTime.now(),
              threads: 1,
              priority: 0,
            ));
          } catch (e) {
            // Skip malformed lines
          }
        }
      }
      
      return processes.take(50).toList();
    } catch (e) {
      throw Exception('Failed to get Windows process list: $e');
    }
  }

  // CLI interface
  Future<String> executePerformanceCommand(List<String> args) async {
    if (args.isEmpty) {
      return _getPerformanceHelpText();
    }

    final command = args[0];
    final commandArgs = args.skip(1).toList();

    switch (command) {
      case 'htop':
      case 'top':
        return await _cliTop(commandArgs);
      case 'ps':
        return await _cliProcessList(commandArgs);
      case 'mem':
      case 'memory':
        return await _cliMemory();
      case 'disk':
        return await _cliDisk();
      case 'cpu':
        return await _cliCPU();
      case 'net':
      case 'network':
        return await _cliNetwork();
      case 'temp':
      case 'temperature':
        return await _cliTemperature();
      case 'monitor':
        return await _cliMonitor(commandArgs);
      case 'kill':
        return await _cliKillProcess(commandArgs);
      default:
        return 'Unknown command: $command\n\n${_getPerformanceHelpText()}';
    }
  }

  Future<String> _cliTop(List<String> args) async {
    final processes = await getProcessList();
    await _collectMetrics();
    
    final latest = _metricsHistory.lastOrNull;
    if (latest == null) return 'No metrics available';
    
    final buffer = StringBuffer();
    buffer.writeln('ROS Performance Monitor');
    buffer.writeln('Time: ${latest.timestamp}');
    buffer.writeln('');
    buffer.writeln('CPU Usage: ${latest.cpuUsage.toStringAsFixed(1)}%');
    buffer.writeln('Memory: ${_formatBytes(latest.usedMemory)} / ${_formatBytes(latest.totalMemory)} (${latest.memoryUsage.toStringAsFixed(1)}%)');
    buffer.writeln('Disk: ${_formatBytes(latest.usedDisk)} / ${_formatBytes(latest.totalDisk)} (${latest.diskUsage.toStringAsFixed(1)}%)');
    buffer.writeln('Processes: ${latest.processCount}');
    buffer.writeln('Temperature: ${latest.temperature.toStringAsFixed(1)}°C');
    buffer.writeln('');
    buffer.writeln('PID     NAME               CPU%    MEM     STATUS');
    buffer.writeln('─' * 50);
    
    for (final process in processes.take(15)) {
      buffer.writeln(
        '${process.pid.toString().padRight(8)}${process.name.length > 18 ? process.name.substring(0, 18) : process.name.padRight(18)} '
        '${process.cpuUsage.toStringAsFixed(1).padLeft(6)}% ${_formatBytes(process.memoryUsage).padLeft(7)} ${process.status}'
      );
    }
    
    return buffer.toString();
  }

  Future<String> _cliProcessList(List<String> args) async {
    final processes = await getProcessList();
    
    final buffer = StringBuffer();
    buffer.writeln('Process List (${processes.length} processes)');
    buffer.writeln('');
    buffer.writeln('PID     NAME                    CPU%    MEMORY      STATUS    USER');
    buffer.writeln('─' * 80);
    
    for (final process in processes) {
      buffer.writeln(
        '${process.pid.toString().padRight(8)}'
        '${process.name.length > 22 ? process.name.substring(0, 22) : process.name.padRight(22)} '
        '${process.cpuUsage.toStringAsFixed(1).padLeft(6)}% '
        '${_formatBytes(process.memoryUsage).padLeft(10)} '
        '${process.status.padRight(9)} '
        '${process.user ?? 'unknown'}'
      );
    }
    
    return buffer.toString();
  }

  Future<String> _cliMemory() async {
    await _collectMetrics();
    final latest = _metricsHistory.lastOrNull;
    if (latest == null) return 'No metrics available';
    
    return '''
Memory Information:
Total:     ${_formatBytes(latest.totalMemory)}
Used:      ${_formatBytes(latest.usedMemory)}
Available: ${_formatBytes(latest.availableMemory)}
Usage:     ${latest.memoryUsage.toStringAsFixed(1)}%
''';
  }

  Future<String> _cliDisk() async {
    await _collectMetrics();
    final latest = _metricsHistory.lastOrNull;
    if (latest == null) return 'No metrics available';
    
    return '''
Disk Information:
Total:     ${_formatBytes(latest.totalDisk)}
Used:      ${_formatBytes(latest.usedDisk)}
Available: ${_formatBytes(latest.availableDisk)}
Usage:     ${latest.diskUsage.toStringAsFixed(1)}%
''';
  }

  Future<String> _cliCPU() async {
    await _collectMetrics();
    final latest = _metricsHistory.lastOrNull;
    if (latest == null) return 'No metrics available';
    
    return '''
CPU Information:
Usage:       ${latest.cpuUsage.toStringAsFixed(1)}%
Temperature: ${latest.temperature.toStringAsFixed(1)}°C
''';
  }

  Future<String> _cliNetwork() async {
    await _collectMetrics();
    final latest = _metricsHistory.lastOrNull;
    if (latest == null) return 'No metrics available';
    
    return '''
Network Information:
Download: ${_formatBytes(latest.networkDownload.round())}/s
Upload:   ${_formatBytes(latest.networkUpload.round())}/s
''';
  }

  Future<String> _cliTemperature() async {
    final temp = await _getTemperature();
    return 'Current Temperature: ${temp.toStringAsFixed(1)}°C';
  }

  Future<String> _cliMonitor(List<String> args) async {
    if (args.isNotEmpty && args[0] == 'start') {
      final interval = args.length > 1 ? int.tryParse(args[1]) ?? 2000 : 2000;
      await startMonitoring(intervalMs: interval);
      return 'Started monitoring (interval: ${interval}ms)';
    } else if (args.isNotEmpty && args[0] == 'stop') {
      stopMonitoring();
      return 'Stopped monitoring';
    } else {
      return '''
Monitor Commands:
  ros perf monitor start [interval_ms]  - Start monitoring
  ros perf monitor stop                 - Stop monitoring
  
Current status: ${_isMonitoring ? 'Running' : 'Stopped'}
''';
    }
  }

  Future<String> _cliKillProcess(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: ros perf kill <pid>';
    }
    
    final pid = int.tryParse(args[0]);
    if (pid == null) {
      return 'Invalid PID: ${args[0]}';
    }
    
    try {
      if (!kIsWeb) {
        if (Platform.isWindows) {
          await Process.run('taskkill', ['/PID', pid.toString(), '/F']);
        } else {
          await Process.run('kill', [pid.toString()]);
        }
      }
      return 'Killed process $pid';
    } catch (e) {
      return 'Failed to kill process $pid: $e';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)}MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)}GB';
  }

  String _getPerformanceHelpText() {
    return '''
ROS Performance Monitor - System monitoring and process management

Usage: ros perf <command> [arguments]

Commands:
  htop                  Show live system overview (like htop)
  ps                    List all processes
  mem                   Show memory information
  disk                  Show disk usage
  cpu                   Show CPU information
  net                   Show network statistics
  temp                  Show temperature
  monitor <start|stop>  Control monitoring
  kill <pid>            Kill process by PID

Examples:
  ros perf htop
  ros perf ps
  ros perf monitor start 1000
  ros perf kill 1234
''';
  }

  // Utility methods
  void _addToHistory(SystemMetrics metrics) {
    _metricsHistory.add(metrics);
    if (_metricsHistory.length > _maxHistoryEntries) {
      _metricsHistory.removeAt(0);
    }
    _saveMetricsHistory();
  }

  void addMetricsListener(Function(SystemMetrics) listener) {
    _metricsListeners.add(listener);
  }

  void removeMetricsListener(Function(SystemMetrics) listener) {
    _metricsListeners.remove(listener);
  }

  void _notifyListeners(SystemMetrics metrics) {
    for (final listener in _metricsListeners) {
      try {
        listener(metrics);
      } catch (e) {
        // Ignore listener errors
      }
    }
  }

  // Persistence
  Future<void> _loadMetricsHistory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_metricsHistoryFile');
      
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as List;
        _metricsHistory.clear();
        
        for (final metricData in data.take(50)) { // Limit loaded history
          _metricsHistory.add(SystemMetrics(
            cpuUsage: metricData['cpuUsage'],
            memoryUsage: metricData['memoryUsage'],
            totalMemory: metricData['totalMemory'],
            availableMemory: metricData['availableMemory'],
            usedMemory: metricData['usedMemory'],
            diskUsage: metricData['diskUsage'],
            totalDisk: metricData['totalDisk'],
            availableDisk: metricData['availableDisk'],
            usedDisk: metricData['usedDisk'],
            networkUpload: metricData['networkUpload'],
            networkDownload: metricData['networkDownload'],
            processCount: metricData['processCount'],
            temperature: metricData['temperature'],
            timestamp: DateTime.parse(metricData['timestamp']),
          ));
        }
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Loading metrics history');
    }
  }

  Future<void> _saveMetricsHistory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_metricsHistoryFile');
      
      final data = _metricsHistory.map((m) => m.toJson()).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Saving metrics history');
    }
  }

  // Getters
  List<SystemMetrics> get metricsHistory => List.unmodifiable(_metricsHistory);
  bool get isMonitoring => _isMonitoring;
  int get updateInterval => _updateInterval;
  SystemMetrics? get latestMetrics => _metricsHistory.lastOrNull;
}

// Riverpod providers
final rosPerformanceMonitorProvider = Provider<ROSPerformanceMonitor>((ref) {
  return ROSPerformanceMonitor();
});

final systemMetricsProvider = StateNotifierProvider<SystemMetricsNotifier, SystemMetrics?>((ref) {
  return SystemMetricsNotifier(ref.read(rosPerformanceMonitorProvider));
});

final processListProvider = StateNotifierProvider<ProcessListNotifier, List<ProcessInfo>>((ref) {
  return ProcessListNotifier(ref.read(rosPerformanceMonitorProvider));
});

class SystemMetricsNotifier extends StateNotifier<SystemMetrics?> {
  final ROSPerformanceMonitor _monitor;
  
  SystemMetricsNotifier(this._monitor) : super(null) {
    _monitor.addMetricsListener(_updateMetrics);
  }

  void _updateMetrics(SystemMetrics metrics) {
    state = metrics;
  }

  Future<void> startMonitoring({int? intervalMs}) async {
    await _monitor.startMonitoring(intervalMs: intervalMs);
  }

  void stopMonitoring() {
    _monitor.stopMonitoring();
  }

  @override
  void dispose() {
    _monitor.removeMetricsListener(_updateMetrics);
    super.dispose();
  }
}

class ProcessListNotifier extends StateNotifier<List<ProcessInfo>> {
  final ROSPerformanceMonitor _monitor;
  
  ProcessListNotifier(this._monitor) : super([]);

  Future<void> refresh() async {
    final processes = await _monitor.getProcessList();
    state = processes;
  }
}