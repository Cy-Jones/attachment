import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 1. Let the splash animation play for 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      // 2. Query the local hardware secure storage for an existing session
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // TOKEN FOUND: Bypass auth and jump straight into the app
        context.go('/welcome');
      } else {
        // NO TOKEN: Route to the authentication flow
        context.go('/auth-start');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD8DCF8),
              Color(0xFFB5BCE4),
            ],
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/logo.svg',
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}