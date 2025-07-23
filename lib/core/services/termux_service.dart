import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/termux_package.dart';
import '../models/termux_environment.dart';

class TermuxService {
  static TermuxService? _instance;
  static TermuxService get instance => _instance ??= TermuxService._();
  TermuxService._();

  late String _termuxHome;
  late String _termuxBin;
  late String _termuxPkg;
  bool _isInitialized = false;
  Process? _currentProcess;
  final StreamController<String> _outputController = StreamController<String>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  String get termuxHome => _termuxHome;
  String get termuxBin => _termuxBin;
  Stream<String> get outputStream => _outputController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Initialize Termux Environment
  static Future<void> initialize() async {
    await instance._initializeTermuxEnvironment();
  }

  Future<void> _initializeTermuxEnvironment() async {
    try {
      debugPrint('Initializing Termux environment...');
      
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      _termuxHome = '${appDir.path}/termux';
      _termuxBin = '$_termuxHome/usr/bin';
      _termuxPkg = '$_termuxHome/usr/var/lib/pkg';

      // Create directory structure
      await _createDirectoryStructure();

      // Check if Termux is already installed
      if (!await _isTermuxInstalled()) {
        await _downloadAndInstallTermux();
      }

      // Setup environment variables
      await _setupEnvironment();

      // Install essential packages
      await _installEssentialPackages();

      _isInitialized = true;
      debugPrint('Termux environment initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Termux environment: $e');
      throw Exception('Termux initialization failed: $e');
    }
  }

  Future<void> _createDirectoryStructure() async {
    final directories = [
      _termuxHome,
      '$_termuxHome/usr',
      '$_termuxHome/usr/bin',
      '$_termuxHome/usr/lib',
      '$_termuxHome/usr/var',
      '$_termuxHome/usr/var/lib',
      '$_termuxHome/usr/var/lib/pkg',
      '$_termuxHome/home',
      '$_termuxHome/tmp',
      AppConstants.scriptsDirectory,
      AppConstants.downloadsDirectory,
      AppConstants.backupDirectory,
    ];

    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
    }
  }

  Future<bool> _isTermuxInstalled() async {
    final bashPath = '$_termuxBin/bash';
    return await File(bashPath).exists();
  }

  Future<void> _downloadAndInstallTermux() async {
    try {
      debugPrint('Downloading Termux bootstrap...');
      
      // In a real implementation, you would download the actual Termux bootstrap
      // For now, we'll create a minimal shell environment
      await _createMinimalShellEnvironment();
      
      debugPrint('Termux bootstrap installed successfully');
    } catch (e) {
      debugPrint('Failed to download Termux bootstrap: $e');
      throw Exception('Termux download failed: $e');
    }
  }

  Future<void> _createMinimalShellEnvironment() async {
    // Create basic shell scripts
    final bashScript = '''#!/system/bin/sh
# ROS Terminal Shell
export HOME=$_termuxHome/home
export PREFIX=$_termuxHome/usr
export PATH=\$PREFIX/bin:\$PATH
export TMPDIR=$_termuxHome/tmp
cd \$HOME
exec /system/bin/sh "\$@"
''';

    final bashFile = File('$_termuxBin/bash');
    await bashFile.writeAsString(bashScript);
    
    // Make executable (on Unix systems)
    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', bashFile.path]);
    }

    // Create basic commands
    await _createBasicCommands();
  }

  Future<void> _createBasicCommands() async {
    final commands = {
      'ls': 'ls',
      'cat': 'cat',
      'echo': 'echo',
      'pwd': 'pwd',
      'cd': 'cd',
      'mkdir': 'mkdir',
      'rm': 'rm',
      'cp': 'cp',
      'mv': 'mv',
      'grep': 'grep',
      'find': 'find',
      'wget': 'wget',
      'curl': 'curl',
      'git': 'git',
      'python': 'python3',
      'pip': 'pip3',
      'nano': 'nano',
      'vim': 'vim',
    };

    for (final entry in commands.entries) {
      final commandFile = File('$_termuxBin/${entry.key}');
      if (!await commandFile.exists()) {
        // Create symlink or wrapper script
        final wrapper = '''#!/system/bin/sh
exec ${entry.value} "\$@"
''';
        await commandFile.writeAsString(wrapper);
        if (!Platform.isWindows) {
          await Process.run('chmod', ['+x', commandFile.path]);
        }
      }
    }
  }

  Future<void> _setupEnvironment() async {
    // Create .bashrc
    final bashrc = '''
# ROS Terminal Configuration
export HOME=$_termuxHome/home
export PREFIX=$_termuxHome/usr
export PATH=\$PREFIX/bin:\$PATH
export TMPDIR=$_termuxHome/tmp
export SHELL=\$PREFIX/bin/bash
export TERM=xterm-256color

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# ROS specific aliases
alias ros-help='echo "ROS Terminal Help - Type /ai help for AI assistance"'
alias ros-update='pkg update && pkg upgrade'
alias ros-info='neofetch'

# Welcome message
echo "Welcome to ROS - Roshan Operating System"
echo "Powered by Termux & Roshan"
echo "Type 'ros-help' for help or '/ai help' for AI assistance"
''';

    final bashrcFile = File('$_termuxHome/home/.bashrc');
    await bashrcFile.writeAsString(bashrc);
  }

  Future<void> _installEssentialPackages() async {
    debugPrint('Installing essential packages...');
    
    // In a real implementation, these would be actual package installations
    // For now, we'll just ensure the directory structure exists
    for (final package in AppConstants.essentialPackages) {
      debugPrint('Installing package: $package');
      // Simulate package installation
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // Execute Command
  Future<CommandResult> executeCommand(String command, {String? workingDirectory}) async {
    if (!_isInitialized) {
      throw Exception('Termux environment not initialized');
    }

    try {
      final shell = Shell(
        workingDirectory: workingDirectory ?? '$_termuxHome/home',
        environment: {
          'HOME': '$_termuxHome/home',
          'PREFIX': '$_termuxHome/usr',
          'PATH': '$_termuxBin:${Platform.environment['PATH'] ?? ''}',
          'TMPDIR': '$_termuxHome/tmp',
          'SHELL': '$_termuxBin/bash',
          'TERM': 'xterm-256color',
        },
      );

      final result = await shell.run(command);
      
      return CommandResult(
        command: command,
        exitCode: result.exitCode,
        stdout: result.stdout.toString(),
        stderr: result.stderr.toString(),
        workingDirectory: workingDirectory ?? '$_termuxHome/home',
      );
    } catch (e) {
      return CommandResult(
        command: command,
        exitCode: 1,
        stdout: '',
        stderr: e.toString(),
        workingDirectory: workingDirectory ?? '$_termuxHome/home',
      );
    }
  }

  // Start Interactive Session
  Future<Process> startInteractiveSession({String? workingDirectory}) async {
    if (!_isInitialized) {
      throw Exception('Termux environment not initialized');
    }

    final environment = {
      'HOME': '$_termuxHome/home',
      'PREFIX': '$_termuxHome/usr',
      'PATH': '$_termuxBin:${Platform.environment['PATH'] ?? ''}',
      'TMPDIR': '$_termuxHome/tmp',
      'SHELL': '$_termuxBin/bash',
      'TERM': 'xterm-256color',
    };

    final process = await Process.start(
      '$_termuxBin/bash',
      ['-i'],
      workingDirectory: workingDirectory ?? '$_termuxHome/home',
      environment: environment,
      mode: ProcessStartMode.normal,
    );

    // Forward output streams
    process.stdout.transform(utf8.decoder).listen((data) {
      _outputController.add(data);
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      _errorController.add(data);
    });

    _currentProcess = process;
    return process;
  }

  // Send Input to Current Process
  void sendInput(String input) {
    _currentProcess?.stdin.writeln(input);
  }

  // Kill Current Process
  Future<void> killCurrentProcess() async {
    if (_currentProcess != null) {
      _currentProcess!.kill();
      _currentProcess = null;
    }
  }

  // Package Management
  Future<List<TermuxPackage>> getAvailablePackages() async {
    // In a real implementation, this would query the Termux package repository
    return _generateMockPackages();
  }

  Future<List<TermuxPackage>> getInstalledPackages() async {
    // In a real implementation, this would check installed packages
    return AppConstants.essentialPackages.map((name) => TermuxPackage(
      name: name,
      version: '1.0.0',
      description: 'Essential package: $name',
      category: 'System',
      isInstalled: true,
      size: '1MB',
    )).toList();
  }

  Future<bool> installPackage(String packageName) async {
    try {
      debugPrint('Installing package: $packageName');
      
      // Simulate package installation
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real implementation, this would use pkg install
      final result = await executeCommand('echo "Installing $packageName..."');
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Failed to install package $packageName: $e');
      return false;
    }
  }

  Future<bool> uninstallPackage(String packageName) async {
    try {
      debugPrint('Uninstalling package: $packageName');
      
      // Simulate package uninstallation
      await Future.delayed(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      debugPrint('Failed to uninstall package $packageName: $e');
      return false;
    }
  }

  Future<bool> updatePackages() async {
    try {
      debugPrint('Updating packages...');
      
      // Simulate package update
      await Future.delayed(const Duration(seconds: 3));
      
      return true;
    } catch (e) {
      debugPrint('Failed to update packages: $e');
      return false;
    }
  }

  // File System Operations
  Future<List<FileSystemEntity>> listDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        return await dir.list().toList();
      }
      return [];
    } catch (e) {
      debugPrint('Failed to list directory $path: $e');
      return [];
    }
  }

  Future<String> readFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return '';
    } catch (e) {
      debugPrint('Failed to read file $path: $e');
      return '';
    }
  }

  Future<bool> writeFile(String path, String content) async {
    try {
      final file = File(path);
      await file.writeAsString(content);
      return true;
    } catch (e) {
      debugPrint('Failed to write file $path: $e');
      return false;
    }
  }

  // Environment Info
  TermuxEnvironment getEnvironmentInfo() {
    return TermuxEnvironment(
      home: _termuxHome,
      prefix: '$_termuxHome/usr',
      shell: '$_termuxBin/bash',
      path: '$_termuxBin:${Platform.environment['PATH'] ?? ''}',
      isInitialized: _isInitialized,
      installedPackages: AppConstants.essentialPackages.length,
    );
  }

  // Cleanup
  Future<void> dispose() async {
    await killCurrentProcess();
    await _outputController.close();
    await _errorController.close();
  }

  // Mock package data for demo
  List<TermuxPackage> _generateMockPackages() {
    final categories = AppConstants.packageCategories;
    final packages = <TermuxPackage>[];

    for (final category in categories) {
      for (int i = 1; i <= 10; i++) {
        packages.add(TermuxPackage(
          name: '${category.toLowerCase().replaceAll(' ', '-')}-tool-$i',
          version: '1.$i.0',
          description: 'A useful tool for $category development and operations',
          category: category,
          isInstalled: i <= 3, // First 3 are "installed"
          size: '${(i * 100).toStringAsFixed(0)}KB',
        ));
      }
    }

    return packages;
  }
}

// Command Result Model
class CommandResult {
  final String command;
  final int exitCode;
  final String stdout;
  final String stderr;
  final String workingDirectory;

  CommandResult({
    required this.command,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.workingDirectory,
  });

  bool get isSuccess => exitCode == 0;
  String get output => stdout.isNotEmpty ? stdout : stderr;
}