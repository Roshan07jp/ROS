import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskSchedulerScreen extends ConsumerWidget {
  const TaskSchedulerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Scheduler')),
      body: const Center(child: Text('Task Scheduler Screen - Coming Soon')),
    );
  }
}