import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DockerManagerScreen extends ConsumerWidget {
  const DockerManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Docker Manager')),
      body: const Center(child: Text('Docker Manager Screen - Coming Soon')),
    );
  }
}