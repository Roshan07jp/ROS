import 'package:flutter/material.dart';

class TerminalDashboardScreen extends StatelessWidget {
  const TerminalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ROS Terminal')),
      body: const Center(
        child: Text('Terminal Dashboard - Coming Soon'),
      ),
    );
  }
}