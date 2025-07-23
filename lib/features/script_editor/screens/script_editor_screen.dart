import 'package:flutter/material.dart';

class ScriptEditorScreen extends StatelessWidget {
  final String? filePath;
  
  const ScriptEditorScreen({super.key, this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Script Editor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Script Editor Screen - Coming Soon'),
            if (filePath != null) ...[
              const SizedBox(height: 16),
              Text('File: $filePath'),
            ],
          ],
        ),
      ),
    );
  }
}