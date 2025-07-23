import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class APITestingScreen extends ConsumerWidget {
  const APITestingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Testing')),
      body: const Center(child: Text('API Testing Screen - Coming Soon')),
    );
  }
}