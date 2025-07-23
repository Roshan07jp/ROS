import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CloudStorageScreen extends ConsumerWidget {
  const CloudStorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Storage')),
      body: const Center(child: Text('Cloud Storage Screen - Coming Soon')),
    );
  }
}