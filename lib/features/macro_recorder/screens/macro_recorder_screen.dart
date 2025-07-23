import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MacroRecorderScreen extends ConsumerWidget {
  const MacroRecorderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Macro Recorder')),
      body: const Center(child: Text('Macro Recorder Screen - Coming Soon')),
    );
  }
}