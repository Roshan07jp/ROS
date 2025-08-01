import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteDesktopScreen extends ConsumerWidget {
  const RemoteDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remote Desktop')),
      body: const Center(child: Text('Remote Desktop Screen - Coming Soon')),
    );
  }
}