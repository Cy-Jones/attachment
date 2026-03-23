import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/network/connectivity_wrapper.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: AttachmentApp()));
}

final themeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    scaffoldBackgroundColor: const Color(0xFFC5CAF0),
    primaryColor: const Color(0xFFF08080),
    // 1. THE GLOBAL BASELINE: All UI, messages, and inputs default to Inter
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: const Color(0xFF1E1E2C),
      displayColor: const Color(0xFF1E1E2C),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: 'Inter', // Explicit override for buttons
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
});

class AttachmentApp extends ConsumerWidget {
  const AttachmentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Attachment',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ConnectivityWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}