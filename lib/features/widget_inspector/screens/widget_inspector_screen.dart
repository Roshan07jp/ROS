import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WidgetInspectorScreen extends ConsumerWidget {
  const WidgetInspectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Inspector')),
      body: const Center(child: Text('Widget Inspector Screen - Coming Soon')),
    );
  }
}