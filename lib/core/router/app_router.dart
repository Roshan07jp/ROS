import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Route
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding Route
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Main Dashboard Route
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const TerminalDashboardScreen(),
        routes: [
          // AI Assistant Route
          GoRoute(
            path: '/ai',
            name: 'ai_assistant',
            builder: (context, state) => const AIAssistantScreen(),
          ),
          
          // Package Manager Route
          GoRoute(
            path: '/packages',
            name: 'package_manager',
            builder: (context, state) => const PackageManagerScreen(),
          ),
          
          // File Manager Route
          GoRoute(
            path: '/files',
            name: 'file_manager',
            builder: (context, state) => const FileManagerScreen(),
          ),
          
          // Network Scanner Route
          GoRoute(
            path: '/network',
            name: 'network_scanner',
            builder: (context, state) => const NetworkScannerScreen(),
          ),
          
          // Script Editor Route
          GoRoute(
            path: '/editor',
            name: 'script_editor',
            builder: (context, state) {
              final filePath = state.uri.queryParameters['file'];
              return ScriptEditorScreen(filePath: filePath);
            },
          ),
          
          // System Monitor Route
          GoRoute(
            path: '/monitor',
            name: 'system_monitor',
            builder: (context, state) => const SystemMonitorScreen(),
          ),
          
          // SSH Client Route
          GoRoute(
            path: '/ssh',
            name: 'ssh_client',
            builder: (context, state) => const SSHClientScreen(),
          ),
          
          // Git Integration Route
          GoRoute(
            path: '/git',
            name: 'git_integration',
            builder: (context, state) => const GitIntegrationScreen(),
          ),
          
          // Security Audit Route
          GoRoute(
            path: '/security',
            name: 'security_audit',
            builder: (context, state) => const SecurityAuditScreen(),
          ),
          
          // Backup & Sync Route
          GoRoute(
            path: '/backup',
            name: 'backup_sync',
            builder: (context, state) => const BackupSyncScreen(),
          ),
          
          // Plugin Marketplace Route
          GoRoute(
            path: '/plugins',
            name: 'plugin_marketplace',
            builder: (context, state) => const PluginMarketplaceScreen(),
          ),
        ],
      ),
      
      // Settings Route
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          // Terminal Settings
          GoRoute(
            path: '/terminal',
            name: 'terminal_settings',
            builder: (context, state) => const TerminalSettingsScreen(),
          ),
          
          // AI Settings
          GoRoute(
            path: '/ai',
            name: 'ai_settings',
            builder: (context, state) => const AISettingsScreen(),
          ),
          
          // Theme Settings
          GoRoute(
            path: '/theme',
            name: 'theme_settings',
            builder: (context, state) => const ThemeSettingsScreen(),
          ),
          
          // Security Settings
          GoRoute(
            path: '/security',
            name: 'security_settings',
            builder: (context, state) => const SecuritySettingsScreen(),
          ),
          
          // Backup Settings
          GoRoute(
            path: '/backup',
            name: 'backup_settings',
            builder: (context, state) => const BackupSettingsScreen(),
          ),
          
          // About Settings
          GoRoute(
            path: '/about',
            name: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
      
      // Terminal Session Route
      GoRoute(
        path: '/terminal/:sessionId',
        name: 'terminal_session',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return TerminalSessionScreen(sessionId: sessionId);
        },
      ),
      
      // Quick Actions Routes
      GoRoute(
        path: '/quick/:action',
        name: 'quick_action',
        builder: (context, state) {
          final action = state.pathParameters['action']!;
          return QuickActionScreen(action: action);
        },
      ),
      
      // Tutorial Routes
      GoRoute(
        path: '/tutorial',
        name: 'tutorial',
        builder: (context, state) => const TutorialScreen(),
        routes: [
          GoRoute(
            path: '/:topic',
            name: 'tutorial_topic',
            builder: (context, state) {
              final topic = state.pathParameters['topic']!;
              return TutorialTopicScreen(topic: topic);
            },
          ),
        ],
      ),
      
      // Tools Routes
      GoRoute(
        path: '/tools',
        name: 'tools',
        builder: (context, state) => const ToolsScreen(),
        routes: [
          // Network Tools
          GoRoute(
            path: '/network',
            name: 'network_tools',
            builder: (context, state) => const NetworkToolsScreen(),
          ),
          
          // Development Tools
          GoRoute(
            path: '/dev',
            name: 'dev_tools',
            builder: (context, state) => const DevToolsScreen(),
          ),
          
          // Security Tools
          GoRoute(
            path: '/security',
            name: 'security_tools',
            builder: (context, state) => const SecurityToolsScreen(),
          ),
          
          // System Tools
          GoRoute(
            path: '/system',
            name: 'system_tools',
            builder: (context, state) => const SystemToolsScreen(),
          ),
        ],
      ),
      
      // Help & Documentation Routes
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpScreen(),
        routes: [
          GoRoute(
            path: '/commands',
            name: 'command_reference',
            builder: (context, state) => const CommandReferenceScreen(),
          ),
          
          GoRoute(
            path: '/faq',
            name: 'faq',
            builder: (context, state) => const FAQScreen(),
          ),
          
          GoRoute(
            path: '/shortcuts',
            name: 'shortcuts',
            builder: (context, state) => const ShortcutsScreen(),
          ),
        ],
      ),
    ],
    
    // Error Handler
    errorBuilder: (context, state) => ErrorScreen(error: state.error?.toString() ?? 'Unknown error'),
    
    // Redirect Logic
    redirect: (context, state) {
      // Add authentication and first-time setup redirects here
      return null;
    },
  );
}

// Navigation Extension
extension AppRouterExtension on GoRouter {
  void pushToTerminal() => pushNamed('dashboard');
  void pushToSettings() => pushNamed('settings');
  void pushToAI() => go('/dashboard/ai');
  void pushToPackages() => go('/dashboard/packages');
  void pushToFiles() => go('/dashboard/files');
  void pushToNetwork() => go('/dashboard/network');
  void pushToEditor({String? filePath}) {
    final uri = Uri(path: '/dashboard/editor', queryParameters: 
        filePath != null ? {'file': filePath} : null);
    go(uri.toString());
  }
}

// Placeholder Screens (to be implemented)
class TerminalSessionScreen extends StatelessWidget {
  final String sessionId;
  
  const TerminalSessionScreen({super.key, required this.sessionId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Terminal Session: $sessionId')),
      body: const Center(child: Text('Terminal Session Screen')),
    );
  }
}

class QuickActionScreen extends StatelessWidget {
  final String action;
  
  const QuickActionScreen({super.key, required this.action});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quick Action: $action')),
      body: const Center(child: Text('Quick Action Screen')),
    );
  }
}

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorials')),
      body: const Center(child: Text('Tutorial Screen')),
    );
  }
}

class TutorialTopicScreen extends StatelessWidget {
  final String topic;
  
  const TutorialTopicScreen({super.key, required this.topic});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tutorial: $topic')),
      body: const Center(child: Text('Tutorial Topic Screen')),
    );
  }
}

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: const Center(child: Text('Tools Screen')),
    );
  }
}

class NetworkToolsScreen extends StatelessWidget {
  const NetworkToolsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Tools')),
      body: const Center(child: Text('Network Tools Screen')),
    );
  }
}

class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Development Tools')),
      body: const Center(child: Text('Development Tools Screen')),
    );
  }
}

class SecurityToolsScreen extends StatelessWidget {
  const SecurityToolsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Tools')),
      body: const Center(child: Text('Security Tools Screen')),
    );
  }
}

class SystemToolsScreen extends StatelessWidget {
  const SystemToolsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Tools')),
      body: const Center(child: Text('System Tools Screen')),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: const Center(child: Text('Help Screen')),
    );
  }
}

class CommandReferenceScreen extends StatelessWidget {
  const CommandReferenceScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Command Reference')),
      body: const Center(child: Text('Command Reference Screen')),
    );
  }
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: const Center(child: Text('FAQ Screen')),
    );
  }
}

class ShortcutsScreen extends StatelessWidget {
  const ShortcutsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Shortcuts')),
      body: const Center(child: Text('Shortcuts Screen')),
    );
  }
}

class TerminalSettingsScreen extends StatelessWidget {
  const TerminalSettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terminal Settings')),
      body: const Center(child: Text('Terminal Settings Screen')),
    );
  }
}

class AISettingsScreen extends StatelessWidget {
  const AISettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Settings')),
      body: const Center(child: Text('AI Settings Screen')),
    );
  }
}

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: const Center(child: Text('Theme Settings Screen')),
    );
  }
}

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: const Center(child: Text('Security Settings Screen')),
    );
  }
}

class BackupSettingsScreen extends StatelessWidget {
  const BackupSettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup Settings')),
      body: const Center(child: Text('Backup Settings Screen')),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About ROS')),
      body: const Center(child: Text('About Screen')),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}