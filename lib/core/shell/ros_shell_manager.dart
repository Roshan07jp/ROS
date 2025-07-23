import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../platform/platform_service.dart';
import '../error_handling/error_handler.dart';

enum ShellType {
  bash,
  zsh,
  fish,
  xonsh,
  nushell,
  powershell,
  cmd,
  sh,
  dash,
  ksh,
  tcsh,
  csh,
}

enum PromptTheme {
  default_,
  powerline,
  starship,
  ohMyZsh,
  pure,
  robbyrussell,
  agnoster,
  spaceship,
  minimal,
  simple,
  fancy,
  git,
  lambda,
  arrow,
  unicode,
}

class ShellConfiguration {
  final ShellType type;
  final String name;
  final String executable;
  final String configFile;
  final List<String> initCommands;
  final Map<String, String> environment;
  final PromptTheme promptTheme;
  final bool syntaxHighlighting;
  final bool autoSuggestions;
  final bool historySearch;
  final int historySize;
  final List<String> plugins;
  final Map<String, String> aliases;
  final Map<String, dynamic> customSettings;

  const ShellConfiguration({
    required this.type,
    required this.name,
    required this.executable,
    required this.configFile,
    this.initCommands = const [],
    this.environment = const {},
    this.promptTheme = PromptTheme.default_,
    this.syntaxHighlighting = true,
    this.autoSuggestions = true,
    this.historySearch = true,
    this.historySize = 10000,
    this.plugins = const [],
    this.aliases = const {},
    this.customSettings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'executable': executable,
      'configFile': configFile,
      'initCommands': initCommands,
      'environment': environment,
      'promptTheme': promptTheme.name,
      'syntaxHighlighting': syntaxHighlighting,
      'autoSuggestions': autoSuggestions,
      'historySearch': historySearch,
      'historySize': historySize,
      'plugins': plugins,
      'aliases': aliases,
      'customSettings': customSettings,
    };
  }

  factory ShellConfiguration.fromJson(Map<String, dynamic> json) {
    return ShellConfiguration(
      type: ShellType.values.firstWhere((t) => t.name == json['type']),
      name: json['name'],
      executable: json['executable'],
      configFile: json['configFile'],
      initCommands: List<String>.from(json['initCommands'] ?? []),
      environment: Map<String, String>.from(json['environment'] ?? {}),
      promptTheme: PromptTheme.values.firstWhere((t) => t.name == json['promptTheme']),
      syntaxHighlighting: json['syntaxHighlighting'] ?? true,
      autoSuggestions: json['autoSuggestions'] ?? true,
      historySearch: json['historySearch'] ?? true,
      historySize: json['historySize'] ?? 10000,
      plugins: List<String>.from(json['plugins'] ?? []),
      aliases: Map<String, String>.from(json['aliases'] ?? {}),
      customSettings: json['customSettings'] ?? {},
    );
  }

  ShellConfiguration copyWith({
    String? name,
    String? executable,
    PromptTheme? promptTheme,
    bool? syntaxHighlighting,
    bool? autoSuggestions,
    bool? historySearch,
    int? historySize,
    List<String>? plugins,
    Map<String, String>? aliases,
  }) {
    return ShellConfiguration(
      type: type,
      name: name ?? this.name,
      executable: executable ?? this.executable,
      configFile: configFile,
      initCommands: initCommands,
      environment: environment,
      promptTheme: promptTheme ?? this.promptTheme,
      syntaxHighlighting: syntaxHighlighting ?? this.syntaxHighlighting,
      autoSuggestions: autoSuggestions ?? this.autoSuggestions,
      historySearch: historySearch ?? this.historySearch,
      historySize: historySize ?? this.historySize,
      plugins: plugins ?? this.plugins,
      aliases: aliases ?? this.aliases,
      customSettings: customSettings,
    );
  }
}

class ShellPlugin {
  final String name;
  final String description;
  final String repository;
  final List<String> dependencies;
  final Map<String, dynamic> config;
  final bool enabled;

  const ShellPlugin({
    required this.name,
    required this.description,
    required this.repository,
    this.dependencies = const [],
    this.config = const {},
    this.enabled = true,
  });
}

class ROSShellManager {
  static const String _shellConfigFile = 'ros_shell_config.json';
  static const String _shellHistoryFile = 'ros_shell_history.json';
  
  ShellConfiguration? _currentShell;
  final List<ShellConfiguration> _availableShells = [];
  final Map<String, ShellPlugin> _availablePlugins = {};
  final List<String> _commandHistory = [];
  String? _currentWorkingDirectory;

  // Default shell configurations
  static const Map<ShellType, Map<String, dynamic>> _defaultShellConfigs = {
    ShellType.bash: {
      'name': 'Bash',
      'executable': '/bin/bash',
      'configFile': '.bashrc',
      'description': 'Bourne Again Shell - Most common Unix shell',
      'features': ['tab_completion', 'history', 'aliases', 'functions'],
    },
    ShellType.zsh: {
      'name': 'Z Shell',
      'executable': '/bin/zsh',
      'configFile': '.zshrc',
      'description': 'Extended Bourne shell with improvements',
      'features': ['tab_completion', 'history', 'themes', 'plugins', 'auto_correction'],
    },
    ShellType.fish: {
      'name': 'Fish Shell',
      'executable': '/usr/bin/fish',
      'configFile': 'config.fish',
      'description': 'Friendly Interactive Shell',
      'features': ['auto_suggestions', 'syntax_highlighting', 'tab_completion', 'web_config'],
    },
    ShellType.xonsh: {
      'name': 'Xonsh',
      'executable': '/usr/bin/xonsh',
      'configFile': '.xonshrc',
      'description': 'Python-powered shell',
      'features': ['python_integration', 'syntax_highlighting', 'tab_completion'],
    },
    ShellType.nushell: {
      'name': 'Nu Shell',
      'executable': '/usr/bin/nu',
      'configFile': 'config.nu',
      'description': 'Modern shell with structured data',
      'features': ['structured_data', 'plugins', 'modern_syntax'],
    },
    ShellType.powershell: {
      'name': 'PowerShell',
      'executable': '/usr/bin/pwsh',
      'configFile': 'Microsoft.PowerShell_profile.ps1',
      'description': 'Cross-platform task automation shell',
      'features': ['object_pipeline', 'cmdlets', 'modules'],
    },
  };

  // Initialize shell manager
  Future<void> initialize() async {
    await _loadConfiguration();
    await _detectAvailableShells();
    await _loadCommandHistory();
    await _setupDefaultShell();
    await _loadPlugins();
  }

  // Shell detection and management
  Future<void> _detectAvailableShells() async {
    final platform = await PlatformService.getPlatformInfo();
    _availableShells.clear();

    for (final entry in _defaultShellConfigs.entries) {
      final shellType = entry.key;
      final config = entry.value;
      
      if (await _isShellAvailable(config['executable'])) {
        final shellConfig = ShellConfiguration(
          type: shellType,
          name: config['name'],
          executable: config['executable'],
          configFile: config['configFile'],
          initCommands: _getDefaultInitCommands(shellType),
          environment: await _getDefaultEnvironment(shellType),
          aliases: _getDefaultAliases(shellType),
        );
        
        _availableShells.add(shellConfig);
      }
    }

    // Add platform-specific shells
    if (platform.type == PlatformType.windowsPC || platform.type == PlatformType.windowsLaptop) {
      _availableShells.add(const ShellConfiguration(
        type: ShellType.cmd,
        name: 'Command Prompt',
        executable: 'cmd.exe',
        configFile: '',
      ));
    }

    // Ensure we have at least one shell
    if (_availableShells.isEmpty) {
      _availableShells.add(const ShellConfiguration(
        type: ShellType.sh,
        name: 'Basic Shell',
        executable: '/bin/sh',
        configFile: '.profile',
      ));
    }
  }

  Future<bool> _isShellAvailable(String executable) async {
    if (kIsWeb) return false;
    
    try {
      final result = await Process.run('which', [executable.split('/').last]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> _setupDefaultShell() async {
    if (_currentShell == null && _availableShells.isNotEmpty) {
      // Prefer zsh, then bash, then first available
      final preferredOrder = [ShellType.zsh, ShellType.bash, ShellType.fish];
      
      for (final preferred in preferredOrder) {
        final shell = _availableShells.where((s) => s.type == preferred).firstOrNull;
        if (shell != null) {
          await setCurrentShell(shell.type);
          return;
        }
      }
      
      // Fallback to first available
      await setCurrentShell(_availableShells.first.type);
    }
  }

  // Shell switching and configuration
  Future<void> setCurrentShell(ShellType type) async {
    final shell = _availableShells.where((s) => s.type == type).firstOrNull;
    if (shell == null) {
      throw Exception('Shell not available: ${type.name}');
    }

    _currentShell = shell;
    await _saveConfiguration();
    await _generateShellConfig(shell);
  }

  Future<void> _generateShellConfig(ShellConfiguration shell) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final configPath = '${appDir.path}/${shell.configFile}';
      final configFile = File(configPath);

      final configContent = _generateConfigContent(shell);
      await configFile.writeAsString(configContent);
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Generating shell config');
    }
  }

  String _generateConfigContent(ShellConfiguration shell) {
    final buffer = StringBuffer();
    
    switch (shell.type) {
      case ShellType.bash:
        buffer.writeln('# ROS Bash Configuration');
        buffer.writeln('export SHELL=${shell.executable}');
        buffer.writeln('export HISTSIZE=${shell.historySize}');
        buffer.writeln('export HISTFILESIZE=${shell.historySize}');
        
        // Add ROS-specific environment
        buffer.writeln('export ROS_HOME="\$HOME/.ros"');
        buffer.writeln('export ROS_WORKSPACE="\$HOME/ros_workspace"');
        
        // Add aliases
        for (final alias in shell.aliases.entries) {
          buffer.writeln('alias ${alias.key}="${alias.value}"');
        }
        
        // Add prompt theme
        buffer.writeln(_getBashPrompt(shell.promptTheme));
        
        // Add plugins/features
        if (shell.syntaxHighlighting) {
          buffer.writeln('# Enable syntax highlighting');
          buffer.writeln('source ~/.bash_syntax_highlighting 2>/dev/null || true');
        }
        
        if (shell.autoSuggestions) {
          buffer.writeln('# Enable auto-suggestions');
          buffer.writeln('source ~/.bash_autosuggestions 2>/dev/null || true');
        }
        break;
        
      case ShellType.zsh:
        buffer.writeln('# ROS Zsh Configuration');
        buffer.writeln('export SHELL=${shell.executable}');
        buffer.writeln('HISTSIZE=${shell.historySize}');
        buffer.writeln('SAVEHIST=${shell.historySize}');
        buffer.writeln('HISTFILE=~/.zsh_history');
        
        // Oh My Zsh setup
        if (shell.plugins.contains('oh-my-zsh')) {
          buffer.writeln('export ZSH="\$HOME/.oh-my-zsh"');
          buffer.writeln('ZSH_THEME="${_getZshTheme(shell.promptTheme)}"');
          buffer.writeln('plugins=(${shell.plugins.where((p) => p != 'oh-my-zsh').join(' ')})');
          buffer.writeln('source \$ZSH/oh-my-zsh.sh');
        }
        
        // Add aliases
        for (final alias in shell.aliases.entries) {
          buffer.writeln('alias ${alias.key}="${alias.value}"');
        }
        
        // Features
        if (shell.syntaxHighlighting) {
          buffer.writeln('source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || true');
        }
        
        if (shell.autoSuggestions) {
          buffer.writeln('source ~/.zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null || true');
        }
        break;
        
      case ShellType.fish:
        buffer.writeln('# ROS Fish Configuration');
        buffer.writeln('set -gx SHELL ${shell.executable}');
        buffer.writeln('set -g fish_history_size ${shell.historySize}');
        
        // Add aliases (functions in fish)
        for (final alias in shell.aliases.entries) {
          buffer.writeln('function ${alias.key}');
          buffer.writeln('    ${alias.value} \$argv');
          buffer.writeln('end');
        }
        
        // Fish-specific features are built-in
        buffer.writeln('# Fish features are enabled by default');
        break;
        
      case ShellType.powershell:
        buffer.writeln('# ROS PowerShell Configuration');
        buffer.writeln('\$env:SHELL = "${shell.executable}"');
        
        // Add aliases
        for (final alias in shell.aliases.entries) {
          buffer.writeln('Set-Alias ${alias.key} "${alias.value}"');
        }
        break;
        
      default:
        buffer.writeln('# ROS Shell Configuration');
        buffer.writeln('export SHELL=${shell.executable}');
    }
    
    // Add custom init commands
    for (final command in shell.initCommands) {
      buffer.writeln(command);
    }
    
    return buffer.toString();
  }

  String _getBashPrompt(PromptTheme theme) {
    switch (theme) {
      case PromptTheme.powerline:
        return r'''
# Powerline-style prompt
PS1='\[\e[1;34m\]\u\[\e[0m\]@\[\e[1;32m\]\h\[\e[0m\]:\[\e[1;33m\]\w\[\e[0m\]\$ '
''';
      case PromptTheme.git:
        return r'''
# Git-aware prompt
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[1;31m\]$(parse_git_branch)\[\e[0m\]\$ '
''';
      case PromptTheme.minimal:
        return 'PS1="\\$ "';
      case PromptTheme.arrow:
        return r'PS1="\[\e[1;36m\]➜\[\e[0m\] \[\e[1;34m\]\w\[\e[0m\] "';
      default:
        return r'PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "';
    }
  }

  String _getZshTheme(PromptTheme theme) {
    switch (theme) {
      case PromptTheme.robbyrussell:
        return 'robbyrussell';
      case PromptTheme.agnoster:
        return 'agnoster';
      case PromptTheme.spaceship:
        return 'spaceship';
      case PromptTheme.pure:
        return 'pure';
      case PromptTheme.powerline:
        return 'powerlevel10k/powerlevel10k';
      default:
        return 'robbyrussell';
    }
  }

  List<String> _getDefaultInitCommands(ShellType type) {
    final commands = <String>[];
    
    // Common ROS commands
    commands.addAll([
      'echo "Welcome to ROS - Roshan Operating System"',
      'echo "Shell: ${type.name}"',
      'echo "Type \'ros help\' for ROS-specific commands"',
    ]);
    
    switch (type) {
      case ShellType.zsh:
        commands.addAll([
          'autoload -U compinit && compinit',
          'setopt AUTO_CD',
          'setopt HIST_VERIFY',
        ]);
        break;
      case ShellType.fish:
        commands.addAll([
          'set fish_greeting ""',
          'set -g fish_prompt_pwd_dir_length 3',
        ]);
        break;
      default:
        break;
    }
    
    return commands;
  }

  Future<Map<String, String>> _getDefaultEnvironment(ShellType type) async {
    final env = <String, String>{};
    final platform = await PlatformService.getPlatformInfo();
    
    // Common environment variables
    env.addAll({
      'ROS_VERSION': '1.0.0',
      'ROS_SHELL': type.name,
      'ROS_PLATFORM': platform.type.name,
      'EDITOR': 'nano',
      'PAGER': 'less',
      'TERM': 'xterm-256color',
    });
    
    // Shell-specific environment
    switch (type) {
      case ShellType.zsh:
        env['ZSH_DISABLE_COMPFIX'] = 'true';
        break;
      case ShellType.fish:
        env['FISH_PROMPT_THEME'] = 'default';
        break;
      default:
        break;
    }
    
    return env;
  }

  Map<String, String> _getDefaultAliases(ShellType type) {
    final aliases = <String, String>{};
    
    // Common aliases
    aliases.addAll({
      'll': 'ls -la',
      'la': 'ls -A',
      'l': 'ls -CF',
      'grep': 'grep --color=auto',
      'fgrep': 'fgrep --color=auto',
      'egrep': 'egrep --color=auto',
      'h': 'history',
      'c': 'clear',
      'e': 'exit',
      'ros-update': 'ros update',
      'ros-install': 'ros install',
      'ros-search': 'ros search',
      'ros-info': 'ros info',
      'ros-clean': 'ros clean',
      '.': 'pwd',
      '..': 'cd ..',
      '...': 'cd ../..',
      'py': 'python3',
      'js': 'node',
      'g': 'git',
      'gs': 'git status',
      'ga': 'git add',
      'gc': 'git commit',
      'gp': 'git push',
      'gl': 'git log',
      'gd': 'git diff',
    });
    
    // Platform-specific aliases
    final platform = PlatformService.getPlatformInfo();
    platform.then((info) {
      if (info.type == PlatformType.macBookPro || 
          info.type == PlatformType.macBookAir || 
          info.type == PlatformType.iMac) {
        aliases['ls'] = 'ls -G';
        aliases['open'] = 'open';
      } else {
        aliases['ls'] = 'ls --color=auto';
        aliases['open'] = 'xdg-open';
      }
    });
    
    return aliases;
  }

  // Plugin management
  Future<void> _loadPlugins() async {
    _availablePlugins.clear();
    
    // Popular shell plugins
    _availablePlugins.addAll({
      'oh-my-zsh': const ShellPlugin(
        name: 'Oh My Zsh',
        description: 'Framework for managing Zsh configuration',
        repository: 'https://github.com/ohmyzsh/ohmyzsh',
      ),
      'powerlevel10k': const ShellPlugin(
        name: 'Powerlevel10k',
        description: 'Fast and flexible Zsh theme',
        repository: 'https://github.com/romkatv/powerlevel10k',
      ),
      'zsh-syntax-highlighting': const ShellPlugin(
        name: 'Zsh Syntax Highlighting',
        description: 'Syntax highlighting for Zsh',
        repository: 'https://github.com/zsh-users/zsh-syntax-highlighting',
      ),
      'zsh-autosuggestions': const ShellPlugin(
        name: 'Zsh Autosuggestions',
        description: 'Fish-like autosuggestions for Zsh',
        repository: 'https://github.com/zsh-users/zsh-autosuggestions',
      ),
      'starship': const ShellPlugin(
        name: 'Starship',
        description: 'Cross-shell prompt',
        repository: 'https://github.com/starship/starship',
      ),
      'fisher': const ShellPlugin(
        name: 'Fisher',
        description: 'Plugin manager for Fish',
        repository: 'https://github.com/jorgebucaran/fisher',
      ),
    });
  }

  Future<void> installPlugin(String pluginName) async {
    final plugin = _availablePlugins[pluginName];
    if (plugin == null) return;

    try {
      switch (pluginName) {
        case 'oh-my-zsh':
          await _installOhMyZsh();
          break;
        case 'starship':
          await _installStarship();
          break;
        default:
          await _installGenericPlugin(plugin);
      }
    } catch (e) {
      ErrorHandler.reportException(
        e,
        context: 'Installing plugin: $pluginName',
        category: ErrorCategory.system,
      );
    }
  }

  Future<void> _installOhMyZsh() async {
    if (!kIsWeb) {
      final script = '''
sh -c "\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
''';
      await Process.run('bash', ['-c', script]);
    }
  }

  Future<void> _installStarship() async {
    if (!kIsWeb) {
      final script = '''
curl -sS https://starship.rs/install.sh | sh
''';
      await Process.run('bash', ['-c', script]);
    }
  }

  Future<void> _installGenericPlugin(ShellPlugin plugin) async {
    // Generic Git-based plugin installation
    if (!kIsWeb) {
      final homeDir = Platform.environment['HOME'] ?? '';
      final pluginDir = '$homeDir/.${plugin.name.toLowerCase()}';
      
      await Process.run('git', ['clone', plugin.repository, pluginDir]);
    }
  }

  // Configuration management
  Future<void> updateShellConfiguration(ShellConfiguration config) async {
    final index = _availableShells.indexWhere((s) => s.type == config.type);
    if (index != -1) {
      _availableShells[index] = config;
      
      if (_currentShell?.type == config.type) {
        _currentShell = config;
        await _generateShellConfig(config);
      }
      
      await _saveConfiguration();
    }
  }

  // Command execution and history
  Future<String> executeCommand(String command, {String? workingDirectory}) async {
    if (_currentShell == null) {
      throw Exception('No shell configured');
    }

    // Add to history
    _commandHistory.add(command);
    if (_commandHistory.length > _currentShell!.historySize) {
      _commandHistory.removeAt(0);
    }
    await _saveCommandHistory();

    // Execute command
    try {
      final result = await Process.run(
        _currentShell!.executable,
        ['-c', command],
        workingDirectory: workingDirectory ?? _currentWorkingDirectory,
        environment: _currentShell!.environment,
      );

      return '${result.stdout}${result.stderr}';
    } catch (e) {
      throw Exception('Command execution failed: $e');
    }
  }

  // CLI interface for shell management
  Future<String> executeShellCommand(List<String> args) async {
    if (args.isEmpty) {
      return _getShellHelpText();
    }

    final command = args[0];
    final commandArgs = args.skip(1).toList();

    switch (command) {
      case 'list':
        return _listShells();
      case 'current':
        return _getCurrentShellInfo();
      case 'switch':
        return await _switchShell(commandArgs);
      case 'config':
        return await _configureShell(commandArgs);
      case 'theme':
        return await _setTheme(commandArgs);
      case 'plugin':
        return await _managePlugins(commandArgs);
      case 'alias':
        return await _manageAliases(commandArgs);
      case 'env':
        return await _manageEnvironment(commandArgs);
      case 'history':
        return _showHistory(commandArgs);
      case 'reset':
        return await _resetShell(commandArgs);
      default:
        return 'Unknown command: $command\n\n${_getShellHelpText()}';
    }
  }

  String _listShells() {
    final buffer = StringBuffer();
    buffer.writeln('Available shells:');
    buffer.writeln();
    
    for (final shell in _availableShells) {
      final current = shell.type == _currentShell?.type ? ' (current)' : '';
      buffer.writeln('${shell.type.name}: ${shell.name}$current');
      buffer.writeln('  Executable: ${shell.executable}');
      buffer.writeln('  Config: ${shell.configFile}');
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  String _getCurrentShellInfo() {
    if (_currentShell == null) {
      return 'No shell configured';
    }

    final shell = _currentShell!;
    final buffer = StringBuffer();
    buffer.writeln('Current shell: ${shell.name}');
    buffer.writeln('Type: ${shell.type.name}');
    buffer.writeln('Executable: ${shell.executable}');
    buffer.writeln('Config file: ${shell.configFile}');
    buffer.writeln('Prompt theme: ${shell.promptTheme.name}');
    buffer.writeln('Syntax highlighting: ${shell.syntaxHighlighting}');
    buffer.writeln('Auto suggestions: ${shell.autoSuggestions}');
    buffer.writeln('History size: ${shell.historySize}');
    
    if (shell.plugins.isNotEmpty) {
      buffer.writeln('Plugins: ${shell.plugins.join(', ')}');
    }
    
    if (shell.aliases.isNotEmpty) {
      buffer.writeln('Aliases: ${shell.aliases.length}');
    }
    
    return buffer.toString();
  }

  Future<String> _switchShell(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: ros shell switch <shell_type>';
    }

    final shellTypeName = args[0];
    try {
      final shellType = ShellType.values.firstWhere(
        (t) => t.name == shellTypeName,
      );
      
      await setCurrentShell(shellType);
      return 'Switched to ${shellType.name}';
    } catch (e) {
      return 'Shell not found: $shellTypeName';
    }
  }

  Future<String> _configureShell(List<String> args) async {
    if (args.length < 2) {
      return 'Usage: ros shell config <setting> <value>';
    }

    final setting = args[0];
    final value = args[1];

    if (_currentShell == null) {
      return 'No shell configured';
    }

    try {
      ShellConfiguration updatedShell;
      
      switch (setting) {
        case 'syntax-highlighting':
          updatedShell = _currentShell!.copyWith(
            syntaxHighlighting: value.toLowerCase() == 'true',
          );
          break;
        case 'auto-suggestions':
          updatedShell = _currentShell!.copyWith(
            autoSuggestions: value.toLowerCase() == 'true',
          );
          break;
        case 'history-size':
          updatedShell = _currentShell!.copyWith(
            historySize: int.parse(value),
          );
          break;
        default:
          return 'Unknown setting: $setting';
      }

      await updateShellConfiguration(updatedShell);
      return 'Updated $setting to $value';
    } catch (e) {
      return 'Failed to update setting: $e';
    }
  }

  Future<String> _setTheme(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: ros shell theme <theme_name>';
    }

    final themeName = args[0];
    
    try {
      final theme = PromptTheme.values.firstWhere(
        (t) => t.name == themeName,
      );
      
      if (_currentShell != null) {
        final updatedShell = _currentShell!.copyWith(promptTheme: theme);
        await updateShellConfiguration(updatedShell);
        return 'Set theme to ${theme.name}';
      } else {
        return 'No shell configured';
      }
    } catch (e) {
      return 'Theme not found: $themeName';
    }
  }

  Future<String> _managePlugins(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: ros shell plugin <list|install|remove> [plugin_name]';
    }

    final action = args[0];
    
    switch (action) {
      case 'list':
        final buffer = StringBuffer();
        buffer.writeln('Available plugins:');
        for (final plugin in _availablePlugins.values) {
          buffer.writeln('${plugin.name}: ${plugin.description}');
        }
        return buffer.toString();
        
      case 'install':
        if (args.length < 2) {
          return 'Usage: ros shell plugin install <plugin_name>';
        }
        await installPlugin(args[1]);
        return 'Installed plugin: ${args[1]}';
        
      case 'remove':
        if (args.length < 2) {
          return 'Usage: ros shell plugin remove <plugin_name>';
        }
        // Implement plugin removal
        return 'Removed plugin: ${args[1]}';
        
      default:
        return 'Unknown plugin action: $action';
    }
  }

  Future<String> _manageAliases(List<String> args) async {
    if (_currentShell == null) {
      return 'No shell configured';
    }

    if (args.isEmpty) {
      // List aliases
      final buffer = StringBuffer();
      buffer.writeln('Current aliases:');
      for (final alias in _currentShell!.aliases.entries) {
        buffer.writeln('${alias.key} = ${alias.value}');
      }
      return buffer.toString();
    }

    if (args.length < 2) {
      return 'Usage: ros shell alias <name> <command>';
    }

    final name = args[0];
    final command = args.skip(1).join(' ');
    
    final newAliases = Map<String, String>.from(_currentShell!.aliases);
    newAliases[name] = command;
    
    final updatedShell = _currentShell!.copyWith(aliases: newAliases);
    await updateShellConfiguration(updatedShell);
    
    return 'Added alias: $name = $command';
  }

  Future<String> _manageEnvironment(List<String> args) async {
    if (_currentShell == null) {
      return 'No shell configured';
    }

    if (args.isEmpty) {
      // List environment variables
      final buffer = StringBuffer();
      buffer.writeln('Environment variables:');
      for (final env in _currentShell!.environment.entries) {
        buffer.writeln('${env.key} = ${env.value}');
      }
      return buffer.toString();
    }

    if (args.length < 2) {
      return 'Usage: ros shell env <name> <value>';
    }

    // Set environment variable
    return 'Environment variables are read-only in this session';
  }

  String _showHistory(List<String> args) {
    final limit = args.isNotEmpty ? int.tryParse(args[0]) ?? 10 : 10;
    final recent = _commandHistory.reversed.take(limit).toList().reversed;
    
    final buffer = StringBuffer();
    buffer.writeln('Recent commands:');
    var index = _commandHistory.length - limit;
    for (final command in recent) {
      buffer.writeln('${index.toString().padLeft(4)}: $command');
      index++;
    }
    
    return buffer.toString();
  }

  Future<String> _resetShell(List<String> args) async {
    if (_currentShell == null) {
      return 'No shell configured';
    }

    // Reset to default configuration
    final defaultConfig = _availableShells.firstWhere(
      (s) => s.type == _currentShell!.type,
    );
    
    await updateShellConfiguration(defaultConfig);
    return 'Reset ${_currentShell!.type.name} to default configuration';
  }

  String _getShellHelpText() {
    return '''
ROS Shell Manager - Advanced shell configuration and management

Usage: ros shell <command> [arguments]

Commands:
  list              List available shells
  current           Show current shell information
  switch <type>     Switch to a different shell
  config <setting>  Configure shell settings
  theme <name>      Set prompt theme
  plugin <action>   Manage shell plugins
  alias <name>      Manage shell aliases
  env               Show environment variables
  history [limit]   Show command history
  reset             Reset shell to defaults

Examples:
  ros shell list
  ros shell switch zsh
  ros shell theme powerline
  ros shell plugin install oh-my-zsh
  ros shell alias ll "ls -la"
  ros shell config syntax-highlighting true
''';
  }

  // Persistence
  Future<void> _loadConfiguration() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_shellConfigFile');
      
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        if (data['currentShell'] != null) {
          _currentShell = ShellConfiguration.fromJson(data['currentShell']);
        }
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Loading shell configuration');
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_shellConfigFile');
      
      final data = {
        'currentShell': _currentShell?.toJson(),
        'availableShells': _availableShells.map((s) => s.toJson()).toList(),
      };
      
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Saving shell configuration');
    }
  }

  Future<void> _loadCommandHistory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_shellHistoryFile');
      
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as List;
        _commandHistory.clear();
        _commandHistory.addAll(data.cast<String>());
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Loading command history');
    }
  }

  Future<void> _saveCommandHistory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_shellHistoryFile');
      
      await file.writeAsString(jsonEncode(_commandHistory));
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Saving command history');
    }
  }

  // Getters
  ShellConfiguration? get currentShell => _currentShell;
  List<ShellConfiguration> get availableShells => List.unmodifiable(_availableShells);
  Map<String, ShellPlugin> get availablePlugins => Map.unmodifiable(_availablePlugins);
  List<String> get commandHistory => List.unmodifiable(_commandHistory);
  String? get currentWorkingDirectory => _currentWorkingDirectory;

  // Setters
  set currentWorkingDirectory(String? path) {
    _currentWorkingDirectory = path;
  }
}

// Riverpod providers
final rosShellManagerProvider = Provider<ROSShellManager>((ref) {
  return ROSShellManager();
});

final currentShellProvider = StateNotifierProvider<CurrentShellNotifier, ShellConfiguration?>((ref) {
  return CurrentShellNotifier(ref.read(rosShellManagerProvider));
});

final availableShellsProvider = StateNotifierProvider<AvailableShellsNotifier, List<ShellConfiguration>>((ref) {
  return AvailableShellsNotifier(ref.read(rosShellManagerProvider));
});

class CurrentShellNotifier extends StateNotifier<ShellConfiguration?> {
  final ROSShellManager _shellManager;
  
  CurrentShellNotifier(this._shellManager) : super(null);

  Future<void> refresh() async {
    state = _shellManager.currentShell;
  }

  Future<void> switchShell(ShellType type) async {
    await _shellManager.setCurrentShell(type);
    await refresh();
  }

  Future<void> updateConfiguration(ShellConfiguration config) async {
    await _shellManager.updateShellConfiguration(config);
    await refresh();
  }
}

class AvailableShellsNotifier extends StateNotifier<List<ShellConfiguration>> {
  final ROSShellManager _shellManager;
  
  AvailableShellsNotifier(this._shellManager) : super([]);

  Future<void> refresh() async {
    state = _shellManager.availableShells;
  }
}