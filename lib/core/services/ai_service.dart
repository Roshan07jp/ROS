import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/ai_message.dart';
import '../models/ai_suggestion.dart';

class AIService {
  static AIService? _instance;
  static AIService get instance => _instance ??= TerminalAIService._();
  AIService._();

  bool _isInitialized = false;
  String? _apiKey;
  String _model = 'gpt-3.5-turbo';
  final List<AIMessage> _conversationHistory = [];
  final StreamController<AIMessage> _messageController = StreamController<AIMessage>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;
  String get model => _model;
  List<AIMessage> get conversationHistory => List.unmodifiable(_conversationHistory);
  Stream<AIMessage> get messageStream => _messageController.stream;

  // Initialize AI Service
  static Future<void> initialize() async {
    await instance._initializeAI();
  }

  Future<void> _initializeAI() async {
    try {
      debugPrint('Initializing AI service...');
      
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString('ai_api_key');
      _model = prefs.getString('ai_model') ?? 'gpt-3.5-turbo';

      _isInitialized = true;
      debugPrint('AI service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize AI service: $e');
      throw Exception('AI initialization failed: $e');
    }
  }

  // Configure API Key
  Future<void> configureAPIKey(String apiKey) async {
    try {
      _apiKey = apiKey;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_api_key', apiKey);
      debugPrint('AI API key configured successfully');
    } catch (e) {
      debugPrint('Failed to configure AI API key: $e');
      throw Exception('Failed to configure API key: $e');
    }
  }

  // Set AI Model
  Future<void> setModel(String model) async {
    try {
      _model = model;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_model', model);
      debugPrint('AI model set to: $model');
    } catch (e) {
      debugPrint('Failed to set AI model: $e');
    }
  }

  // Send Message to AI
  Future<AIMessage> sendMessage(String message, {AIMessageType type = AIMessageType.user}) async {
    if (!_isInitialized) {
      throw Exception('AI service not initialized');
    }

    if (!isConfigured) {
      throw Exception('AI service not configured. Please set API key.');
    }

    try {
      // Add user message to history
      final userMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        type: type,
        timestamp: DateTime.now(),
        role: 'user',
      );

      _conversationHistory.add(userMessage);
      _messageController.add(userMessage);

      // Get AI response
      final aiResponse = await _getAIResponse(message);

      // Add AI response to history
      final aiMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiResponse,
        type: AIMessageType.assistant,
        timestamp: DateTime.now(),
        role: 'assistant',
      );

      _conversationHistory.add(aiMessage);
      _messageController.add(aiMessage);

      return aiMessage;
    } catch (e) {
      debugPrint('Failed to send message to AI: $e');
      
      // Return error message
      final errorMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error: ${e.toString()}',
        type: AIMessageType.error,
        timestamp: DateTime.now(),
        role: 'assistant',
      );

      _conversationHistory.add(errorMessage);
      _messageController.add(errorMessage);

      return errorMessage;
    }
  }

  Future<String> _getAIResponse(String message) async {
    if (!isConfigured) {
      return 'AI service is not configured. Please set your OpenAI API key in settings.';
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.openAIAPIUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': _model,
          'messages': _buildConversationContext(message),
          'max_tokens': 1000,
          'temperature': 0.7,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('AI API request failed: $e');
      
      // Fallback to predefined responses
      return _getFallbackResponse(message);
    }
  }

  List<Map<String, String>> _buildConversationContext(String currentMessage) {
    final messages = <Map<String, String>>[];

    // System prompt for terminal assistant
    messages.add({
      'role': 'system',
      'content': '''You are ROS AI Assistant, an advanced AI helper for the ROS (Roshan Operating System) terminal application. You are an expert in:

1. Linux/Unix commands and terminal operations
2. Bash scripting and automation
3. Package management and system administration
4. Network tools and security
5. Development tools and programming
6. Debugging and troubleshooting

Your primary tasks:
- Help users with terminal commands and explain their usage
- Generate bash scripts based on user requirements
- Explain command outputs and error messages
- Suggest best practices and security considerations
- Provide step-by-step guidance for complex tasks

Keep responses concise but informative. Always prioritize security and safety in your recommendations.'''
    });

    // Add conversation history (last 10 messages for context)
    final recentHistory = _conversationHistory.takeLast(10);
    for (final msg in recentHistory) {
      if (msg.type != AIMessageType.error) {
        messages.add({
          'role': msg.role,
          'content': msg.content,
        });
      }
    }

    // Add current message
    messages.add({
      'role': 'user',
      'content': currentMessage,
    });

    return messages;
  }

  String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();

    // Command help responses
    if (lowerMessage.contains('help') || lowerMessage.startsWith('/ai help')) {
      return '''ROS AI Assistant Commands:

• Ask about any Linux/terminal command
• Request bash script generation
• Get explanations for error messages
• Ask for troubleshooting help
• Request security advice

Examples:
- "How do I list files with permissions?"
- "Create a script to backup my home directory"
- "Explain this error: permission denied"
- "How to install packages securely?"

I'm here to help with all your terminal needs!''';
    }

    // Command explanations
    if (lowerMessage.contains('ls ') || lowerMessage.startsWith('ls')) {
      return '''The 'ls' command lists directory contents.

Common options:
• ls -l : Long format with permissions, size, date
• ls -la : Include hidden files
• ls -lh : Human readable file sizes
• ls -lt : Sort by modification time
• ls -R : Recursive listing

Example: ls -la shows all files with detailed information.''';
    }

    if (lowerMessage.contains('cd ') || lowerMessage.startsWith('cd')) {
      return '''The 'cd' command changes the current directory.

Usage:
• cd /path/to/directory : Go to specific path
• cd .. : Go up one directory
• cd ~ : Go to home directory
• cd - : Go to previous directory
• cd : Go to home directory (same as cd ~)

Example: cd /usr/local/bin''';
    }

    if (lowerMessage.contains('chmod') || lowerMessage.contains('permission')) {
      return '''File permissions in Linux use chmod command:

Format: chmod [permissions] [file]

Numeric method:
• 4 = read (r)
• 2 = write (w)  
• 1 = execute (x)

Examples:
• chmod 755 script.sh : rwxr-xr-x
• chmod 644 file.txt : rw-r--r--
• chmod +x script.sh : Add execute permission

Use 'ls -l' to view current permissions.''';
    }

    if (lowerMessage.contains('git')) {
      return '''Git commands for version control:

Basic workflow:
• git init : Initialize repository
• git add . : Stage all changes
• git commit -m "message" : Commit changes
• git push : Upload to remote
• git pull : Download from remote

Useful commands:
• git status : Check repository status
• git log : View commit history
• git branch : List/create branches
• git clone [url] : Download repository''';
    }

    if (lowerMessage.contains('package') || lowerMessage.contains('install')) {
      return '''Package management in ROS:

Using pkg (Termux package manager):
• pkg update : Update package lists
• pkg upgrade : Upgrade installed packages
• pkg install [package] : Install package
• pkg uninstall [package] : Remove package
• pkg search [term] : Search packages
• pkg list-installed : Show installed packages

Example: pkg install python git curl''';
    }

    if (lowerMessage.contains('script') || lowerMessage.contains('bash')) {
      return '''Bash scripting basics:

Create a script:
1. nano script.sh
2. Add #!/bin/bash at the top
3. Write your commands
4. Save and exit
5. chmod +x script.sh
6. ./script.sh to run

Variables: var="value"
Conditions: if [ condition ]; then ... fi
Loops: for i in {1..10}; do ... done

Want me to create a specific script for you?''';
    }

    // Default helpful response
    return '''I'm here to help with terminal commands and Linux operations!

You can ask me about:
• Linux/Unix commands (ls, cd, chmod, etc.)
• Bash scripting and automation
• Package installation and management
• Network tools and troubleshooting
• File operations and permissions
• Git version control
• Security best practices

Try asking something like:
- "How do I find files containing text?"
- "Create a backup script"
- "Explain file permissions"
- "Help with git commands"

What would you like help with?''';
  }

  // Generate Command Suggestions
  Future<List<AISuggestion>> getCommandSuggestions(String partialCommand) async {
    final suggestions = <AISuggestion>[];

    // Common command completions
    final commandMap = {
      'ls': ['ls -la', 'ls -lh', 'ls -lt', 'ls -R'],
      'cd': ['cd ..', 'cd ~', 'cd -', 'cd /'],
      'git': ['git status', 'git add .', 'git commit', 'git push', 'git pull'],
      'pkg': ['pkg update', 'pkg upgrade', 'pkg install', 'pkg search'],
      'chmod': ['chmod 755', 'chmod 644', 'chmod +x'],
      'cp': ['cp -r', 'cp -v', 'cp -i'],
      'mv': ['mv -v', 'mv -i'],
      'rm': ['rm -rf', 'rm -i', 'rm -v'],
      'find': ['find . -name', 'find . -type f', 'find . -type d'],
      'grep': ['grep -r', 'grep -i', 'grep -n'],
    };

    for (final entry in commandMap.entries) {
      if (entry.key.startsWith(partialCommand)) {
        for (final suggestion in entry.value) {
          suggestions.add(AISuggestion(
            text: suggestion,
            description: 'Common ${entry.key} command',
            type: AISuggestionType.command,
          ));
        }
      }
    }

    return suggestions;
  }

  // Generate Script
  Future<String> generateScript(String description) async {
    try {
      final prompt = '''Create a bash script for: $description

Requirements:
- Include proper shebang (#!/bin/bash)
- Add comments explaining each step
- Include error handling where appropriate
- Make it executable and safe
- Follow bash best practices

Return only the script code.''';

      final response = await sendMessage(prompt, type: AIMessageType.system);
      return response.content;
    } catch (e) {
      return '''#!/bin/bash
# Auto-generated script for: $description
# Generated by ROS AI Assistant

echo "Script generation failed: $e"
echo "Please provide more specific requirements."

# Template script structure:
# 1. Set variables
# 2. Check prerequisites
# 3. Main operations
# 4. Cleanup and exit

exit 1''';
    }
  }

  // Explain Command Output
  Future<String> explainOutput(String command, String output) async {
    try {
      final prompt = '''Explain this command output:

Command: $command
Output: $output

Please explain what this output means, any important information it contains, and if there are any warnings or errors to be aware of.''';

      final response = await sendMessage(prompt, type: AIMessageType.system);
      return response.content;
    } catch (e) {
      return 'Unable to explain output at the moment. Please check the command documentation or try rephrasing your question.';
    }
  }

  // Clear Conversation History
  void clearHistory() {
    _conversationHistory.clear();
    debugPrint('AI conversation history cleared');
  }

  // Get Quick Help
  String getQuickHelp(String topic) {
    final helpMap = {
      'commands': 'Common commands: ls, cd, pwd, mkdir, rm, cp, mv, chmod, chown, find, grep',
      'files': 'File operations: touch, cat, less, head, tail, wc, sort, uniq',
      'network': 'Network tools: ping, wget, curl, ssh, scp, netstat, nmap',
      'processes': 'Process management: ps, top, htop, kill, killall, jobs, bg, fg',
      'packages': 'Package management: pkg update, pkg install, pkg search, pkg list-installed',
      'git': 'Git basics: init, add, commit, push, pull, status, log, branch',
      'permissions': 'Permissions: chmod, chown, chgrp, umask, sudo',
      'scripting': 'Bash scripting: variables, conditions, loops, functions',
    };

    return helpMap[topic.toLowerCase()] ?? 'Available help topics: ${helpMap.keys.join(', ')}';
  }

  // Dispose
  Future<void> dispose() async {
    await _messageController.close();
    _conversationHistory.clear();
  }
}

// Mock implementation for development
class TerminalAIService extends AIService {
  TerminalAIService._() : super._();
}

extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}