class AppConstants {
  // App Information
  static const String appName = 'ROS';
  static const String appFullName = 'Roshan Operating System';
  static const String appVersion = '1.0.0';
  static const String appId = 'com.roshan.ros';
  static const String createdBy = 'Roshan';
  static const String poweredBy = 'Termux & Roshan';
  
  // URLs and Links
  static const String githubUrl = 'https://github.com/Roshan07jp/ROS';
  static const String termuxUrl = 'https://github.com/termux/termux-app';
  static const String supportEmail = 'support@roshan.dev';
  static const String websiteUrl = 'https://roshan.dev';
  
  // Splash Screen
  static const String splashTitle = 'ROS';
  static const String splashSubtitle = 'Powered by Termux & Roshan';
  static const String splashCreatedBy = 'Created by Roshan';
  static const Duration splashDuration = Duration(seconds: 3);
  
  // Terminal Configuration
  static const int maxTerminalSessions = 10;
  static const int maxCommandHistory = 5000;
  static const String defaultShell = '/bin/bash';
  static const String termuxDirectory = '/data/data/com.roshan.ros/files/usr';
  static const Duration commandTimeout = Duration(minutes: 5);
  
  // AI Configuration
  static const String geminiApiKey = 'AIzaSyBQcahJ__WFtiNX51DKTQLSduFrTaeDDUk';
  static const String openaiApiKey = 'your-openai-api-key';
  static const int maxAIResponseLength = 2048;
  static const Duration aiRequestTimeout = Duration(seconds: 30);

  // 60+ NEW FEATURES
  static const List<String> newFeatures = [
    // Core Terminal Features
    'Multi-Session Terminal Manager',
    'Advanced Command History',
    'Terminal Recording & Playback',
    'Session Persistence',
    'Custom Shell Support',
    'Terminal Multiplexer',
    'Command Auto-completion',
    'Smart Command Suggestions',
    'Terminal Theming Engine',
    'Font Customization',
    
    // AI & Intelligence Features
    'Gemini AI Integration',
    'Natural Language Commands',
    'AI Code Generation',
    'Smart Error Explanation',
    'Automated Script Writing',
    'Code Review Assistant',
    'Security Audit AI',
    'Performance Optimization AI',
    'Documentation Generator',
    'Learning Assistant',
    
    // Development Tools
    'Multi-Language Code Playground',
    'Integrated Web Browser',
    'Database Management Suite',
    'API Testing Framework',
    'Docker Container Manager',
    'Git Integration Hub',
    'Project Template System',
    'Code Snippet Library',
    'Dependency Analyzer',
    'Build System Integration',
    
    // System & Monitoring
    'Real-time Performance Monitor',
    'Resource Usage Analytics',
    'Process Manager',
    'Log Aggregation System',
    'System Health Dashboard',
    'Alert & Notification System',
    'Automated Diagnostics',
    'Crash Report Analysis',
    'Memory Leak Detection',
    'CPU Profiling Tools',
    
    // Networking & Security
    'Advanced Network Scanner',
    'Port Security Analyzer',
    'VPN Integration',
    'Firewall Configuration',
    'Network Traffic Monitor',
    'SSL Certificate Manager',
    'Security Vulnerability Scanner',
    'Penetration Testing Suite',
    'Encrypted Communication',
    'Secure File Transfer',
    
    // File & Storage Management
    'Advanced File Manager',
    'Cloud Storage Sync',
    'Automated Backup System',
    'File Encryption/Decryption',
    'Duplicate File Finder',
    'Large File Analyzer',
    'File Permission Manager',
    'Archive & Compression Tools',
    'File Version Control',
    'Smart File Organization',
    
    // Productivity & Workflow
    'Task Automation Engine',
    'Workflow Designer',
    'Macro Recording System',
    'Custom Shortcut Manager',
    'Voice Command Interface',
    'Gesture Control System',
    'Quick Action Launcher',
    'Context-Aware Suggestions',
    'Smart Workspace Manager',
    'Productivity Analytics',
  ];

  // 20+ ADVANCED FEATURES
  static const List<String> advancedFeatures = [
    'Neural Network Code Analysis',
    'Quantum Computing Simulator',
    'Blockchain Development Kit',
    'Machine Learning Playground',
    'Augmented Reality Terminal',
    'Real-time Collaboration Platform',
    'Advanced Cryptography Suite',
    'IoT Device Management',
    'Serverless Function Deployment',
    'Edge Computing Framework',
    'Advanced Data Visualization',
    'Predictive System Analytics',
    'Automated Testing Framework',
    'Performance Benchmarking Suite',
    'Advanced Security Hardening',
    'Multi-Cloud Integration',
    'Advanced API Gateway',
    'Microservices Orchestration',
    'Real-time Data Streaming',
    'Advanced Plugin Architecture',
    'Custom Language Support',
    'Advanced Debugging Tools',
    'Professional Code Profiling',
    'Enterprise Security Compliance',
    'Advanced Monitoring & Alerting',
  ];

  // 50+ PROFESSIONAL TOOLS
  static const Map<String, List<String>> professionalTools = {
    'Development Tools': [
      'Code Editor Pro',
      'Syntax Highlighter',
      'Code Formatter',
      'Refactoring Assistant',
      'Unit Test Generator',
      'Documentation Builder',
      'API Mock Server',
      'Database Schema Designer',
      'Code Quality Analyzer',
      'Performance Profiler',
    ],
    'Network Tools': [
      'Advanced Port Scanner',
      'Network Topology Mapper',
      'Bandwidth Monitor',
      'DNS Lookup Tools',
      'SSL/TLS Analyzer',
      'Network Security Scanner',
      'Packet Analyzer',
      'Load Balancer Tester',
      'VPN Configuration Manager',
      'Network Performance Tester',
    ],
    'Security Tools': [
      'Vulnerability Scanner',
      'Password Manager',
      'Encryption Suite',
      'Digital Signature Tools',
      'Security Audit Framework',
      'Intrusion Detection System',
      'Forensic Analysis Tools',
      'Malware Scanner',
      'Security Policy Manager',
      'Compliance Checker',
    ],
    'System Tools': [
      'System Resource Monitor',
      'Process Manager Pro',
      'Service Controller',
      'Registry Editor',
      'Environment Manager',
      'System Configuration',
      'Hardware Diagnostics',
      'Driver Manager',
      'System Optimizer',
      'Cleanup Utilities',
    ],
    'Data Tools': [
      'Database Designer',
      'Query Builder',
      'Data Migration Tools',
      'ETL Pipeline Builder',
      'Data Visualization Suite',
      'Statistical Analysis Tools',
      'Report Generator',
      'Data Backup Manager',
      'Data Recovery Tools',
      'Data Encryption Manager',
    ],
  };

  // NEW SCREENS (10+)
  static const List<String> newScreens = [
    'AI Command Center',
    'Advanced Terminal Dashboard',
    'Professional Code Playground',
    'System Analytics Hub',
    'Security Command Center',
    'Network Operations Center',
    'DevOps Dashboard',
    'Cloud Management Console',
    'Data Analysis Workbench',
    'Collaboration Hub',
    'Plugin Marketplace Pro',
    'Enterprise Settings Panel',
    'Performance Monitoring Center',
    'Automation Workflow Designer',
    'Professional Theme Studio',
  ];
  
  // Package Categories
  static const List<String> packageCategories = [
    'Development Tools',
    'Hacking & Security',
    'Python & Data Science',
    'Network & Communication',
    'System Utilities',
    'Entertainment & Fun',
    'Productivity Tools',
    'Database & Storage',
    'Web Development',
    'Mobile Development',
    'DevOps & CI/CD',
    'Machine Learning',
    'Blockchain & Crypto',
    'IoT & Embedded',
    'Cloud & Serverless',
  ];
  
  // Developer Toolkits
  static const Map<String, List<String>> developerToolkits = {
    'Full Stack Developer': ['nodejs', 'python', 'git', 'docker', 'nginx'],
    'Mobile Developer': ['flutter', 'react-native', 'android-tools', 'ios-tools'],
    'DevOps Engineer': ['kubernetes', 'terraform', 'ansible', 'jenkins', 'prometheus'],
    'Data Scientist': ['python', 'jupyter', 'pandas', 'tensorflow', 'r'],
    'Security Expert': ['nmap', 'metasploit', 'wireshark', 'burpsuite', 'nikto'],
    'Web Developer': ['nodejs', 'npm', 'webpack', 'sass', 'php'],
    'System Administrator': ['htop', 'tmux', 'vim', 'openssh', 'curl'],
    'AI/ML Engineer': ['python', 'pytorch', 'tensorflow', 'opencv', 'scikit-learn'],
    'Blockchain Developer': ['web3', 'solidity', 'truffle', 'ganache', 'metamask'],
    'Game Developer': ['unity', 'unreal', 'blender', 'godot', 'love2d'],
  };
  
  // Terminal Color Schemes
  static const Map<String, Map<String, String>> terminalThemes = {
    'Hacker Green': {
      'background': '#000000',
      'foreground': '#00FF00',
      'cursor': '#00FF00',
      'selection': '#004400',
    },
    'Monokai': {
      'background': '#272822',
      'foreground': '#F8F8F2',
      'cursor': '#F8F8F0',
      'selection': '#49483E',
    },
    'Dracula': {
      'background': '#282A36',
      'foreground': '#F8F8F2',
      'cursor': '#F8F8F0',
      'selection': '#44475A',
    },
    'Cyberpunk': {
      'background': '#0D1117',
      'foreground': '#FF00FF',
      'cursor': '#00FFFF',
      'selection': '#1A1A2E',
    },
    'Matrix': {
      'background': '#000000',
      'foreground': '#00FF41',
      'cursor': '#00FF41',
      'selection': '#003300',
    },
    'Synthwave': {
      'background': '#2A0845',
      'foreground': '#FF6EC7',
      'cursor': '#57FFAB',
      'selection': '#451952',
    },
    'Nord': {
      'background': '#2E3440',
      'foreground': '#D8DEE9',
      'cursor': '#D8DEE9',
      'selection': '#434C5E',
    },
    'Gruvbox Dark': {
      'background': '#282828',
      'foreground': '#EBDBB2',
      'cursor': '#EBDBB2',
      'selection': '#3C3836',
    },
    'One Dark': {
      'background': '#1E2127',
      'foreground': '#ABB2BF',
      'cursor': '#ABB2BF',
      'selection': '#2C323C',
    },
    'Solarized Dark': {
      'background': '#002B36',
      'foreground': '#839496',
      'cursor': '#839496',
      'selection': '#073642',
    },
    'Tokyo Night': {
      'background': '#1A1B26',
      'foreground': '#C0CAF5',
      'cursor': '#C0CAF5',
      'selection': '#283457',
    },
    'Palenight': {
      'background': '#292D3E',
      'foreground': '#A6ACCD',
      'cursor': '#A6ACCD',
      'selection': '#444267',
    },
    'Oceanic Next': {
      'background': '#1B2B34',
      'foreground': '#CDD3DE',
      'cursor': '#CDD3DE',
      'selection': '#4F5B66',
    },
    'Material': {
      'background': '#263238',
      'foreground': '#EEFFFF',
      'cursor': '#EEFFFF',
      'selection': '#314549',
    },
    'Atom One Dark': {
      'background': '#282C34',
      'foreground': '#ABB2BF',
      'cursor': '#ABB2BF',
      'selection': '#3E4451',
    },
  };
  
  // Terminal Font Families
  static const List<String> terminalFonts = [
    'JetBrains Mono',
    'Fira Code',
    'Hack Nerd Font',
    'Source Code Pro',
    'Cascadia Code',
    'Monaco',
    'Consolas',
    'Ubuntu Mono',
    'DejaVu Sans Mono',
    'Liberation Mono',
  ];
  
  // App Theme Names
  static const List<String> appThemes = [
    'Material You',
    'Dark Professional',
    'Light Modern',
    'AMOLED Black',
    'Cyberpunk Neon',
    'Hacker Terminal',
    'Corporate Blue',
    'Nature Green',
    'Sunset Orange',
    'Royal Purple',
  ];
  
  // Permission Types
  static const List<String> requiredPermissions = [
    'INTERNET',
    'WRITE_EXTERNAL_STORAGE',
    'READ_EXTERNAL_STORAGE',
    'CAMERA',
    'RECORD_AUDIO',
    'ACCESS_NETWORK_STATE',
    'ACCESS_WIFI_STATE',
    'WAKE_LOCK',
    'VIBRATE',
    'USE_BIOMETRIC',
    'USE_FINGERPRINT',
    'SYSTEM_ALERT_WINDOW',
    'MODIFY_AUDIO_SETTINGS',
    'ACCESS_NOTIFICATION_POLICY',
    'REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
  ];
  
  // API Endpoints
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String openaiApiUrl = 'https://api.openai.com/v1';
  static const String termuxPackagesUrl = 'https://packages.termux.org';
  static const String rosUpdatesUrl = 'https://api.github.com/repos/Roshan07jp/ROS/releases';
  
  // File Extensions for Syntax Highlighting
  static const Map<String, String> fileExtensions = {
    '.dart': 'dart',
    '.py': 'python',
    '.js': 'javascript',
    '.ts': 'typescript',
    '.java': 'java',
    '.cpp': 'cpp',
    '.c': 'c',
    '.h': 'c',
    '.hpp': 'cpp',
    '.cs': 'csharp',
    '.php': 'php',
    '.rb': 'ruby',
    '.go': 'go',
    '.rs': 'rust',
    '.swift': 'swift',
    '.kt': 'kotlin',
    '.scala': 'scala',
    '.sh': 'bash',
    '.bash': 'bash',
    '.zsh': 'zsh',
    '.fish': 'fish',
    '.ps1': 'powershell',
    '.sql': 'sql',
    '.html': 'html',
    '.css': 'css',
    '.scss': 'scss',
    '.sass': 'sass',
    '.xml': 'xml',
    '.json': 'json',
    '.yaml': 'yaml',
    '.yml': 'yaml',
    '.toml': 'toml',
    '.ini': 'ini',
    '.conf': 'nginx',
    '.md': 'markdown',
    '.tex': 'latex',
    '.r': 'r',
    '.m': 'matlab',
    '.pl': 'perl',
    '.vim': 'vim',
    '.lua': 'lua',
    '.hs': 'haskell',
    '.clj': 'clojure',
    '.ex': 'elixir',
    '.erl': 'erlang',
    '.ml': 'ocaml',
    '.fs': 'fsharp',
    '.vb': 'vbnet',
    '.pas': 'pascal',
    '.asm': 'assembly',
    '.s': 'assembly',
  };

  // Advanced AI Prompts
  static const Map<String, String> aiPrompts = {
    'code_optimization': 'Optimize this code for better performance and readability:',
    'bug_detection': 'Analyze this code and identify potential bugs or issues:',
    'security_review': 'Perform a security review of this code and highlight vulnerabilities:',
    'documentation': 'Generate comprehensive documentation for this code:',
    'unit_tests': 'Create unit tests for the following code:',
    'refactoring': 'Refactor this code following best practices:',
    'explanation': 'Explain how this code works in simple terms:',
    'migration': 'Help migrate this code to a newer version or framework:',
    'integration': 'Suggest how to integrate this code with other systems:',
    'performance': 'Analyze the performance characteristics of this code:',
  };

  // Feature Flags
  static const Map<String, bool> featureFlags = {
    'gemini_ai_enabled': true,
    'openai_enabled': true,
    'voice_commands_enabled': true,
    'biometric_auth_enabled': true,
    'cloud_sync_enabled': true,
    'advanced_terminal_enabled': true,
    'docker_support_enabled': true,
    'web_browser_enabled': true,
    'code_playground_enabled': true,
    'network_tools_enabled': true,
    'security_tools_enabled': true,
    'performance_monitoring_enabled': true,
    'automation_enabled': true,
    'collaboration_enabled': true,
    'plugin_system_enabled': true,
    'enterprise_features_enabled': true,
    'analytics_enabled': true,
    'crash_reporting_enabled': true,
    'beta_features_enabled': false,
    'debug_mode_enabled': false,
  };

  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Network connection error. Please check your internet connection.',
    'permission_denied': 'Permission denied. Please grant required permissions.',
    'file_not_found': 'File not found. Please check the file path.',
    'invalid_command': 'Invalid command. Type "help" for available commands.',
    'ai_service_error': 'AI service is temporarily unavailable. Please try again later.',
    'authentication_failed': 'Authentication failed. Please check your credentials.',
    'insufficient_storage': 'Insufficient storage space. Please free up some space.',
    'unsupported_format': 'Unsupported file format.',
    'operation_cancelled': 'Operation was cancelled by the user.',
    'timeout_error': 'Operation timed out. Please try again.',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'command_executed': 'Command executed successfully!',
    'file_saved': 'File saved successfully!',
    'settings_updated': 'Settings updated successfully!',
    'backup_created': 'Backup created successfully!',
    'sync_completed': 'Synchronization completed!',
    'installation_completed': 'Installation completed successfully!',
    'update_available': 'Update available! Tap to install.',
    'login_successful': 'Login successful!',
    'export_completed': 'Export completed successfully!',
    'import_completed': 'Import completed successfully!',
  };
}