import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to ROS')),
      body: const Center(
        child: Text('Onboarding Screen - Coming Soon'),
      ),
    );
  }
}