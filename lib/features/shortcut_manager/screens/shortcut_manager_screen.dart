import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShortcutManagerScreen extends ConsumerWidget {
  const ShortcutManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shortcut Manager')),
      body: const Center(child: Text('Shortcut Manager Screen - Coming Soon')),
    );
  }
}