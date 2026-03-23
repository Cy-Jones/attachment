import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Onboarding & System Screens ---
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/name_entry_screen.dart';
import '../../features/onboarding/presentation/pending_screen.dart';
import '../../features/onboarding/presentation/invite_screen.dart';
import '../../features/space/presentation/home_screen.dart';

// --- Authentication Screens ---
import '../../features/auth/presentation/auth_start_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/phone_screen.dart';
import '../../features/auth/presentation/verify_screen.dart';

// 1. GLOBAL ROOT KEY: The hardware-level bridge.
// This allows background callbacks from Firebase to trigger navigation
// even if the active screen was temporarily desynced by the OS.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',

    // 2. REDIRECT SILENCER: The iOS Safari Fix.
    // When Safari redirects back to the app with a token, GoRouter naturally
    // tries to find a route for that URL. Returning 'null' here tells the
    // engine: "Do nothing. Stay on the current page and let the Firebase SDK handle the URL."
    redirect: (context, state) {
      final uri = state.uri.toString();
      if (uri.contains('firebaseauth') || uri.contains('link?deep_link_id')) {
        return null;
      }
      return null;
    },

    // 3. ERROR RECOVERY: Catches malformed deep links or reCAPTCHA failures.
    errorBuilder: (context, state) {
      final uriString = state.uri.toString();

      if (uriString.contains('firebaseauth') || state.uri.path == '/link') {
        final firebaseError = state.uri.queryParameters['firebaseError'];

        if (firebaseError != null) {
          String decodedError = "Security verification failed.";
          try {
            final Map<String, dynamic> errorMap = jsonDecode(firebaseError);
            decodedError = errorMap['message'] ?? decodedError;
          } catch (_) {}

          return Scaffold(
            backgroundColor: const Color(0xFFC5CAF0),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security_rounded, color: Color(0xFF1E1E2C), size: 64),
                    const SizedBox(height: 24),
                    Text('Verification Issue', textAlign: TextAlign.center,
                        style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFF1E1E2C))),
                    const SizedBox(height: 12),
                    Text(decodedError, textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: const Color(0xFF1E1E2C), fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.go('/phone'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF08080),
                          foregroundColor: const Color(0xFF1E1E2C),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Text('Retry Phone Login', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        return const Scaffold(
          backgroundColor: Color(0xFFC5CAF0),
          body: Center(child: CircularProgressIndicator(color: Color(0xFF1E1E2C))),
        );
      }

      return Scaffold(body: Center(child: Text('Navigation error: $uriString')));
    },

    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/auth-start', builder: (context, state) => const AuthStartScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/phone', builder: (context, state) => const PhoneScreen()),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          // Unpacks the data packet (phone + verificationId)
          final payload = state.extra as Map<String, dynamic>? ?? {};
          final phone = payload['phone'] as String? ?? 'Unknown Number';
          final vid = payload['verificationId'] as String? ?? '';
          return VerifyScreen(phoneNumber: phone, verificationId: vid);
        },
      ),
      GoRoute(path: '/name-entry', builder: (context, state) => const NameEntryScreen()),
      GoRoute(
        path: '/welcome',
        builder: (context, state) {
          final name = state.extra as String?;
          return WelcomeScreen(injectedName: name);
        },
      ),
      GoRoute(path: '/pending', builder: (context, state) => const PendingScreen()),
      GoRoute(path: '/invite', builder: (context, state) => const InviteScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});