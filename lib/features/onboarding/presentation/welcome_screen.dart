import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_wrapper.dart';

class WelcomeScreen extends StatefulWidget {
  final String? injectedName;

  const WelcomeScreen({super.key, this.injectedName});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void initState() {
    super.initState();
    _validateHardwareToken();
  }

  Future<void> _validateHardwareToken() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('user-disabled') || errorStr.contains('user-not-found')) {
        await FirebaseAuth.instance.signOut();
        if (mounted) context.go('/auth-start');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final headerFontSize = (screenWidth * 0.12).clamp(40.0, 56.0);
    final double textScale = isTablet ? 1.25 : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFC5CAF0),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1E1E2C)));
                  }

                  if (!snapshot.hasData && FirebaseAuth.instance.currentUser == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.go('/auth-start');
                    });
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1E1E2C)));
                  }

                  final user = snapshot.data ?? FirebaseAuth.instance.currentUser;

                  String displayName = 'Partner';
                  if (widget.injectedName != null && widget.injectedName!.trim().isNotEmpty) {
                    displayName = widget.injectedName!.trim();
                  } else if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
                    displayName = user.displayName!.trim();
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Welcome, $displayName!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.urbanist(
                            fontSize: headerFontSize,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E1E2C),
                            letterSpacing: -1.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * textScale),

                      Text(
                        "Let's get you connected.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 18 * textScale,
                          color: const Color(0xFF1E1E2C).withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 64 * textScale),

                      // APPLE AESTHETIC: Borderless, clean stadium buttons
                      ElevatedButton(
                        onPressed: () => context.push('/pending'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF08080),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: Text('Create New Space', style: GoogleFonts.inter(fontSize: 18 * textScale, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 16 * textScale),

                      ElevatedButton(
                        onPressed: () => context.push('/invite'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E1E2C),
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: Text('I have a code', style: GoogleFonts.inter(fontSize: 18 * textScale, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                }
            ),
          ),
        ),
      ),
    );
  }
}