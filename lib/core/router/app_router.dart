import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import all screen files
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/terminal/screens/terminal_dashboard_screen.dart';
import '../../features/ai/screens/ai_assistant_screen.dart';
import '../../features/package_manager/screens/package_manager_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/file_manager/screens/file_manager_screen.dart';
import '../../features/network_scanner/screens/network_scanner_screen.dart';
import '../../features/script_editor/screens/script_editor_screen.dart';
import '../../features/system_monitor/screens/system_monitor_screen.dart';
import '../../features/ssh_client/screens/ssh_client_screen.dart';
import '../../features/git_integration/screens/git_integration_screen.dart';
import '../../features/security_audit/screens/security_audit_screen.dart';
import '../../features/backup_sync/screens/backup_sync_screen.dart';
import '../../features/plugin_marketplace/screens/plugin_marketplace_screen.dart';
import '../../features/code_playground/screens/code_playground_screen.dart';
import '../../features/web_browser/screens/web_browser_screen.dart';
import '../../features/media_center/screens/media_center_screen.dart';
import '../../features/database_manager/screens/database_manager_screen.dart';
import '../../features/api_testing/screens/api_testing_screen.dart';
import '../../features/docker_manager/screens/docker_manager_screen.dart';
import '../../features/cloud_storage/screens/cloud_storage_screen.dart';
import '../../features/remote_desktop/screens/remote_desktop_screen.dart';
import '../../features/task_scheduler/screens/task_scheduler_screen.dart';
import '../../features/log_viewer/screens/log_viewer_screen.dart';
import '../../features/performance_profiler/screens/performance_profiler_screen.dart';
import '../../features/widget_inspector/screens/widget_inspector_screen.dart';
import '../../features/shortcut_manager/screens/shortcut_manager_screen.dart';
import '../../features/theme_studio/screens/theme_studio_screen.dart';
import '../../features/macro_recorder/screens/macro_recorder_screen.dart';

// New Advanced Features
import '../../features/ai_command_center/screens/ai_command_center_screen.dart';
import '../../features/quantum_computing/screens/quantum_simulator_screen.dart';
import '../../features/blockchain_dev/screens/blockchain_dev_screen.dart';

// Additional Advanced Screens
import '../../features/machine_learning/screens/ml_playground_screen.dart';
import '../../features/augmented_reality/screens/ar_terminal_screen.dart';
import '../../features/collaboration/screens/collaboration_hub_screen.dart';
import '../../features/cryptography/screens/cryptography_suite_screen.dart';
import '../../features/iot_management/screens/iot_manager_screen.dart';
import '../../features/serverless/screens/serverless_deploy_screen.dart';
import '../../features/edge_computing/screens/edge_computing_screen.dart';
import '../../features/data_visualization/screens/data_viz_screen.dart';
import '../../features/predictive_analytics/screens/predictive_analytics_screen.dart';
import '../../features/automation_testing/screens/automation_testing_screen.dart';
import '../../features/benchmarking/screens/benchmarking_screen.dart';
import '../../features/security_hardening/screens/security_hardening_screen.dart';
import '../../features/multi_cloud/screens/multi_cloud_screen.dart';
import '../../features/api_gateway/screens/api_gateway_screen.dart';
import '../../features/microservices/screens/microservices_screen.dart';
import '../../features/data_streaming/screens/data_streaming_screen.dart';
import '../../features/plugin_architecture/screens/plugin_architecture_screen.dart';
import '../../features/custom_language/screens/custom_language_screen.dart';
import '../../features/advanced_debugging/screens/advanced_debugging_screen.dart';
import '../../features/code_profiling/screens/code_profiling_screen.dart';
import '../../features/enterprise_security/screens/enterprise_security_screen.dart';
import '../../features/monitoring_alerting/screens/monitoring_alerting_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash and Onboarding
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main Dashboard
      GoRoute(
        path: '/',
        builder: (context, state) => const TerminalDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const TerminalDashboardScreen(),
      ),

      // Core Features
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AIAssistantScreen(),
      ),
      GoRoute(
        path: '/package-manager',
        builder: (context, state) => const PackageManagerScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // System Tools
      GoRoute(
        path: '/file-manager',
        builder: (context, state) => const FileManagerScreen(),
      ),
      GoRoute(
        path: '/network-scanner',
        builder: (context, state) => const NetworkScannerScreen(),
      ),
      GoRoute(
        path: '/script-editor',
        builder: (context, state) => const ScriptEditorScreen(),
      ),
      GoRoute(
        path: '/system-monitor',
        builder: (context, state) => const SystemMonitorScreen(),
      ),

      // Network and Remote
      GoRoute(
        path: '/ssh-client',
        builder: (context, state) => const SSHClientScreen(),
      ),
      GoRoute(
        path: '/remote-desktop',
        builder: (context, state) => const RemoteDesktopScreen(),
      ),

      // Development Tools
      GoRoute(
        path: '/git-integration',
        builder: (context, state) => const GitIntegrationScreen(),
      ),
      GoRoute(
        path: '/code-playground',
        builder: (context, state) => const CodePlaygroundScreen(),
      ),
      GoRoute(
        path: '/api-testing',
        builder: (context, state) => const APITestingScreen(),
      ),
      GoRoute(
        path: '/database-manager',
        builder: (context, state) => const DatabaseManagerScreen(),
      ),

      // Security Tools
      GoRoute(
        path: '/security-audit',
        builder: (context, state) => const SecurityAuditScreen(),
      ),
      GoRoute(
        path: '/security-hardening',
        builder: (context, state) => const SecurityHardeningScreen(),
      ),
      GoRoute(
        path: '/enterprise-security',
        builder: (context, state) => const EnterpriseSecurityScreen(),
      ),

      // Cloud and DevOps
      GoRoute(
        path: '/docker-manager',
        builder: (context, state) => const DockerManagerScreen(),
      ),
      GoRoute(
        path: '/cloud-storage',
        builder: (context, state) => const CloudStorageScreen(),
      ),
      GoRoute(
        path: '/multi-cloud',
        builder: (context, state) => const MultiCloudScreen(),
      ),
      GoRoute(
        path: '/serverless',
        builder: (context, state) => const ServerlessDeployScreen(),
      ),
      GoRoute(
        path: '/microservices',
        builder: (context, state) => const MicroservicesScreen(),
      ),

      // Data and Analytics
      GoRoute(
        path: '/data-visualization',
        builder: (context, state) => const DataVizScreen(),
      ),
      GoRoute(
        path: '/predictive-analytics',
        builder: (context, state) => const PredictiveAnalyticsScreen(),
      ),
      GoRoute(
        path: '/data-streaming',
        builder: (context, state) => const DataStreamingScreen(),
      ),

      // Advanced Features
      GoRoute(
        path: '/ai-command-center',
        builder: (context, state) => const AICommandCenterScreen(),
      ),
      GoRoute(
        path: '/quantum-simulator',
        builder: (context, state) => const QuantumSimulatorScreen(),
      ),
      GoRoute(
        path: '/blockchain-dev',
        builder: (context, state) => const BlockchainDevScreen(),
      ),
      GoRoute(
        path: '/machine-learning',
        builder: (context, state) => const MLPlaygroundScreen(),
      ),
      GoRoute(
        path: '/ar-terminal',
        builder: (context, state) => const ARTerminalScreen(),
      ),
      GoRoute(
        path: '/collaboration-hub',
        builder: (context, state) => const CollaborationHubScreen(),
      ),
      GoRoute(
        path: '/cryptography-suite',
        builder: (context, state) => const CryptographySuiteScreen(),
      ),
      GoRoute(
        path: '/iot-manager',
        builder: (context, state) => const IoTManagerScreen(),
      ),
      GoRoute(
        path: '/edge-computing',
        builder: (context, state) => const EdgeComputingScreen(),
      ),

      // Monitoring and Performance
      GoRoute(
        path: '/log-viewer',
        builder: (context, state) => const LogViewerScreen(),
      ),
      GoRoute(
        path: '/performance-profiler',
        builder: (context, state) => const PerformanceProfilerScreen(),
      ),
      GoRoute(
        path: '/monitoring-alerting',
        builder: (context, state) => const MonitoringAlertingScreen(),
      ),
      GoRoute(
        path: '/benchmarking',
        builder: (context, state) => const BenchmarkingScreen(),
      ),

      // Testing and Automation
      GoRoute(
        path: '/automation-testing',
        builder: (context, state) => const AutomationTestingScreen(),
      ),
      GoRoute(
        path: '/task-scheduler',
        builder: (context, state) => const TaskSchedulerScreen(),
      ),
      GoRoute(
        path: '/macro-recorder',
        builder: (context, state) => const MacroRecorderScreen(),
      ),

      // Customization and Tools
      GoRoute(
        path: '/theme-studio',
        builder: (context, state) => const ThemeStudioScreen(),
      ),
      GoRoute(
        path: '/shortcut-manager',
        builder: (context, state) => const ShortcutManagerScreen(),
      ),
      GoRoute(
        path: '/widget-inspector',
        builder: (context, state) => const WidgetInspectorScreen(),
      ),
      GoRoute(
        path: '/plugin-architecture',
        builder: (context, state) => const PluginArchitectureScreen(),
      ),
      GoRoute(
        path: '/custom-language',
        builder: (context, state) => const CustomLanguageScreen(),
      ),

      // Professional Development
      GoRoute(
        path: '/advanced-debugging',
        builder: (context, state) => const AdvancedDebuggingScreen(),
      ),
      GoRoute(
        path: '/code-profiling',
        builder: (context, state) => const CodeProfilingScreen(),
      ),
      GoRoute(
        path: '/api-gateway',
        builder: (context, state) => const APIGatewayScreen(),
      ),

      // Media and Browser
      GoRoute(
        path: '/web-browser',
        builder: (context, state) => const WebBrowserScreen(),
      ),
      GoRoute(
        path: '/media-center',
        builder: (context, state) => const MediaCenterScreen(),
      ),

      // Backup and Storage
      GoRoute(
        path: '/backup-sync',
        builder: (context, state) => const BackupSyncScreen(),
      ),

      // Marketplace
      GoRoute(
        path: '/plugin-marketplace',
        builder: (context, state) => const PluginMarketplaceScreen(),
      ),

      // Nested Routes for Settings
      GoRoute(
        path: '/settings/general',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/terminal',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/ai',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/network',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/performance',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/themes',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/plugins',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/backup',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Error Route
      GoRoute(
        path: '/error',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(
            child: Text('Page not found!'),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Route helper class for easy navigation
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/';
  static const String aiAssistant = '/ai-assistant';
  static const String packageManager = '/package-manager';
  static const String settings = '/settings';
  static const String fileManager = '/file-manager';
  static const String networkScanner = '/network-scanner';
  static const String scriptEditor = '/script-editor';
  static const String systemMonitor = '/system-monitor';
  static const String sshClient = '/ssh-client';
  static const String gitIntegration = '/git-integration';
  static const String securityAudit = '/security-audit';
  static const String backupSync = '/backup-sync';
  static const String pluginMarketplace = '/plugin-marketplace';
  static const String codePlayground = '/code-playground';
  static const String webBrowser = '/web-browser';
  static const String mediaCenter = '/media-center';
  static const String databaseManager = '/database-manager';
  static const String apiTesting = '/api-testing';
  static const String dockerManager = '/docker-manager';
  static const String cloudStorage = '/cloud-storage';
  static const String remoteDesktop = '/remote-desktop';
  static const String taskScheduler = '/task-scheduler';
  static const String logViewer = '/log-viewer';
  static const String performanceProfiler = '/performance-profiler';
  static const String widgetInspector = '/widget-inspector';
  static const String shortcutManager = '/shortcut-manager';
  static const String themeStudio = '/theme-studio';
  static const String macroRecorder = '/macro-recorder';

  // Advanced Features
  static const String aiCommandCenter = '/ai-command-center';
  static const String quantumSimulator = '/quantum-simulator';
  static const String blockchainDev = '/blockchain-dev';
  static const String machineLearning = '/machine-learning';
  static const String arTerminal = '/ar-terminal';
  static const String collaborationHub = '/collaboration-hub';
  static const String cryptographySuite = '/cryptography-suite';
  static const String iotManager = '/iot-manager';
  static const String serverless = '/serverless';
  static const String edgeComputing = '/edge-computing';
  static const String dataVisualization = '/data-visualization';
  static const String predictiveAnalytics = '/predictive-analytics';
  static const String automationTesting = '/automation-testing';
  static const String benchmarking = '/benchmarking';
  static const String securityHardening = '/security-hardening';
  static const String multiCloud = '/multi-cloud';
  static const String apiGateway = '/api-gateway';
  static const String microservices = '/microservices';
  static const String dataStreaming = '/data-streaming';
  static const String pluginArchitecture = '/plugin-architecture';
  static const String customLanguage = '/custom-language';
  static const String advancedDebugging = '/advanced-debugging';
  static const String codeProfiling = '/code-profiling';
  static const String enterpriseSecurity = '/enterprise-security';
  static const String monitoringAlerting = '/monitoring-alerting';

  // Settings Routes
  static const String settingsGeneral = '/settings/general';
  static const String settingsTerminal = '/settings/terminal';
  static const String settingsAI = '/settings/ai';
  static const String settingsSecurity = '/settings/security';
  static const String settingsNetwork = '/settings/network';
  static const String settingsPerformance = '/settings/performance';
  static const String settingsThemes = '/settings/themes';
  static const String settingsPlugins = '/settings/plugins';
  static const String settingsBackup = '/settings/backup';
  static const String settingsAbout = '/settings/about';
}

// Navigation extensions
extension GoRouterExtension on GoRouter {
  void pushAndClearStack(String route) {
    while (canPop()) {
      pop();
    }
    pushReplacement(route);
  }
}

// Screen categories for menu generation
class ScreenCategories {
  static const Map<String, List<Map<String, String>>> categories = {
    'Core Features': [
      {'name': 'Terminal Dashboard', 'route': AppRoutes.dashboard, 'icon': 'terminal'},
      {'name': 'AI Assistant', 'route': AppRoutes.aiAssistant, 'icon': 'psychology'},
      {'name': 'Package Manager', 'route': AppRoutes.packageManager, 'icon': 'inventory'},
      {'name': 'File Manager', 'route': AppRoutes.fileManager, 'icon': 'folder'},
    ],
    'Development Tools': [
      {'name': 'Code Playground', 'route': AppRoutes.codePlayground, 'icon': 'code'},
      {'name': 'Git Integration', 'route': AppRoutes.gitIntegration, 'icon': 'merge_type'},
      {'name': 'API Testing', 'route': AppRoutes.apiTesting, 'icon': 'api'},
      {'name': 'Database Manager', 'route': AppRoutes.databaseManager, 'icon': 'storage'},
      {'name': 'Script Editor', 'route': AppRoutes.scriptEditor, 'icon': 'edit_note'},
    ],
    'System Tools': [
      {'name': 'System Monitor', 'route': AppRoutes.systemMonitor, 'icon': 'monitor_heart'},
      {'name': 'Network Scanner', 'route': AppRoutes.networkScanner, 'icon': 'network_check'},
      {'name': 'Log Viewer', 'route': AppRoutes.logViewer, 'icon': 'description'},
      {'name': 'Performance Profiler', 'route': AppRoutes.performanceProfiler, 'icon': 'speed'},
      {'name': 'Task Scheduler', 'route': AppRoutes.taskScheduler, 'icon': 'schedule'},
    ],
    'Advanced Features': [
      {'name': 'AI Command Center', 'route': AppRoutes.aiCommandCenter, 'icon': 'auto_awesome'},
      {'name': 'Quantum Simulator', 'route': AppRoutes.quantumSimulator, 'icon': 'science'},
      {'name': 'Blockchain Dev', 'route': AppRoutes.blockchainDev, 'icon': 'currency_bitcoin'},
      {'name': 'Machine Learning', 'route': AppRoutes.machineLearning, 'icon': 'smart_toy'},
      {'name': 'AR Terminal', 'route': AppRoutes.arTerminal, 'icon': 'view_in_ar'},
    ],
    'Security Tools': [
      {'name': 'Security Audit', 'route': AppRoutes.securityAudit, 'icon': 'security'},
      {'name': 'Security Hardening', 'route': AppRoutes.securityHardening, 'icon': 'shield'},
      {'name': 'Cryptography Suite', 'route': AppRoutes.cryptographySuite, 'icon': 'lock'},
      {'name': 'Enterprise Security', 'route': AppRoutes.enterpriseSecurity, 'icon': 'verified_user'},
    ],
    'Cloud & DevOps': [
      {'name': 'Docker Manager', 'route': AppRoutes.dockerManager, 'icon': 'container'},
      {'name': 'Cloud Storage', 'route': AppRoutes.cloudStorage, 'icon': 'cloud'},
      {'name': 'Multi-Cloud', 'route': AppRoutes.multiCloud, 'icon': 'cloud_queue'},
      {'name': 'Serverless', 'route': AppRoutes.serverless, 'icon': 'functions'},
      {'name': 'Microservices', 'route': AppRoutes.microservices, 'icon': 'hub'},
    ],
    'Data & Analytics': [
      {'name': 'Data Visualization', 'route': AppRoutes.dataVisualization, 'icon': 'analytics'},
      {'name': 'Predictive Analytics', 'route': AppRoutes.predictiveAnalytics, 'icon': 'trending_up'},
      {'name': 'Data Streaming', 'route': AppRoutes.dataStreaming, 'icon': 'stream'},
      {'name': 'Monitoring & Alerting', 'route': AppRoutes.monitoringAlerting, 'icon': 'notifications'},
    ],
    'Productivity': [
      {'name': 'Web Browser', 'route': AppRoutes.webBrowser, 'icon': 'web'},
      {'name': 'Media Center', 'route': AppRoutes.mediaCenter, 'icon': 'perm_media'},
      {'name': 'Backup & Sync', 'route': AppRoutes.backupSync, 'icon': 'backup'},
      {'name': 'Remote Desktop', 'route': AppRoutes.remoteDesktop, 'icon': 'desktop_windows'},
    ],
    'Customization': [
      {'name': 'Theme Studio', 'route': AppRoutes.themeStudio, 'icon': 'palette'},
      {'name': 'Shortcut Manager', 'route': AppRoutes.shortcutManager, 'icon': 'keyboard'},
      {'name': 'Macro Recorder', 'route': AppRoutes.macroRecorder, 'icon': 'play_circle'},
      {'name': 'Plugin Marketplace', 'route': AppRoutes.pluginMarketplace, 'icon': 'extension'},
    ],
  };
}