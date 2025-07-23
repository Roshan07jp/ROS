import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/themes/app_themes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _glowController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Start animations in sequence
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _glowController.repeat(reverse: true);

    // Navigate after splash duration
    await Future.delayed(AppConstants.splashDuration);
    _navigateToNext();
  }

  void _navigateToNext() {
    final appSettings = ref.read(appSettingsProvider);
    
    if (appSettings.firstLaunch) {
      context.go('/onboarding');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = ref.watch(colorSchemeProvider);
    final terminalColors = AppThemes.terminalColorSchemes[colorScheme]!;

    return Scaffold(
      backgroundColor: terminalColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              terminalColors.background,
              terminalColors.background.withOpacity(0.8),
              terminalColors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated ROS Logo
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                terminalColors.foreground.withOpacity(0.3),
                                terminalColors.foreground.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: terminalColors.foreground.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: terminalColors.foreground.withOpacity(
                                      0.5 + (_glowAnimation.value * 0.5),
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'ROS',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: terminalColors.foreground,
                                      shadows: [
                                        Shadow(
                                          color: terminalColors.foreground.withOpacity(0.5),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Animated Title
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          AppConstants.splashTitle,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: terminalColors.foreground,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: terminalColors.foreground.withOpacity(0.3),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.appFullName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: terminalColors.foreground.withOpacity(0.8),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Animated Subtitle
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: terminalColors.foreground.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: terminalColors.foreground.withOpacity(0.05),
                      ),
                      child: Text(
                        AppConstants.splashSubtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: terminalColors.foreground.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Loading Animation
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Terminal-style loading indicator
                          Container(
                            width: 200,
                            height: 4,
                            decoration: BoxDecoration(
                              color: terminalColors.foreground.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: AnimatedBuilder(
                              animation: _glowController,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    terminalColors.foreground.withOpacity(
                                      0.7 + (_glowAnimation.value * 0.3),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              final dots = '.' * ((_glowController.value * 3).floor() + 1);
                              return Text(
                                'Initializing$dots',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 14,
                                  color: terminalColors.foreground.withOpacity(0.7),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Created by text
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Text(
                        AppConstants.splashCreatedBy,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: terminalColors.foreground.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}