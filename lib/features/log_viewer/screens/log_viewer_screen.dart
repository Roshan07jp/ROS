import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogViewerScreen extends ConsumerWidget {
  const LogViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Viewer')),
      body: const Center(child: Text('Log Viewer Screen - Coming Soon')),
    );
  }
}