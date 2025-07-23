class AppConstants {
  // App Information
  static const String appName = 'ROS';
  static const String appFullName = 'Roshan Operating System';
  static const String appId = 'com.roshan.ros';
  static const String appVersion = '1.0.0';
  static const String createdBy = 'Roshan';
  static const String poweredBy = 'Termux & Roshan';
  static const String appDescription = 'Advanced professional modern Termux-like app with AI integration';

  // Splash Screen
  static const String splashTitle = 'ROS';
  static const String splashSubtitle = 'Powered by Termux & Roshan';
  static const String splashCreatedBy = 'Created by Roshan';
  static const Duration splashDuration = Duration(seconds: 3);

  // Terminal Configuration
  static const String defaultShell = '/bin/bash';
  static const String defaultTerminalFont = 'JetBrainsMono';
  static const double defaultFontSize = 14.0;
  static const int maxTerminalSessions = 10;
  static const int terminalHistorySize = 5000;
  
  // AI Configuration
  static const String aiAssistantName = 'ROS AI Assistant';
  static const String aiWelcomeMessage = 'Hello! I\'m your AI assistant. How can I help you with terminal commands today?';
  static const String aiHelpCommand = '/ai help';
  static const int maxAIConversationHistory = 50;
  
  // Package Manager
  static const List<String> packageCategories = [
    'Dev Tools',
    'Hacking',
    'Python',
    'Network',
    'Fun',
    'Utilities',
    'Text Editors',
    'Compilers',
    'Languages',
    'System Tools'
  ];
  
  // Pre-installed Packages
  static const List<String> essentialPackages = [
    'bash',
    'coreutils',
    'curl',
    'git',
    'nano',
    'vim',
    'python',
    'nodejs',
    'openssh',
    'wget',
    'zip',
    'unzip',
    'htop',
    'neofetch'
  ];
  
  // Developer Toolkits
  static const Map<String, List<String>> developerToolkits = {
    'Web Development': ['nodejs', 'npm', 'yarn', 'php', 'nginx'],
    'Python Development': ['python', 'pip', 'python-dev', 'jupyter'],
    'Security Tools': ['nmap', 'hydra', 'metasploit', 'sqlmap', 'wireshark'],
    'Network Tools': ['netcat', 'tcpdump', 'iperf3', 'mtr', 'dig'],
    'System Administration': ['htop', 'iotop', 'rsync', 'tmux', 'screen'],
    'Database Tools': ['sqlite', 'postgresql', 'mysql', 'redis'],
  };

  // Theme Configuration
  static const List<String> availableThemes = [
    'Hacker Green',
    'Monokai',
    'Dracula',
    'Cyberpunk',
    'Matrix',
    'Synthwave',
    'Nord',
    'Gruvbox',
    'One Dark',
    'Solarized'
  ];

  // File Extensions and Syntax
  static const Map<String, String> fileExtensionLanguage = {
    '.dart': 'dart',
    '.py': 'python',
    '.js': 'javascript',
    '.ts': 'typescript',
    '.java': 'java',
    '.cpp': 'cpp',
    '.c': 'c',
    '.sh': 'bash',
    '.php': 'php',
    '.html': 'html',
    '.css': 'css',
    '.json': 'json',
    '.xml': 'xml',
    '.md': 'markdown',
    '.sql': 'sql',
    '.go': 'go',
    '.rs': 'rust',
  };

  // Network Configuration
  static const int defaultSSHPort = 22;
  static const int defaultHTTPPort = 80;
  static const int defaultHTTPSPort = 443;
  static const Duration networkTimeout = Duration(seconds: 30);
  
  // Storage Configuration
  static const String termuxDirectory = '/data/data/com.roshan.ros/files/usr';
  static const String scriptsDirectory = 'scripts';
  static const String downloadsDirectory = 'downloads';
  static const String backupDirectory = 'backups';
  
  // Permissions
  static const List<String> requiredPermissions = [
    'android.permission.INTERNET',
    'android.permission.WAKE_LOCK',
  ];
  
  static const List<String> optionalPermissions = [
    'android.permission.WRITE_EXTERNAL_STORAGE',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.CAMERA',
    'android.permission.RECORD_AUDIO',
    'android.permission.ACCESS_NETWORK_STATE',
    'android.permission.ACCESS_WIFI_STATE',
  ];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Layout Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Terminal Colors (Fallback)
  static const Map<String, String> terminalColors = {
    'black': '#000000',
    'red': '#FF0000',
    'green': '#00FF00',
    'yellow': '#FFFF00',
    'blue': '#0000FF',
    'magenta': '#FF00FF',
    'cyan': '#00FFFF',
    'white': '#FFFFFF',
    'bright_black': '#808080',
    'bright_red': '#FF8080',
    'bright_green': '#80FF80',
    'bright_yellow': '#FFFF80',
    'bright_blue': '#8080FF',
    'bright_magenta': '#FF80FF',
    'bright_cyan': '#80FFFF',
    'bright_white': '#FFFFFF',
  };

  // API Configuration
  static const String openAIAPIUrl = 'https://api.openai.com/v1';
  static const String termuxAPIUrl = 'https://termux.com/api';
  static const String githubAPIUrl = 'https://api.github.com';

  // Error Messages
  static const String genericError = 'An error occurred. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String permissionError = 'Permission denied. Please grant required permissions.';
  static const String termuxInitError = 'Failed to initialize Termux environment.';
  static const String aiError = 'AI service is currently unavailable.';

  // Success Messages
  static const String packageInstallSuccess = 'Package installed successfully';
  static const String scriptSaveSuccess = 'Script saved successfully';
  static const String backupSuccess = 'Backup completed successfully';
  static const String termuxInitSuccess = 'Termux environment initialized successfully';

  // Feature Flags
  static const bool enableAI = true;
  static const bool enableSSH = true;
  static const bool enableGit = true;
  static const bool enableNetworkScanner = true;
  static const bool enablePluginMarketplace = true;
  static const bool enableCloudSync = false; // Future feature
  static const bool enableBiometricAuth = true;
  static const bool enableVoiceCommands = false; // Future feature
  
  // URLs
  static const String githubUrl = 'https://github.com/roshan';
  static const String documentationUrl = 'https://ros-docs.roshan.dev';
  static const String supportUrl = 'mailto:support@roshan.dev';
  static const String privacyPolicyUrl = 'https://roshan.dev/privacy';
  static const String termsOfServiceUrl = 'https://roshan.dev/terms';
}