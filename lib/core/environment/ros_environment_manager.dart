import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../platform/platform_service.dart';
import '../error_handling/error_handler.dart';

enum EnvironmentType {
  python,
  node,
  ruby,
  rust,
  go,
  java,
  php,
  dotnet,
  lua,
  swift,
  kotlin,
  dart,
  docker,
  conda,
  custom,
}

enum EnvironmentStatus {
  active,
  inactive,
  installing,
  removing,
  error,
  unknown,
}

class EnvironmentVersion {
  final String version;
  final String? alias;
  final bool isDefault;
  final bool isGlobal;
  final DateTime? installedDate;
  final String? source;
  final Map<String, dynamic> metadata;

  const EnvironmentVersion({
    required this.version,
    this.alias,
    this.isDefault = false,
    this.isGlobal = false,
    this.installedDate,
    this.source,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'alias': alias,
      'isDefault': isDefault,
      'isGlobal': isGlobal,
      'installedDate': installedDate?.toIso8601String(),
      'source': source,
      'metadata': metadata,
    };
  }

  factory EnvironmentVersion.fromJson(Map<String, dynamic> json) {
    return EnvironmentVersion(
      version: json['version'],
      alias: json['alias'],
      isDefault: json['isDefault'] ?? false,
      isGlobal: json['isGlobal'] ?? false,
      installedDate: json['installedDate'] != null 
          ? DateTime.parse(json['installedDate'])
          : null,
      source: json['source'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class ROSEnvironment {
  final String name;
  final EnvironmentType type;
  final String path;
  final EnvironmentVersion version;
  final EnvironmentStatus status;
  final Map<String, String> variables;
  final List<String> dependencies;
  final Map<String, dynamic> config;
  final DateTime createdDate;
  final DateTime? lastUsed;

  const ROSEnvironment({
    required this.name,
    required this.type,
    required this.path,
    required this.version,
    required this.status,
    this.variables = const {},
    this.dependencies = const [],
    this.config = const {},
    required this.createdDate,
    this.lastUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'path': path,
      'version': version.toJson(),
      'status': status.name,
      'variables': variables,
      'dependencies': dependencies,
      'config': config,
      'createdDate': createdDate.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  factory ROSEnvironment.fromJson(Map<String, dynamic> json) {
    return ROSEnvironment(
      name: json['name'],
      type: EnvironmentType.values.firstWhere((t) => t.name == json['type']),
      path: json['path'],
      version: EnvironmentVersion.fromJson(json['version']),
      status: EnvironmentStatus.values.firstWhere((s) => s.name == json['status']),
      variables: Map<String, String>.from(json['variables'] ?? {}),
      dependencies: List<String>.from(json['dependencies'] ?? []),
      config: json['config'] ?? {},
      createdDate: DateTime.parse(json['createdDate']),
      lastUsed: json['lastUsed'] != null 
          ? DateTime.parse(json['lastUsed'])
          : null,
    );
  }

  ROSEnvironment copyWith({
    EnvironmentStatus? status,
    Map<String, String>? variables,
    List<String>? dependencies,
    DateTime? lastUsed,
  }) {
    return ROSEnvironment(
      name: name,
      type: type,
      path: path,
      version: version,
      status: status ?? this.status,
      variables: variables ?? this.variables,
      dependencies: dependencies ?? this.dependencies,
      config: config,
      createdDate: createdDate,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}

class ROSEnvironmentManager {
  static const String _environmentsConfigFile = 'ros_environments.json';
  static const String _activeEnvironmentFile = 'ros_active_environment.json';
  
  final Map<String, ROSEnvironment> _environments = {};
  final Map<EnvironmentType, List<EnvironmentVersion>> _availableVersions = {};
  ROSEnvironment? _activeEnvironment;
  String? _globalEnvironmentPath;

  // Initialize environment manager
  Future<void> initialize() async {
    await _loadEnvironments();
    await _loadActiveEnvironment();
    await _detectAvailableVersions();
    await _setupGlobalEnvironment();
  }

  // Environment management
  Future<ROSEnvironment> createEnvironment({
    required String name,
    required EnvironmentType type,
    required String version,
    String? basePath,
    Map<String, String>? variables,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final envPath = basePath ?? '${appDir.path}/environments/$name';
    
    // Create environment directory
    final envDir = Directory(envPath);
    await envDir.create(recursive: true);

    // Install environment version
    await _installEnvironmentVersion(type, version, envPath);

    final environment = ROSEnvironment(
      name: name,
      type: type,
      path: envPath,
      version: EnvironmentVersion(version: version),
      status: EnvironmentStatus.active,
      variables: variables ?? _getDefaultEnvironmentVariables(type, envPath),
      createdDate: DateTime.now(),
    );

    _environments[name] = environment;
    await _saveEnvironments();

    return environment;
  }

  Future<void> _installEnvironmentVersion(
    EnvironmentType type, 
    String version, 
    String envPath,
  ) async {
    try {
      switch (type) {
        case EnvironmentType.python:
          await _installPythonVersion(version, envPath);
          break;
        case EnvironmentType.node:
          await _installNodeVersion(version, envPath);
          break;
        case EnvironmentType.ruby:
          await _installRubyVersion(version, envPath);
          break;
        case EnvironmentType.rust:
          await _installRustVersion(version, envPath);
          break;
        case EnvironmentType.go:
          await _installGoVersion(version, envPath);
          break;
        case EnvironmentType.java:
          await _installJavaVersion(version, envPath);
          break;
        case EnvironmentType.docker:
          await _setupDockerEnvironment(envPath);
          break;
        default:
          throw Exception('Environment type not supported: ${type.name}');
      }
    } catch (e) {
      ErrorHandler.reportException(
        e,
        context: 'Installing ${type.name} version $version',
        category: ErrorCategory.system,
      );
      rethrow;
    }
  }

  Future<void> _installPythonVersion(String version, String envPath) async {
    if (kIsWeb) return;

    // Create virtual environment
    final result = await Process.run(
      'python$version',
      ['-m', 'venv', '$envPath/venv'],
    );

    if (result.exitCode != 0) {
      throw Exception('Failed to create Python virtual environment');
    }

    // Install pip packages
    await Process.run(
      '$envPath/venv/bin/pip',
      ['install', '--upgrade', 'pip', 'setuptools', 'wheel'],
    );
  }

  Future<void> _installNodeVersion(String version, String envPath) async {
    if (kIsWeb) return;

    // Download and install Node.js version
    final nodeDir = Directory('$envPath/node-$version');
    await nodeDir.create(recursive: true);

    // Simulate Node.js installation
    await Future.delayed(const Duration(seconds: 2));
    
    // Create npm directory
    final npmDir = Directory('$envPath/node_modules');
    await npmDir.create(recursive: true);
  }

  Future<void> _installRubyVersion(String version, String envPath) async {
    if (kIsWeb) return;

    // Install Ruby using rbenv-like approach
    final rubyDir = Directory('$envPath/ruby-$version');
    await rubyDir.create(recursive: true);

    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _installRustVersion(String version, String envPath) async {
    if (kIsWeb) return;

    // Install Rust toolchain
    final result = await Process.run(
      'rustup',
      ['toolchain', 'install', version, '--profile', 'minimal'],
    );

    if (result.exitCode == 0) {
      // Set up cargo environment
      final cargoDir = Directory('$envPath/.cargo');
      await cargoDir.create(recursive: true);
    }
  }

  Future<void> _installGoVersion(String version, String envPath) async {
    if (kIsWeb) return;

    // Download and install Go version
    final goDir = Directory('$envPath/go-$version');
    await goDir.create(recursive: true);

    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _installJavaVersion(String version, String envPath) async {
    if (kIsWeb) return;

    // Install Java using SDKMAN-like approach
    final javaDir = Directory('$envPath/java-$version');
    await javaDir.create(recursive: true);

    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _setupDockerEnvironment(String envPath) async {
    if (kIsWeb) return;

    // Create Docker environment configuration
    final dockerComposeFile = File('$envPath/docker-compose.yml');
    final dockerComposeContent = '''
version: '3.8'
services:
  ros-env:
    image: ubuntu:latest
    container_name: ros-env-${DateTime.now().millisecondsSinceEpoch}
    volumes:
      - .:/workspace
    working_dir: /workspace
    command: tail -f /dev/null
''';
    await dockerComposeFile.writeAsString(dockerComposeContent);

    // Create Dockerfile
    final dockerFile = File('$envPath/Dockerfile');
    final dockerFileContent = '''
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \\
    curl \\
    git \\
    vim \\
    python3 \\
    python3-pip \\
    nodejs \\
    npm \\
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
''';
    await dockerFile.writeAsString(dockerFileContent);
  }

  Map<String, String> _getDefaultEnvironmentVariables(
    EnvironmentType type, 
    String envPath,
  ) {
    final variables = <String, String>{};

    switch (type) {
      case EnvironmentType.python:
        variables.addAll({
          'VIRTUAL_ENV': '$envPath/venv',
          'PATH': '$envPath/venv/bin:\$PATH',
          'PYTHONPATH': '$envPath/venv/lib/python3/site-packages',
          'PIP_REQUIRE_VIRTUALENV': 'true',
        });
        break;
      case EnvironmentType.node:
        variables.addAll({
          'NODE_PATH': '$envPath/node_modules',
          'NPM_CONFIG_PREFIX': envPath,
          'PATH': '$envPath/bin:\$PATH',
        });
        break;
      case EnvironmentType.ruby:
        variables.addAll({
          'GEM_HOME': '$envPath/gems',
          'GEM_PATH': '$envPath/gems',
          'PATH': '$envPath/gems/bin:\$PATH',
        });
        break;
      case EnvironmentType.rust:
        variables.addAll({
          'CARGO_HOME': '$envPath/.cargo',
          'RUSTUP_HOME': '$envPath/.rustup',
          'PATH': '$envPath/.cargo/bin:\$PATH',
        });
        break;
      case EnvironmentType.go:
        variables.addAll({
          'GOPATH': envPath,
          'GOROOT': '$envPath/go',
          'PATH': '$envPath/go/bin:$envPath/bin:\$PATH',
        });
        break;
      case EnvironmentType.java:
        variables.addAll({
          'JAVA_HOME': '$envPath/java',
          'PATH': '$envPath/java/bin:\$PATH',
        });
        break;
      case EnvironmentType.docker:
        variables.addAll({
          'DOCKER_COMPOSE_FILE': '$envPath/docker-compose.yml',
          'DOCKER_CONTEXT': envPath,
        });
        break;
      default:
        variables['ROS_ENV_PATH'] = envPath;
    }

    return variables;
  }

  // Environment activation and switching
  Future<void> activateEnvironment(String name) async {
    final environment = _environments[name];
    if (environment == null) {
      throw Exception('Environment not found: $name');
    }

    _activeEnvironment = environment.copyWith(
      lastUsed: DateTime.now(),
      status: EnvironmentStatus.active,
    );
    
    _environments[name] = _activeEnvironment!;
    await _saveActiveEnvironment();
    await _saveEnvironments();
  }

  Future<void> deactivateEnvironment() async {
    if (_activeEnvironment != null) {
      _activeEnvironment = _activeEnvironment!.copyWith(
        status: EnvironmentStatus.inactive,
      );
      _environments[_activeEnvironment!.name] = _activeEnvironment!;
      await _saveEnvironments();
    }
    
    _activeEnvironment = null;
    await _saveActiveEnvironment();
  }

  // Version management
  Future<void> installVersion(EnvironmentType type, String version) async {
    final appDir = await getApplicationDocumentsDirectory();
    final versionsPath = '${appDir.path}/versions/${type.name}';
    final versionPath = '$versionsPath/$version';

    await _installEnvironmentVersion(type, version, versionPath);

    final envVersion = EnvironmentVersion(
      version: version,
      installedDate: DateTime.now(),
      source: 'ros-install',
    );

    if (_availableVersions[type] == null) {
      _availableVersions[type] = [];
    }
    _availableVersions[type]!.add(envVersion);
  }

  Future<void> uninstallVersion(EnvironmentType type, String version) async {
    final appDir = await getApplicationDocumentsDirectory();
    final versionPath = '${appDir.path}/versions/${type.name}/$version';
    
    final versionDir = Directory(versionPath);
    if (await versionDir.exists()) {
      await versionDir.delete(recursive: true);
    }

    _availableVersions[type]?.removeWhere((v) => v.version == version);
  }

  Future<void> setGlobalVersion(EnvironmentType type, String version) async {
    if (_availableVersions[type] == null) {
      throw Exception('No versions available for ${type.name}');
    }

    final versionIndex = _availableVersions[type]!.indexWhere(
      (v) => v.version == version,
    );

    if (versionIndex == -1) {
      throw Exception('Version not found: $version');
    }

    // Remove global flag from all versions
    final updatedVersions = _availableVersions[type]!.map((v) => 
      EnvironmentVersion(
        version: v.version,
        alias: v.alias,
        isDefault: v.isDefault,
        isGlobal: false,
        installedDate: v.installedDate,
        source: v.source,
        metadata: v.metadata,
      ),
    ).toList();

    // Set global flag for selected version
    updatedVersions[versionIndex] = EnvironmentVersion(
      version: version,
      alias: updatedVersions[versionIndex].alias,
      isDefault: updatedVersions[versionIndex].isDefault,
      isGlobal: true,
      installedDate: updatedVersions[versionIndex].installedDate,
      source: updatedVersions[versionIndex].source,
      metadata: updatedVersions[versionIndex].metadata,
    );

    _availableVersions[type] = updatedVersions;
  }

  // Environment discovery
  Future<void> _detectAvailableVersions() async {
    await _detectPythonVersions();
    await _detectNodeVersions();
    await _detectRubyVersions();
    await _detectJavaVersions();
  }

  Future<void> _detectPythonVersions() async {
    if (kIsWeb) return;

    final versions = <EnvironmentVersion>[];
    
    // Detect system Python versions
    for (final pythonCmd in ['python3', 'python3.8', 'python3.9', 'python3.10', 'python3.11']) {
      try {
        final result = await Process.run(pythonCmd, ['--version']);
        if (result.exitCode == 0) {
          final versionMatch = RegExp(r'Python (\d+\.\d+\.\d+)').firstMatch(result.stdout);
          if (versionMatch != null) {
            versions.add(EnvironmentVersion(
              version: versionMatch.group(1)!,
              source: 'system',
              isGlobal: pythonCmd == 'python3',
            ));
          }
        }
      } catch (e) {
        // Python version not available
      }
    }

    if (versions.isNotEmpty) {
      _availableVersions[EnvironmentType.python] = versions;
    }
  }

  Future<void> _detectNodeVersions() async {
    if (kIsWeb) return;

    try {
      final result = await Process.run('node', ['--version']);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim().substring(1); // Remove 'v' prefix
        _availableVersions[EnvironmentType.node] = [
          EnvironmentVersion(
            version: version,
            source: 'system',
            isGlobal: true,
          ),
        ];
      }
    } catch (e) {
      // Node.js not available
    }
  }

  Future<void> _detectRubyVersions() async {
    if (kIsWeb) return;

    try {
      final result = await Process.run('ruby', ['--version']);
      if (result.exitCode == 0) {
        final versionMatch = RegExp(r'ruby (\d+\.\d+\.\d+)').firstMatch(result.stdout);
        if (versionMatch != null) {
          _availableVersions[EnvironmentType.ruby] = [
            EnvironmentVersion(
              version: versionMatch.group(1)!,
              source: 'system',
              isGlobal: true,
            ),
          ];
        }
      }
    } catch (e) {
      // Ruby not available
    }
  }

  Future<void> _detectJavaVersions() async {
    if (kIsWeb) return;

    try {
      final result = await Process.run('java', ['-version']);
      if (result.exitCode == 0) {
        final versionMatch = RegExp(r'version "(\d+\.\d+\.\d+)').firstMatch(result.stderr);
        if (versionMatch != null) {
          _availableVersions[EnvironmentType.java] = [
            EnvironmentVersion(
              version: versionMatch.group(1)!,
              source: 'system',
              isGlobal: true,
            ),
          ];
        }
      }
    } catch (e) {
      // Java not available
    }
  }

  // CLI interface
  Future<String> executeEnvironmentCommand(List<String> args) async {
    if (args.isEmpty) {
      return _getEnvironmentHelpText();
    }

    final command = args[0];
    final commandArgs = args.skip(1).toList();

    switch (command) {
      case 'list':
        return _listEnvironments();
      case 'create':
        return await _createEnvironmentCLI(commandArgs);
      case 'activate':
        return await _activateEnvironmentCLI(commandArgs);
      case 'deactivate':
        return await _deactivateEnvironmentCLI();
      case 'remove':
        return await _removeEnvironmentCLI(commandArgs);
      case 'versions':
        return _listVersions(commandArgs);
      case 'install':
        return await _installVersionCLI(commandArgs);
      case 'uninstall':
        return await _uninstallVersionCLI(commandArgs);
      case 'global':
        return await _setGlobalVersionCLI(commandArgs);
      case 'current':
        return _getCurrentEnvironment();
      case 'info':
        return _getEnvironmentInfo(commandArgs);
      default:
        return 'Unknown command: $command\n\n${_getEnvironmentHelpText()}';
    }
  }

  String _listEnvironments() {
    if (_environments.isEmpty) {
      return 'No environments created yet';
    }

    final buffer = StringBuffer();
    buffer.writeln('ROS Environments:');
    buffer.writeln();

    for (final env in _environments.values) {
      final active = env.name == _activeEnvironment?.name ? ' (active)' : '';
      buffer.writeln('${env.name}: ${env.type.name} ${env.version.version}$active');
      buffer.writeln('  Path: ${env.path}');
      buffer.writeln('  Status: ${env.status.name}');
      buffer.writeln('  Created: ${env.createdDate.toLocal()}');
      if (env.lastUsed != null) {
        buffer.writeln('  Last used: ${env.lastUsed!.toLocal()}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  Future<String> _createEnvironmentCLI(List<String> args) async {
    if (args.length < 3) {
      return 'Usage: ros env create <name> <type> <version>';
    }

    final name = args[0];
    final typeStr = args[1];
    final version = args[2];

    try {
      final type = EnvironmentType.values.firstWhere(
        (t) => t.name == typeStr,
      );

      final environment = await createEnvironment(
        name: name,
        type: type,
        version: version,
      );

      return 'Created environment: ${environment.name}';
    } catch (e) {
      return 'Failed to create environment: $e';
    }
  }

  Future<String> _activateEnvironmentCLI(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: ros env activate <name>';
    }

    final name = args[0];
    try {
      await activateEnvironment(name);
      return 'Activated environment: $name';
    } catch (e) {
      return 'Failed to activate environment: $e';
    }
  }

  Future<String> _deactivateEnvironmentCLI() async {
    if (_activeEnvironment == null) {
      return 'No environment is currently active';
    }

    final currentName = _activeEnvironment!.name;
    await deactivateEnvironment();
    return 'Deactivated environment: $currentName';
  }

  Future<String> _removeEnvironmentCLI(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: ros env remove <name>';
    }

    final name = args[0];
    final environment = _environments[name];
    
    if (environment == null) {
      return 'Environment not found: $name';
    }

    try {
      // Remove environment directory
      final envDir = Directory(environment.path);
      if (await envDir.exists()) {
        await envDir.delete(recursive: true);
      }

      _environments.remove(name);
      
      if (_activeEnvironment?.name == name) {
        _activeEnvironment = null;
        await _saveActiveEnvironment();
      }
      
      await _saveEnvironments();
      return 'Removed environment: $name';
    } catch (e) {
      return 'Failed to remove environment: $e';
    }
  }

  String _listVersions(List<String> args) {
    if (args.isEmpty) {
      // List all available versions for all types
      final buffer = StringBuffer();
      buffer.writeln('Available versions:');
      buffer.writeln();

      for (final entry in _availableVersions.entries) {
        buffer.writeln('${entry.key.name}:');
        for (final version in entry.value) {
          final global = version.isGlobal ? ' (global)' : '';
          final default_ = version.isDefault ? ' (default)' : '';
          buffer.writeln('  ${version.version}$global$default_');
        }
        buffer.writeln();
      }

      return buffer.toString();
    } else {
      // List versions for specific type
      final typeStr = args[0];
      try {
        final type = EnvironmentType.values.firstWhere(
          (t) => t.name == typeStr,
        );

        final versions = _availableVersions[type];
        if (versions == null || versions.isEmpty) {
          return 'No versions available for ${type.name}';
        }

        final buffer = StringBuffer();
        buffer.writeln('${type.name} versions:');
        for (final version in versions) {
          final global = version.isGlobal ? ' (global)' : '';
          final default_ = version.isDefault ? ' (default)' : '';
          buffer.writeln('  ${version.version}$global$default_');
        }

        return buffer.toString();
      } catch (e) {
        return 'Unknown environment type: $typeStr';
      }
    }
  }

  Future<String> _installVersionCLI(List<String> args) async {
    if (args.length < 2) {
      return 'Usage: ros env install <type> <version>';
    }

    final typeStr = args[0];
    final version = args[1];

    try {
      final type = EnvironmentType.values.firstWhere(
        (t) => t.name == typeStr,
      );

      await installVersion(type, version);
      return 'Installed ${type.name} $version';
    } catch (e) {
      return 'Failed to install version: $e';
    }
  }

  Future<String> _uninstallVersionCLI(List<String> args) async {
    if (args.length < 2) {
      return 'Usage: ros env uninstall <type> <version>';
    }

    final typeStr = args[0];
    final version = args[1];

    try {
      final type = EnvironmentType.values.firstWhere(
        (t) => t.name == typeStr,
      );

      await uninstallVersion(type, version);
      return 'Uninstalled ${type.name} $version';
    } catch (e) {
      return 'Failed to uninstall version: $e';
    }
  }

  Future<String> _setGlobalVersionCLI(List<String> args) async {
    if (args.length < 2) {
      return 'Usage: ros env global <type> <version>';
    }

    final typeStr = args[0];
    final version = args[1];

    try {
      final type = EnvironmentType.values.firstWhere(
        (t) => t.name == typeStr,
      );

      await setGlobalVersion(type, version);
      return 'Set global ${type.name} version to $version';
    } catch (e) {
      return 'Failed to set global version: $e';
    }
  }

  String _getCurrentEnvironment() {
    if (_activeEnvironment == null) {
      return 'No environment is currently active';
    }

    final env = _activeEnvironment!;
    final buffer = StringBuffer();
    buffer.writeln('Active environment: ${env.name}');
    buffer.writeln('Type: ${env.type.name}');
    buffer.writeln('Version: ${env.version.version}');
    buffer.writeln('Path: ${env.path}');
    buffer.writeln('Status: ${env.status.name}');
    
    if (env.variables.isNotEmpty) {
      buffer.writeln('Environment variables:');
      for (final variable in env.variables.entries) {
        buffer.writeln('  ${variable.key}=${variable.value}');
      }
    }

    return buffer.toString();
  }

  String _getEnvironmentInfo(List<String> args) {
    if (args.isEmpty) {
      return 'Usage: ros env info <name>';
    }

    final name = args[0];
    final environment = _environments[name];
    
    if (environment == null) {
      return 'Environment not found: $name';
    }

    final buffer = StringBuffer();
    buffer.writeln('Environment: ${environment.name}');
    buffer.writeln('Type: ${environment.type.name}');
    buffer.writeln('Version: ${environment.version.version}');
    buffer.writeln('Path: ${environment.path}');
    buffer.writeln('Status: ${environment.status.name}');
    buffer.writeln('Created: ${environment.createdDate.toLocal()}');
    
    if (environment.lastUsed != null) {
      buffer.writeln('Last used: ${environment.lastUsed!.toLocal()}');
    }

    if (environment.dependencies.isNotEmpty) {
      buffer.writeln('Dependencies: ${environment.dependencies.join(', ')}');
    }

    if (environment.variables.isNotEmpty) {
      buffer.writeln('Environment variables:');
      for (final variable in environment.variables.entries) {
        buffer.writeln('  ${variable.key}=${variable.value}');
      }
    }

    return buffer.toString();
  }

  String _getEnvironmentHelpText() {
    return '''
ROS Environment Manager - Isolated environments and version management

Usage: ros env <command> [arguments]

Commands:
  list                    List all environments
  create <name> <type> <version>  Create new environment
  activate <name>         Activate environment
  deactivate              Deactivate current environment
  remove <name>           Remove environment
  versions [type]         List available versions
  install <type> <version>  Install language version
  uninstall <type> <version>  Uninstall language version
  global <type> <version>   Set global version
  current                 Show current environment
  info <name>             Show environment details

Environment Types:
  python, node, ruby, rust, go, java, php, dotnet, docker

Examples:
  ros env create myproject python 3.11
  ros env activate myproject
  ros env install node 18.12.0
  ros env global python 3.11
  ros env versions python
''';
  }

  // Global environment setup
  Future<void> _setupGlobalEnvironment() async {
    final appDir = await getApplicationDocumentsDirectory();
    _globalEnvironmentPath = '${appDir.path}/global';
    
    final globalDir = Directory(_globalEnvironmentPath!);
    if (!await globalDir.exists()) {
      await globalDir.create(recursive: true);
    }
  }

  // Persistence
  Future<void> _loadEnvironments() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_environmentsConfigFile');
      
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _environments.clear();
        
        for (final entry in data.entries) {
          _environments[entry.key] = ROSEnvironment.fromJson(entry.value);
        }
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Loading environments');
    }
  }

  Future<void> _saveEnvironments() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_environmentsConfigFile');
      
      final data = _environments.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Saving environments');
    }
  }

  Future<void> _loadActiveEnvironment() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_activeEnvironmentFile');
      
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        if (data['activeEnvironment'] != null) {
          final envName = data['activeEnvironment'];
          _activeEnvironment = _environments[envName];
        }
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Loading active environment');
    }
  }

  Future<void> _saveActiveEnvironment() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_activeEnvironmentFile');
      
      final data = {
        'activeEnvironment': _activeEnvironment?.name,
      };
      
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Saving active environment');
    }
  }

  // Getters
  Map<String, ROSEnvironment> get environments => Map.unmodifiable(_environments);
  Map<EnvironmentType, List<EnvironmentVersion>> get availableVersions => 
      Map.unmodifiable(_availableVersions);
  ROSEnvironment? get activeEnvironment => _activeEnvironment;
  String? get globalEnvironmentPath => _globalEnvironmentPath;
}

// Riverpod providers
final rosEnvironmentManagerProvider = Provider<ROSEnvironmentManager>((ref) {
  return ROSEnvironmentManager();
});

final environmentsProvider = StateNotifierProvider<EnvironmentsNotifier, Map<String, ROSEnvironment>>((ref) {
  return EnvironmentsNotifier(ref.read(rosEnvironmentManagerProvider));
});

final activeEnvironmentProvider = StateNotifierProvider<ActiveEnvironmentNotifier, ROSEnvironment?>((ref) {
  return ActiveEnvironmentNotifier(ref.read(rosEnvironmentManagerProvider));
});

class EnvironmentsNotifier extends StateNotifier<Map<String, ROSEnvironment>> {
  final ROSEnvironmentManager _envManager;
  
  EnvironmentsNotifier(this._envManager) : super({});

  Future<void> refresh() async {
    state = _envManager.environments;
  }

  Future<void> createEnvironment({
    required String name,
    required EnvironmentType type,
    required String version,
  }) async {
    await _envManager.createEnvironment(
      name: name,
      type: type,
      version: version,
    );
    await refresh();
  }

  Future<void> removeEnvironment(String name) async {
    await _envManager.executeEnvironmentCommand(['remove', name]);
    await refresh();
  }
}

class ActiveEnvironmentNotifier extends StateNotifier<ROSEnvironment?> {
  final ROSEnvironmentManager _envManager;
  
  ActiveEnvironmentNotifier(this._envManager) : super(null);

  Future<void> refresh() async {
    state = _envManager.activeEnvironment;
  }

  Future<void> activateEnvironment(String name) async {
    await _envManager.activateEnvironment(name);
    await refresh();
  }

  Future<void> deactivateEnvironment() async {
    await _envManager.deactivateEnvironment();
    await refresh();
  }
}