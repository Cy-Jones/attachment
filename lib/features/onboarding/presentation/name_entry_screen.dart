import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_wrapper.dart';

class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    } catch (_) {}

    try {
      await FirebaseAuth.instance.currentUser?.reload();
    } catch (_) {}

    if (mounted) {
      context.go('/welcome', extra: name);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Adjusted header size slightly to give the FittedBox more native breathing room
    final headerFontSize = (screenWidth * 0.09).clamp(32.0, 48.0);
    final double textScale = isTablet ? 1.25 : 1.0;

    final double imageHeight = (screenWidth * 0.85).clamp(280.0, 450.0);

    return Scaffold(
      backgroundColor: const Color(0xFFC5CAF0),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32 * textScale),

                SizedBox(
                  height: imageHeight,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/ballon_hero.svg',
                      height: imageHeight,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: imageHeight,
                        alignment: Alignment.center,
                        child: Text('ASSET ERROR:\nPlease fully STOP the app and hit PLAY\nso Flutter can bundle the new SVG.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32 * textScale),

                // APPLE AESTHETIC: Separated the text to guarantee single-line scaling
                Text(
                  'Yay!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 32 * textScale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1E2C).withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'What should we call you?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E1E2C),
                      letterSpacing: -1.0,
                    ),
                  ),
                ),

                SizedBox(height: 32 * textScale),

                // APPLE AESTHETIC: Clean white input, no harsh borders, subtle shadow
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 20 * textScale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E2C),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Your Name',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF1E1E2C).withOpacity(0.3),
                        fontSize: 20 * textScale,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 22),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _saveName(),
                  ),
                ),
                const SizedBox(height: 20),

                // APPLE AESTHETIC: Fully rounded, borderless, high-contrast button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E2C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text('Continue', style: GoogleFonts.inter(fontSize: 18 * textScale, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}