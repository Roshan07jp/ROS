import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatabaseManagerScreen extends ConsumerWidget {
  const DatabaseManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Manager')),
      body: const Center(child: Text('Database Manager Screen - Coming Soon')),
    );
  }
}