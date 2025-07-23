import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeStudioScreen extends ConsumerWidget {
  const ThemeStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Studio')),
      body: const Center(child: Text('Theme Studio Screen - Coming Soon')),
    );
  }
}