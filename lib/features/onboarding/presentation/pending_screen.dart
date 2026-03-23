import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_wrapper.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  String _inviteCode = '';
  bool _isGenerating = true;
  bool _isLinked = false;
  StreamSubscription<DocumentSnapshot>? _inviteSubscription;

  @override
  void initState() {
    super.initState();
    _initializeHostSession();
  }

  @override
  void dispose() {
    _inviteSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeHostSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) context.go('/auth-start');
      return;
    }

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));

    try {
      await FirebaseFirestore.instance.collection('invites').doc(code).set({
        'hostId': user.uid,
        'hostName': user.displayName ?? 'Partner',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) setState(() { _inviteCode = code; _isGenerating = false; });

      _inviteSubscription = FirebaseFirestore.instance.collection('invites').doc(code).snapshots().listen((snapshot) {
        if (!snapshot.exists) return;
        final data = snapshot.data();
        if (data != null && data['status'] == 'linked') {
          _inviteSubscription?.cancel();
          if (mounted) {
            setState(() => _isLinked = true);
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) context.go('/home');
            });
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating code: $e', style: GoogleFonts.inter()), backgroundColor: Colors.red));
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _copyToClipboard() async {
    if (_inviteCode.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _inviteCode));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final headerFontSize = (screenWidth * 0.08).clamp(28.0, 42.0);
    final double textScale = isTablet ? 1.25 : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFB5BDE0),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  // APPLE AESTHETIC: Very soft, dispersed shadow
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80 * textScale, height: 80 * textScale,
                      decoration: const BoxDecoration(color: Color(0xFFF08080), shape: BoxShape.circle),
                      child: Icon(Icons.favorite_rounded, color: Colors.white, size: 40 * textScale),
                    ),
                    SizedBox(height: 24 * textScale),

                    Text(
                      'Partner Link',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E1E2C),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 16 * textScale),

                    Text(
                      'Share this code with your partner\nto link your accounts',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16 * textScale,
                        color: const Color(0xFF888BAA),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 32 * textScale),

                    // APPLE AESTHETIC: Light frosted background, dark text for code
                    Container(
                      height: 64 * textScale,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF2F3FB),
                          borderRadius: BorderRadius.circular(16)
                      ),
                      child: _isGenerating
                          ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF1E1E2C), strokeWidth: 2.5)))
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _inviteCode,
                            style: GoogleFonts.inter(
                              fontSize: 24 * textScale,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E1E2C), // High contrast dark
                              letterSpacing: 3.0,
                            ),
                          ),
                          GestureDetector(
                            onTap: _copyToClipboard,
                            child: Icon(Icons.copy_all_rounded, color: const Color(0xFF1E1E2C), size: 28 * textScale),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32 * textScale),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _isLinked ? 'Partner linked successfully! Redirecting...' : 'Waiting for partner to join...',
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          fontSize: 14 * textScale,
                          color: _isLinked ? Colors.green.shade600 : const Color(0xFF888BAA),
                          fontWeight: _isLinked ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: FloatingActionButton(
          onPressed: () => context.pop(),
          backgroundColor: Colors.white.withOpacity(0.4),
          elevation: 0,
          mini: true,
          child: const Padding(
            padding: EdgeInsets.only(right: 2.0),
            child: Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E1E2C), size: 20),
          ),
        ),
      ),
    );
  }
}