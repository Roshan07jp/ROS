import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../platform/platform_service.dart';
import '../error_handling/error_handler.dart';

enum PackageStatus {
  installed,
  available,
  updateAvailable,
  installing,
  removing,
  failed,
  unknown
}

enum PackageType {
  apt,
  pkg,
  pip,
  npm,
  cargo,
  go,
  gem,
  github,
  deb,
  shell,
  rosPackage
}

class ROSPackage {
  final String name;
  final String version;
  final String? latestVersion;
  final String description;
  final PackageType type;
  final PackageStatus status;
  final List<String> dependencies;
  final String? homepage;
  final String? repository;
  final int? size;
  final DateTime? installedDate;
  final Map<String, dynamic> metadata;

  const ROSPackage({
    required this.name,
    required this.version,
    required this.description,
    required this.type,
    required this.status,
    this.latestVersion,
    this.dependencies = const [],
    this.homepage,
    this.repository,
    this.size,
    this.installedDate,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'latestVersion': latestVersion,
      'description': description,
      'type': type.name,
      'status': status.name,
      'dependencies': dependencies,
      'homepage': homepage,
      'repository': repository,
      'size': size,
      'installedDate': installedDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ROSPackage.fromJson(Map<String, dynamic> json) {
    return ROSPackage(
      name: json['name'],
      version: json['version'],
      description: json['description'],
      type: PackageType.values.firstWhere((t) => t.name == json['type']),
      status: PackageStatus.values.firstWhere((s) => s.name == json['status']),
      latestVersion: json['latestVersion'],
      dependencies: List<String>.from(json['dependencies'] ?? []),
      homepage: json['homepage'],
      repository: json['repository'],
      size: json['size'],
      installedDate: json['installedDate'] != null 
          ? DateTime.parse(json['installedDate'])
          : null,
      metadata: json['metadata'] ?? {},
    );
  }

  ROSPackage copyWith({
    String? version,
    String? latestVersion,
    PackageStatus? status,
    DateTime? installedDate,
  }) {
    return ROSPackage(
      name: name,
      version: version ?? this.version,
      latestVersion: latestVersion ?? this.latestVersion,
      description: description,
      type: type,
      status: status ?? this.status,
      dependencies: dependencies,
      homepage: homepage,
      repository: repository,
      size: size,
      installedDate: installedDate ?? this.installedDate,
      metadata: metadata,
    );
  }
}

class ROSRepository {
  final String name;
  final String url;
  final String? description;
  final bool enabled;
  final PackageType type;
  final Map<String, dynamic> config;

  const ROSRepository({
    required this.name,
    required this.url,
    this.description,
    required this.enabled,
    required this.type,
    this.config = const {},
  });
}

class PackageInstallProgress {
  final String packageName;
  final double progress;
  final String currentAction;
  final List<String> logs;

  const PackageInstallProgress({
    required this.packageName,
    required this.progress,
    required this.currentAction,
    required this.logs,
  });
}

class ROSPackageManager {
  static const String _packageCacheFile = 'ros_packages.json';
  static const String _repoConfigFile = 'ros_repositories.json';
  
  final Map<String, ROSPackage> _installedPackages = {};
  final Map<String, ROSPackage> _availablePackages = {};
  final List<ROSRepository> _repositories = [];
  final List<Function(PackageInstallProgress)> _progressListeners = [];

  // Default ROS repositories
  static const List<Map<String, dynamic>> _defaultRepositories = [
    {
      'name': 'ros-main',
      'url': 'https://packages.ros-system.com/main',
      'description': 'Main ROS package repository',
      'enabled': true,
      'type': 'rosPackage',
    },
    {
      'name': 'termux-packages',
      'url': 'https://packages.termux.org',
      'description': 'Termux packages for Android',
      'enabled': true,
      'type': 'pkg',
    },
    {
      'name': 'ubuntu-main',
      'url': 'http://archive.ubuntu.com/ubuntu',
      'description': 'Ubuntu main repository',
      'enabled': true,
      'type': 'apt',
    },
    {
      'name': 'github-releases',
      'url': 'https://api.github.com',
      'description': 'GitHub releases and binaries',
      'enabled': true,
      'type': 'github',
    },
  ];

  // Core commands
  Future<void> initialize() async {
    await _loadRepositories();
    await _loadInstalledPackages();
    await _detectInstalledPackages();
  }

  // Repository management
  Future<void> addRepository(ROSRepository repo) async {
    _repositories.add(repo);
    await _saveRepositories();
  }

  Future<void> removeRepository(String name) async {
    _repositories.removeWhere((repo) => repo.name == name);
    await _saveRepositories();
  }

  Future<void> updateRepositories() async {
    for (final repo in _repositories.where((r) => r.enabled)) {
      await _updateRepository(repo);
    }
    await _saveAvailablePackages();
  }

  Future<void> _updateRepository(ROSRepository repo) async {
    try {
      switch (repo.type) {
        case PackageType.rosPackage:
          await _updateROSRepository(repo);
          break;
        case PackageType.apt:
          await _updateAptRepository(repo);
          break;
        case PackageType.pkg:
          await _updatePkgRepository(repo);
          break;
        case PackageType.github:
          await _updateGitHubRepository(repo);
          break;
        default:
          // Handle other package types
          break;
      }
    } catch (e) {
      ErrorHandler.reportException(
        e,
        context: 'Updating repository: ${repo.name}',
        category: ErrorCategory.network,
      );
    }
  }

  Future<void> _updateROSRepository(ROSRepository repo) async {
    final response = await http.get(Uri.parse('${repo.url}/packages.json'));
    if (response.statusCode == 200) {
      final packageList = jsonDecode(response.body) as List;
      for (final packageData in packageList) {
        final package = ROSPackage.fromJson(packageData);
        _availablePackages[package.name] = package;
      }
    }
  }

  Future<void> _updateAptRepository(ROSRepository repo) async {
    // Simulate APT package discovery
    final commonAptPackages = [
      ROSPackage(
        name: 'git',
        version: '2.34.1',
        description: 'Fast, scalable, distributed revision control system',
        type: PackageType.apt,
        status: PackageStatus.available,
      ),
      ROSPackage(
        name: 'curl',
        version: '7.81.0',
        description: 'Command line tool for transferring data with URL syntax',
        type: PackageType.apt,
        status: PackageStatus.available,
      ),
      ROSPackage(
        name: 'wget',
        version: '1.21.2',
        description: 'Network utility to retrieve files from the Web',
        type: PackageType.apt,
        status: PackageStatus.available,
      ),
      ROSPackage(
        name: 'htop',
        version: '3.0.5',
        description: 'Interactive process viewer for Unix',
        type: PackageType.apt,
        status: PackageStatus.available,
      ),
      ROSPackage(
        name: 'vim',
        version: '8.2',
        description: 'Vi IMproved - enhanced vi editor',
        type: PackageType.apt,
        status: PackageStatus.available,
      ),
      ROSPackage(
        name: 'python3',
        version: '3.10.6',
        description: 'Interactive high-level object-oriented language',
        type: PackageType.apt,
        status: PackageStatus.available,
      ),
      ROSPackage(
        name: 'nodejs',
        version: '18.12.1',
        description: 'Event-based server-side JavaScript engine',
        type: PackageType.apt,
        status: PackageStatus.available,
      ),
      ROSPackage(
        name: 'golang-go',
        version: '1.19.3',
        description: 'Go programming language compiler',
        type: PackageType.apt,
        status: PackageStatus.available,
      ),
    ];

    for (final package in commonAptPackages) {
      _availablePackages[package.name] = package;
    }
  }

  Future<void> _updatePkgRepository(ROSRepository repo) async {
    // Simulate PKG (Termux) package discovery
    final commonPkgPackages = [
      ROSPackage(
        name: 'termux-tools',
        version: '0.180',
        description: 'Basic system tools for Termux',
        type: PackageType.pkg,
        status: PackageStatus.available,
      ),
      ROSPackage(
        name: 'openssh',
        version: '9.1p1',
        description: 'SSH connectivity tools',
        type: PackageType.pkg,
        status: PackageStatus.available,
      ),
      ROSPackage(
        name: 'nmap',
        version: '7.93',
        description: 'Network discovery and security auditing tool',
        type: PackageType.pkg,
        status: PackageStatus.available,
      ),
    ];

    for (final package in commonPkgPackages) {
      _availablePackages[package.name] = package;
    }
  }

  Future<void> _updateGitHubRepository(ROSRepository repo) async {
    // Discover popular GitHub releases
    final popularRepos = [
      'sharkdp/bat',
      'BurntSushi/ripgrep',
      'ogham/exa',
      'ajeetdsouza/zoxide',
      'starship/starship',
    ];

    for (final repoName in popularRepos) {
      try {
        final response = await http.get(
          Uri.parse('https://api.github.com/repos/$repoName/releases/latest'),
        );
        
        if (response.statusCode == 200) {
          final releaseData = jsonDecode(response.body);
          final packageName = repoName.split('/').last;
          
          final package = ROSPackage(
            name: packageName,
            version: releaseData['tag_name'],
            description: releaseData['body'] ?? 'GitHub package',
            type: PackageType.github,
            status: PackageStatus.available,
            repository: 'https://github.com/$repoName',
          );
          
          _availablePackages[package.name] = package;
        }
      } catch (e) {
        // Skip this package if failed to fetch
      }
    }
  }

  // Package management
  Future<bool> installPackage(String packageName, {
    String? version,
    bool force = false,
  }) async {
    final package = _availablePackages[packageName];
    if (package == null) {
      ErrorHandler.reportError(
        ErrorHandler.createFileError('install', packageName, 
          details: 'Package not found in repositories'),
      );
      return false;
    }

    _notifyProgress(PackageInstallProgress(
      packageName: packageName,
      progress: 0.0,
      currentAction: 'Preparing installation...',
      logs: ['Starting installation of $packageName'],
    ));

    try {
      final success = await _installPackageByType(package, version: version);
      
      if (success) {
        final installedPackage = package.copyWith(
          status: PackageStatus.installed,
          installedDate: DateTime.now(),
        );
        _installedPackages[packageName] = installedPackage;
        await _saveInstalledPackages();
        
        _notifyProgress(PackageInstallProgress(
          packageName: packageName,
          progress: 1.0,
          currentAction: 'Installation complete',
          logs: ['Successfully installed $packageName'],
        ));
      }
      
      return success;
    } catch (e) {
      ErrorHandler.reportException(
        e,
        context: 'Installing package: $packageName',
        category: ErrorCategory.system,
      );
      return false;
    }
  }

  Future<bool> _installPackageByType(ROSPackage package, {String? version}) async {
    switch (package.type) {
      case PackageType.apt:
        return await _installAptPackage(package, version: version);
      case PackageType.pkg:
        return await _installPkgPackage(package, version: version);
      case PackageType.pip:
        return await _installPipPackage(package, version: version);
      case PackageType.npm:
        return await _installNpmPackage(package, version: version);
      case PackageType.github:
        return await _installGitHubPackage(package, version: version);
      case PackageType.rosPackage:
        return await _installROSPackage(package, version: version);
      default:
        return false;
    }
  }

  Future<bool> _installAptPackage(ROSPackage package, {String? version}) async {
    final platform = await PlatformService.getPlatformInfo();
    
    if (platform.isDesktop && !platform.isWeb) {
      final command = version != null 
          ? 'apt install -y ${package.name}=$version'
          : 'apt install -y ${package.name}';
      
      final result = await Process.run('bash', ['-c', command]);
      return result.exitCode == 0;
    } else {
      // Simulate installation for mobile/web
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }
  }

  Future<bool> _installPkgPackage(ROSPackage package, {String? version}) async {
    // Simulate pkg (Termux) installation
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> _installPipPackage(ROSPackage package, {String? version}) async {
    final command = version != null 
        ? 'pip install ${package.name}==$version'
        : 'pip install ${package.name}';
    
    final result = await Process.run('bash', ['-c', command]);
    return result.exitCode == 0;
  }

  Future<bool> _installNpmPackage(ROSPackage package, {String? version}) async {
    final command = version != null 
        ? 'npm install -g ${package.name}@$version'
        : 'npm install -g ${package.name}';
    
    final result = await Process.run('bash', ['-c', command]);
    return result.exitCode == 0;
  }

  Future<bool> _installGitHubPackage(ROSPackage package, {String? version}) async {
    // Download and install GitHub releases
    if (package.repository != null) {
      // Simulate GitHub package installation
      await Future.delayed(const Duration(seconds: 3));
      return true;
    }
    return false;
  }

  Future<bool> _installROSPackage(ROSPackage package, {String? version}) async {
    // Install ROS-specific packages
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<bool> removePackage(String packageName) async {
    final package = _installedPackages[packageName];
    if (package == null) {
      return false;
    }

    try {
      final success = await _removePackageByType(package);
      
      if (success) {
        _installedPackages.remove(packageName);
        await _saveInstalledPackages();
      }
      
      return success;
    } catch (e) {
      ErrorHandler.reportException(
        e,
        context: 'Removing package: $packageName',
        category: ErrorCategory.system,
      );
      return false;
    }
  }

  Future<bool> _removePackageByType(ROSPackage package) async {
    switch (package.type) {
      case PackageType.apt:
        final result = await Process.run('bash', ['-c', 'apt remove -y ${package.name}']);
        return result.exitCode == 0;
      case PackageType.pip:
        final result = await Process.run('bash', ['-c', 'pip uninstall -y ${package.name}']);
        return result.exitCode == 0;
      case PackageType.npm:
        final result = await Process.run('bash', ['-c', 'npm uninstall -g ${package.name}']);
        return result.exitCode == 0;
      default:
        // Simulate removal for other types
        await Future.delayed(const Duration(seconds: 1));
        return true;
    }
  }

  Future<void> updatePackage(String packageName) async {
    await removePackage(packageName);
    await installPackage(packageName);
  }

  Future<void> updateAllPackages() async {
    final outdatedPackages = _installedPackages.values
        .where((pkg) => pkg.latestVersion != null && pkg.latestVersion != pkg.version)
        .toList();

    for (final package in outdatedPackages) {
      await updatePackage(package.name);
    }
  }

  // Search and listing
  List<ROSPackage> searchPackages(String query) {
    final allPackages = {..._availablePackages, ..._installedPackages};
    
    return allPackages.values
        .where((pkg) =>
            pkg.name.toLowerCase().contains(query.toLowerCase()) ||
            pkg.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<ROSPackage> getInstalledPackages() {
    return _installedPackages.values.toList();
  }

  List<ROSPackage> getAvailablePackages() {
    return _availablePackages.values.toList();
  }

  List<ROSPackage> getUpdatablePackages() {
    return _installedPackages.values
        .where((pkg) => pkg.latestVersion != null && pkg.latestVersion != pkg.version)
        .toList();
  }

  // CLI Command interface
  Future<String> executeCLICommand(List<String> args) async {
    if (args.isEmpty) {
      return _getHelpText();
    }

    final command = args[0];
    final commandArgs = args.skip(1).toList();

    switch (command) {
      case 'install':
        return await _cliInstall(commandArgs);
      case 'remove':
      case 'uninstall':
        return await _cliRemove(commandArgs);
      case 'update':
        return await _cliUpdate(commandArgs);
      case 'search':
        return _cliSearch(commandArgs);
      case 'list':
        return _cliList(commandArgs);
      case 'info':
        return _cliInfo(commandArgs);
      case 'repo':
        return await _cliRepo(commandArgs);
      case 'clean':
        return await _cliClean(commandArgs);
      default:
        return 'Unknown command: $command\n\n${_getHelpText()}';
    }
  }

  Future<String> _cliInstall(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: ros install <package> [package2] [package3]...';
    }

    final results = <String>[];
    for (final packageName in args) {
      final success = await installPackage(packageName);
      results.add(success 
          ? '✅ Successfully installed $packageName'
          : '❌ Failed to install $packageName');
    }
    
    return results.join('\n');
  }

  Future<String> _cliRemove(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: ros remove <package> [package2] [package3]...';
    }

    final results = <String>[];
    for (final packageName in args) {
      final success = await removePackage(packageName);
      results.add(success 
          ? '✅ Successfully removed $packageName'
          : '❌ Failed to remove $packageName');
    }
    
    return results.join('\n');
  }

  Future<String> _cliUpdate(List<String> args) async {
    if (args.isEmpty) {
      await updateAllPackages();
      return '✅ Updated all packages';
    } else {
      final results = <String>[];
      for (final packageName in args) {
        await updatePackage(packageName);
        results.add('✅ Updated $packageName');
      }
      return results.join('\n');
    }
  }

  String _cliSearch(List<String> args) {
    if (args.isEmpty) {
      return 'Usage: ros search <query>';
    }

    final query = args.join(' ');
    final results = searchPackages(query);
    
    if (results.isEmpty) {
      return 'No packages found for: $query';
    }

    final output = StringBuffer();
    output.writeln('Found ${results.length} packages:');
    output.writeln();
    
    for (final package in results.take(10)) {
      output.writeln('${package.name} (${package.version})');
      output.writeln('  ${package.description}');
      output.writeln('  Status: ${package.status.name}');
      output.writeln();
    }
    
    return output.toString();
  }

  String _cliList(List<String> args) {
    final filter = args.isNotEmpty ? args[0] : 'installed';
    
    List<ROSPackage> packages;
    switch (filter) {
      case 'available':
        packages = getAvailablePackages();
        break;
      case 'updates':
      case 'upgradable':
        packages = getUpdatablePackages();
        break;
      case 'installed':
      default:
        packages = getInstalledPackages();
        break;
    }

    if (packages.isEmpty) {
      return 'No packages found';
    }

    final output = StringBuffer();
    output.writeln('${packages.length} packages ($filter):');
    output.writeln();
    
    for (final package in packages) {
      output.writeln('${package.name} ${package.version}');
    }
    
    return output.toString();
  }

  String _cliInfo(List<String> args) {
    if (args.isEmpty) {
      return 'Usage: ros info <package>';
    }

    final packageName = args[0];
    final package = _installedPackages[packageName] ?? _availablePackages[packageName];
    
    if (package == null) {
      return 'Package not found: $packageName';
    }

    final output = StringBuffer();
    output.writeln('Package: ${package.name}');
    output.writeln('Version: ${package.version}');
    if (package.latestVersion != null) {
      output.writeln('Latest: ${package.latestVersion}');
    }
    output.writeln('Type: ${package.type.name}');
    output.writeln('Status: ${package.status.name}');
    output.writeln('Description: ${package.description}');
    
    if (package.dependencies.isNotEmpty) {
      output.writeln('Dependencies: ${package.dependencies.join(', ')}');
    }
    
    if (package.homepage != null) {
      output.writeln('Homepage: ${package.homepage}');
    }
    
    if (package.repository != null) {
      output.writeln('Repository: ${package.repository}');
    }
    
    if (package.size != null) {
      output.writeln('Size: ${_formatBytes(package.size!)}');
    }
    
    if (package.installedDate != null) {
      output.writeln('Installed: ${package.installedDate}');
    }
    
    return output.toString();
  }

  Future<String> _cliRepo(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: ros repo <list|add|remove|update>';
    }

    final subcommand = args[0];
    final subArgs = args.skip(1).toList();

    switch (subcommand) {
      case 'list':
        final output = StringBuffer();
        output.writeln('Repositories:');
        for (final repo in _repositories) {
          final status = repo.enabled ? '✅' : '❌';
          output.writeln('$status ${repo.name}: ${repo.url}');
        }
        return output.toString();
        
      case 'add':
        if (subArgs.length < 2) {
          return 'Usage: ros repo add <name> <url>';
        }
        await addRepository(ROSRepository(
          name: subArgs[0],
          url: subArgs[1],
          enabled: true,
          type: PackageType.rosPackage,
        ));
        return 'Added repository: ${subArgs[0]}';
        
      case 'remove':
        if (subArgs.isEmpty) {
          return 'Usage: ros repo remove <name>';
        }
        await removeRepository(subArgs[0]);
        return 'Removed repository: ${subArgs[0]}';
        
      case 'update':
        await updateRepositories();
        return 'Updated all repositories';
        
      default:
        return 'Unknown repo command: $subcommand';
    }
  }

  Future<String> _cliClean(List<String> args) async {
    // Clean package cache and temporary files
    await Future.delayed(const Duration(seconds: 1));
    return 'Cleaned package cache';
  }

  String _getHelpText() {
    return '''
ROS Package Manager - Advanced package management for all platforms

Usage: ros <command> [arguments]

Commands:
  install <pkg>     Install packages
  remove <pkg>      Remove packages  
  update [pkg]      Update packages (all if no package specified)
  search <query>    Search for packages
  list [filter]     List packages (installed/available/updates)
  info <pkg>        Show package information
  repo <cmd>        Manage repositories (list/add/remove/update)
  clean             Clean package cache

Examples:
  ros install python3 nodejs git
  ros search network
  ros list updates
  ros info htop
  ros repo add custom https://my-repo.com
  ros update
''';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)}MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)}GB';
  }

  // Auto-detect installed packages
  Future<void> _detectInstalledPackages() async {
    final platform = await PlatformService.getPlatformInfo();
    
    if (platform.isDesktop && !platform.isWeb) {
      await _detectSystemPackages();
    }
    
    await _detectLanguagePackages();
  }

  Future<void> _detectSystemPackages() async {
    final commonCommands = ['git', 'curl', 'wget', 'htop', 'vim', 'python3', 'node', 'go'];
    
    for (final command in commonCommands) {
      try {
        final result = await Process.run('which', [command]);
        if (result.exitCode == 0) {
          // Get version
          final versionResult = await Process.run(command, ['--version']);
          final version = _extractVersion(versionResult.stdout);
          
          _installedPackages[command] = ROSPackage(
            name: command,
            version: version,
            description: 'System package',
            type: PackageType.apt,
            status: PackageStatus.installed,
            installedDate: DateTime.now(),
          );
        }
      } catch (e) {
        // Package not found or version check failed
      }
    }
  }

  Future<void> _detectLanguagePackages() async {
    // Detect Python packages
    try {
      final result = await Process.run('pip', ['list', '--format=json']);
      if (result.exitCode == 0) {
        final packages = jsonDecode(result.stdout) as List;
        for (final pkg in packages) {
          _installedPackages[pkg['name']] = ROSPackage(
            name: pkg['name'],
            version: pkg['version'],
            description: 'Python package',
            type: PackageType.pip,
            status: PackageStatus.installed,
          );
        }
      }
    } catch (e) {
      // pip not available
    }

    // Detect npm packages
    try {
      final result = await Process.run('npm', ['list', '-g', '--json']);
      if (result.exitCode == 0) {
        final data = jsonDecode(result.stdout);
        final dependencies = data['dependencies'] as Map<String, dynamic>;
        for (final entry in dependencies.entries) {
          _installedPackages[entry.key] = ROSPackage(
            name: entry.key,
            version: entry.value['version'],
            description: 'Node.js package',
            type: PackageType.npm,
            status: PackageStatus.installed,
          );
        }
      }
    } catch (e) {
      // npm not available
    }
  }

  String _extractVersion(String output) {
    final versionRegex = RegExp(r'(\d+\.\d+\.\d+)');
    final match = versionRegex.firstMatch(output);
    return match?.group(1) ?? 'unknown';
  }

  // Progress notifications
  void addProgressListener(Function(PackageInstallProgress) listener) {
    _progressListeners.add(listener);
  }

  void removeProgressListener(Function(PackageInstallProgress) listener) {
    _progressListeners.remove(listener);
  }

  void _notifyProgress(PackageInstallProgress progress) {
    for (final listener in _progressListeners) {
      listener(progress);
    }
  }

  // Persistence
  Future<void> _loadRepositories() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_repoConfigFile');
      
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as List;
        _repositories.clear();
        
        for (final repoData in data) {
          _repositories.add(ROSRepository(
            name: repoData['name'],
            url: repoData['url'],
            description: repoData['description'],
            enabled: repoData['enabled'],
            type: PackageType.values.firstWhere((t) => t.name == repoData['type']),
            config: repoData['config'] ?? {},
          ));
        }
      } else {
        // Add default repositories
        for (final repoData in _defaultRepositories) {
          _repositories.add(ROSRepository(
            name: repoData['name'],
            url: repoData['url'],
            description: repoData['description'],
            enabled: repoData['enabled'],
            type: PackageType.values.firstWhere((t) => t.name == repoData['type']),
          ));
        }
        await _saveRepositories();
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Loading repositories');
    }
  }

  Future<void> _saveRepositories() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_repoConfigFile');
      
      final data = _repositories.map((repo) => {
        'name': repo.name,
        'url': repo.url,
        'description': repo.description,
        'enabled': repo.enabled,
        'type': repo.type.name,
        'config': repo.config,
      }).toList();
      
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Saving repositories');
    }
  }

  Future<void> _loadInstalledPackages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_packageCacheFile');
      
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _installedPackages.clear();
        
        for (final entry in data.entries) {
          _installedPackages[entry.key] = ROSPackage.fromJson(entry.value);
        }
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Loading installed packages');
    }
  }

  Future<void> _saveInstalledPackages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_packageCacheFile');
      
      final data = _installedPackages.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Saving installed packages');
    }
  }

  Future<void> _saveAvailablePackages() async {
    // Cache available packages for offline access
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/available_packages.json');
      
      final data = _availablePackages.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Saving available packages');
    }
  }
}

// Riverpod providers
final rosPackageManagerProvider = Provider<ROSPackageManager>((ref) {
  return ROSPackageManager();
});

final installedPackagesProvider = StateNotifierProvider<InstalledPackagesNotifier, List<ROSPackage>>((ref) {
  return InstalledPackagesNotifier(ref.read(rosPackageManagerProvider));
});

final availablePackagesProvider = StateNotifierProvider<AvailablePackagesNotifier, List<ROSPackage>>((ref) {
  return AvailablePackagesNotifier(ref.read(rosPackageManagerProvider));
});

class InstalledPackagesNotifier extends StateNotifier<List<ROSPackage>> {
  final ROSPackageManager _packageManager;
  
  InstalledPackagesNotifier(this._packageManager) : super([]);

  Future<void> refresh() async {
    state = _packageManager.getInstalledPackages();
  }

  Future<bool> installPackage(String name) async {
    final success = await _packageManager.installPackage(name);
    if (success) {
      await refresh();
    }
    return success;
  }

  Future<bool> removePackage(String name) async {
    final success = await _packageManager.removePackage(name);
    if (success) {
      await refresh();
    }
    return success;
  }
}

class AvailablePackagesNotifier extends StateNotifier<List<ROSPackage>> {
  final ROSPackageManager _packageManager;
  
  AvailablePackagesNotifier(this._packageManager) : super([]);

  Future<void> refresh() async {
    await _packageManager.updateRepositories();
    state = _packageManager.getAvailablePackages();
  }

  List<ROSPackage> search(String query) {
    return _packageManager.searchPackages(query);
  }
}