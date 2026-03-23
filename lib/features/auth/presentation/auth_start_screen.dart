import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_wrapper.dart';

class AuthStartScreen extends StatelessWidget {
  const AuthStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final double textScale = isTablet ? 1.2 : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFC5CAF0),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // 1. BRAND HEADER: Matches the bold 'Attachment' from reference
                Text(
                  'Attachment',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 48 * textScale,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E1E2C),
                    letterSpacing: -1.0,
                  ),
                ),

                const Spacer(),

                // 2. HERO ILLUSTRATION: Switched to PNG version
                // Ensure your file is named 'auth_hero.png' in assets/images/
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Image.asset(
                    'assets/images/auth_hero.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.people_alt_rounded,
                      size: 120,
                      color: Color(0xFF1E1E2C),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. DESCRIPTION TEXT: (As requested from your design prompt)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'A private space for your relationship. Share photos, chat, and connect deeply.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15 * textScale,
                      color: const Color(0xFF1E1E2C).withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                // 4. ACTION BUTTONS: Functional 'Get Started' and Login
                ElevatedButton(
                  onPressed: () => context.push('/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF08080),
                    foregroundColor: const Color(0xFF1E1E2C),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Color(0xFF1E1E2C), width: 1.2),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                      'Get Started',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F3FB),
                    foregroundColor: const Color(0xFF1E1E2C),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Color(0xFF1E1E2C), width: 1.2),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                      'I have an account',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)
                  ),
                ),

                const SizedBox(height: 32),

                // 5. SECURITY FOOTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF1E1E2C)),
                    const SizedBox(width: 8),
                    Text(
                      'Private & Secure',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E1E2C),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}