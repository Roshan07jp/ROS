import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CodePlaygroundScreen extends ConsumerStatefulWidget {
  const CodePlaygroundScreen({super.key});

  @override
  ConsumerState<CodePlaygroundScreen> createState() => _CodePlaygroundScreenState();
}

class _CodePlaygroundScreenState extends ConsumerState<CodePlaygroundScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _selectedLanguage = 'python';
  String _output = '';
  bool _isRunning = false;

  final List<String> _supportedLanguages = [
    'python',
    'javascript',
    'bash',
    'dart',
    'java',
    'cpp',
    'c',
    'go',
    'rust',
    'php',
    'ruby',
    'swift',
  ];

  final Map<String, String> _codeTemplates = {
    'python': '''# Python Code Playground
print("Hello, ROS!")

# Example: Simple calculation
def calculate_fibonacci(n):
    if n <= 1:
        return n
    return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)

print(f"Fibonacci(10): {calculate_fibonacci(10)}")
''',
    'javascript': '''// JavaScript Code Playground
console.log("Hello, ROS!");

// Example: Simple function
function factorial(n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

console.log(`Factorial(5): ${factorial(5)}`);
''',
    'bash': '''#!/bin/bash
# Bash Script Playground
echo "Hello, ROS!"

# Example: System information
echo "Current directory: $(pwd)"
echo "Date: $(date)"
echo "User: $(whoami)"

# Simple loop
for i in {1..5}; do
    echo "Iteration: $i"
done
''',
  };

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  void _loadTemplate() {
    _codeController.text = _codeTemplates[_selectedLanguage] ?? '// Code here...';
  }

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _output = 'Running...';
    });

    // Simulate code execution
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRunning = false;
      _output = '''Code executed successfully!

Language: $_selectedLanguage
Code length: ${_codeController.text.length} characters

Output:
Hello, ROS!
Process completed with exit code 0

Execution time: 1.23s
Memory usage: 15.6 MB
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Playground'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (language) {
              setState(() {
                _selectedLanguage = language;
                _loadTemplate();
              });
            },
            itemBuilder: (context) => _supportedLanguages
                .map((lang) => PopupMenuItem(
                      value: lang,
                      child: Text(lang.toUpperCase()),
                    ))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save code logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code saved!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Language selector bar
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                const Icon(Icons.code),
                const SizedBox(width: 8),
                Text(
                  'Language: ${_selectedLanguage.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runCode,
                  icon: _isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isRunning ? 'Running...' : 'Run'),
                ),
              ],
            ),
          ),

          // Code editor
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _codeController,
                maxLines: null,
                expands: true,
                style: GoogleFonts.jetBrainsMono(fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.0),
                  hintText: 'Write your code here...',
                ),
              ),
            ),
          ),

          // Output panel
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.black87,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.terminal, size: 16),
                        SizedBox(width: 8),
                        Text('Output', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _output.isEmpty ? 'Click "Run" to execute your code...' : _output,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.greenAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'clear',
            mini: true,
            onPressed: () {
              _codeController.clear();
              setState(() {
                _output = '';
              });
            },
            child: const Icon(Icons.clear),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'share',
            mini: true,
            onPressed: () {
              // Share code logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code shared!')),
              );
            },
            child: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}