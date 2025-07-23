import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerformanceProfilerScreen extends ConsumerWidget {
  const PerformanceProfilerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Profiler')),
      body: const Center(child: Text('Performance Profiler Screen - Coming Soon')),
    );
  }
}