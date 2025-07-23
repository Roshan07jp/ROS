import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyBQcahJ__WFtiNX51DKTQLSduFrTaeDDUk';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  final http.Client _client = http.Client();

  // Generate content using Gemini Pro
  Future<String> generateContent(String prompt) async {
    try {
      final url = Uri.parse('$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey');
      
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] ?? 'No response generated';
          }
        }
        return 'No valid response from Gemini';
      } else {
        throw Exception('Failed to generate content: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gemini API Error: $e');
    }
  }

  // Generate terminal command suggestions
  Future<String> generateTerminalCommand(String description) async {
    final prompt = '''
You are a terminal command expert. Generate a precise terminal command for the following task:
"$description"

Provide only the command without explanation. If multiple commands are needed, separate them with &&.
Focus on commonly used terminal commands for Linux/Termux environment.
''';
    
    return await generateContent(prompt);
  }

  // Explain terminal commands
  Future<String> explainCommand(String command) async {
    final prompt = '''
Explain this terminal command in simple terms:
"$command"

Provide a clear, concise explanation of what this command does, including:
1. Main purpose
2. Key parameters/flags
3. Expected output
4. Any warnings or considerations
''';
    
    return await generateContent(prompt);
  }

  // Generate bash scripts
  Future<String> generateBashScript(String task) async {
    final prompt = '''
Create a bash script for the following task:
"$task"

Requirements:
- Include proper shebang
- Add comments explaining each section
- Include error handling
- Make it executable and safe
- Use best practices for bash scripting
''';
    
    return await generateContent(prompt);
  }

  // Security audit for commands
  Future<String> auditCommand(String command) async {
    final prompt = '''
Perform a security audit on this command:
"$command"

Analyze for:
1. Potential security risks
2. Permissions required
3. Data safety
4. Recommended alternatives if risky
5. Safety rating (Safe/Caution/Dangerous)

Provide a detailed security assessment.
''';
    
    return await generateContent(prompt);
  }

  // Code review and optimization
  Future<String> reviewCode(String code, String language) async {
    final prompt = '''
Review this $language code and provide suggestions for improvement:

```$language
$code
```

Focus on:
1. Code quality and best practices
2. Performance optimizations
3. Security considerations
4. Readability improvements
5. Bug detection
''';
    
    return await generateContent(prompt);
  }

  // Network analysis explanation
  Future<String> explainNetworkScan(String scanResults) async {
    final prompt = '''
Analyze and explain these network scan results:
"$scanResults"

Provide:
1. Summary of findings
2. Security implications
3. Recommended actions
4. Potential vulnerabilities
5. Next steps for investigation
''';
    
    return await generateContent(prompt);
  }

  // System optimization suggestions
  Future<String> optimizeSystem(String systemInfo) async {
    final prompt = '''
Based on this system information, provide optimization suggestions:
"$systemInfo"

Suggest:
1. Performance improvements
2. Resource optimization
3. Security enhancements
4. Maintenance tasks
5. Monitoring recommendations
''';
    
    return await generateContent(prompt);
  }

  void dispose() {
    _client.close();
  }
}

// Riverpod provider for Gemini service
final geminiServiceProvider = Provider<GeminiService>((ref) {
  final service = GeminiService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider for Gemini responses
final geminiResponseProvider = FutureProvider.family<String, String>((ref, prompt) async {
  final geminiService = ref.watch(geminiServiceProvider);
  return await geminiService.generateContent(prompt);
});

// Provider for command suggestions
final commandSuggestionProvider = FutureProvider.family<String, String>((ref, description) async {
  final geminiService = ref.watch(geminiServiceProvider);
  return await geminiService.generateTerminalCommand(description);
});

// Provider for command explanations
final commandExplanationProvider = FutureProvider.family<String, String>((ref, command) async {
  final geminiService = ref.watch(geminiServiceProvider);
  return await geminiService.explainCommand(command);
});

// Provider for bash script generation
final bashScriptProvider = FutureProvider.family<String, String>((ref, task) async {
  final geminiService = ref.watch(geminiServiceProvider);
  return await geminiService.generateBashScript(task);
});

// Provider for security audits
final securityAuditProvider = FutureProvider.family<String, String>((ref, command) async {
  final geminiService = ref.watch(geminiServiceProvider);
  return await geminiService.auditCommand(command);
});