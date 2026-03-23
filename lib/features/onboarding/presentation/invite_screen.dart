import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_wrapper.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null) {
      _nameController.text = user!.displayName!;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14))),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E2C).withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        margin: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
      ),
    );
  }

  Future<void> _joinPartner() async {
    final code = _codeController.text.trim().toUpperCase();
    final name = _nameController.text.trim();

    if (code.length != 6) {
      _showError('Please enter a valid 6-character code.');
      return;
    }
    if (name.isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Authentication lost. Please log in again.');

      if (user.displayName != name) {
        try { await user.updateDisplayName(name); } catch (_) {}
        try { await user.reload(); } catch (_) {}
      }

      final inviteRef = FirebaseFirestore.instance.collection('invites').doc(code);
      final spaceRef = FirebaseFirestore.instance.collection('spaces').doc();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final inviteSnapshot = await transaction.get(inviteRef);

        if (!inviteSnapshot.exists) {
          throw Exception('Invalid invite code. Please check with your partner.');
        }

        final data = inviteSnapshot.data()!;

        if (data['status'] == 'linked') {
          throw Exception('This code has already been used.');
        }

        if (data['hostId'] == user.uid) {
          throw Exception('You cannot link an account to itself.');
        }

        final hostId = data['hostId'] as String;
        final hostName = data['hostName'] as String;

        transaction.set(spaceRef, {
          'members': [hostId, user.uid],
          'createdAt': FieldValue.serverTimestamp(),
          'recentMessage': null,
        });

        final hostUserRef = FirebaseFirestore.instance.collection('users').doc(hostId);
        transaction.set(hostUserRef, {
          'name': hostName,
          'spaceId': spaceRef.id,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final clientUserRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        transaction.set(clientUserRef, {
          'name': name,
          'spaceId': spaceRef.id,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.update(inviteRef, {
          'clientId': user.uid,
          'clientName': name,
          'status': 'linked',
          'spaceId': spaceRef.id,
          'linkedAt': FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Linked successfully!', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14))),
              ],
            ),
            backgroundColor: Colors.green.shade700.withOpacity(0.95),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            margin: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final headerFontSize = (screenWidth * 0.08).clamp(28.0, 42.0);
    final double textScale = isTablet ? 1.25 : 1.0;

    InputDecoration slateInputDecoration(String hint) {
      return InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.5),
          fontSize: 22 * textScale,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: const Color(0xFF8C91B6),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () {
            if (hint.contains('EX:')) {
              _codeController.clear();
            } else {
              _nameController.clear();
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFB5BDE0),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Enter Invite Code',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist( // HERO Tier
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E1E2C),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 32 * textScale),

                    Text(
                      'Ask your partner for their code.',
                      style: GoogleFonts.inter( // UI Tier
                        fontSize: 16 * textScale,
                        color: const Color(0xFF888BAA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8 * textScale),

                    TextFormField(
                      controller: _codeController,
                      style: GoogleFonts.inter(
                        fontSize: 24 * textScale,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) =>
                            newValue.copyWith(text: newValue.text.toUpperCase())),
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: slateInputDecoration('EX: AB12CD'),
                    ),
                    SizedBox(height: 24 * textScale),

                    Text(
                      'How should they see your name?',
                      style: GoogleFonts.inter(
                        fontSize: 16 * textScale,
                        color: const Color(0xFF888BAA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8 * textScale),

                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.inter(
                        fontSize: 24 * textScale,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      decoration: slateInputDecoration('Your name'),
                    ),
                    SizedBox(height: 32 * textScale),

                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Cancel', // Optically better than 'Back' in a horizontal stack
                              style: GoogleFonts.inter(
                                fontSize: 18 * textScale,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E1E2C),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16 * textScale),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _joinPartner,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF4B6B6),
                              disabledBackgroundColor: const Color(0xFFF4B6B6).withOpacity(0.5),
                              foregroundColor: const Color(0xFF1E1E2C),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: _isLoading ? Colors.transparent : const Color(0xFF1E1E2C),
                                    width: 1.2
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF1E1E2C), strokeWidth: 2.5))
                                : Text('Join Partner', style: GoogleFonts.inter(fontSize: 18 * textScale, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}