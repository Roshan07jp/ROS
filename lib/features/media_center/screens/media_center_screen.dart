import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaCenterScreen extends ConsumerWidget {
  const MediaCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Center')),
      body: const Center(child: Text('Media Center Screen - Coming Soon')),
    );
  }
}