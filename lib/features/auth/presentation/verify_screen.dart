import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/responsive_wrapper.dart';
import '../providers/auth_provider.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId; // STRICT DATA PIPELINE

  const VerifyScreen({super.key, required this.phoneNumber, required this.verificationId});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
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

  // FIREBASE OTP VALIDATION
  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).verifyOTP(
          verificationId: widget.verificationId,
          smsCode: _otpController.text
      );

      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user?.displayName == null || user!.displayName!.trim().isEmpty) {
          context.go('/name-entry');
        } else {
          context.go('/welcome');
        }
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
      _otpController.clear();
      FocusScope.of(context).requestFocus(_focusNode);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final headerFontSize = (screenWidth * 0.1).clamp(36.0, 52.0);
    final double textScale = isTablet ? 1.25 : 1.0;
    final double imageHeight = (screenWidth * 0.55).clamp(200.0, 380.0);

    return Scaffold(
      backgroundColor: const Color(0xFFC5CAF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Center(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Padding(padding: EdgeInsets.only(right: 2.0), child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                SizedBox(height: imageHeight + 20, child: Center(child: SvgPicture.asset('assets/images/otp.svg', height: imageHeight, fit: BoxFit.contain))),
                const SizedBox(height: 32),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Verify Your Number', textAlign: TextAlign.center, style: GoogleFonts.urbanist(fontSize: headerFontSize, fontWeight: FontWeight.w900, color: const Color(0xFF1E1E2C), letterSpacing: -1.0)),
                ),
                const SizedBox(height: 16),

                Text('Please enter the 6 digit code sent to\n${widget.phoneNumber}', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 15 * textScale, color: const Color(0xFF888BAA), fontWeight: FontWeight.w500, height: 1.4)),
                const SizedBox(height: 48),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.0,
                      child: TextFormField(
                        controller: _otpController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                        onChanged: (val) {
                          setState(() {});
                          if (val.length == 6) {
                            _focusNode.unfocus();
                            _verifyOTP();
                          }
                        },
                      ),
                    ),

                    GestureDetector(
                      onTap: () => FocusScope.of(context).requestFocus(_focusNode),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          String char = '';
                          if (_otpController.text.length > index) char = _otpController.text[index];

                          bool isFocused = _focusNode.hasFocus && _otpController.text.length == index;
                          bool isFilled = char.isNotEmpty;

                          return Container(
                            width: 44 * textScale,
                            height: 60 * textScale,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isFocused || isFilled ? const Color(0xFF1E1E2C) : Colors.white,
                                  width: isFocused ? 2.0 : 1.0,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(char, style: GoogleFonts.inter(fontSize: 32 * textScale, fontWeight: FontWeight.w600, color: const Color(0xFF1E1E2C))),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Text(_formattedTime, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14 * textScale, color: Colors.white, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _secondsRemaining == 0
                      ? () {
                    setState(() => _secondsRemaining = 60);
                    _startTimer();
                  }
                      : null,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inter(color: const Color(0xFF888BAA), fontSize: 14 * textScale, fontWeight: FontWeight.w500),
                      children: [
                        const TextSpan(text: "Didn't receive the code? "),
                        TextSpan(text: 'Resend', style: GoogleFonts.inter(color: _secondsRemaining == 0 ? const Color(0xFF1E1E2C) : const Color(0xFF888BAA), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _otpController.text.length == 6 && !_isLoading ? _verifyOTP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF08080),
                    disabledBackgroundColor: const Color(0xFFF08080).withOpacity(0.5),
                    foregroundColor: const Color(0xFF1E1E2C),
                    disabledForegroundColor: const Color(0xFF1E1E2C).withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF1E1E2C), strokeWidth: 2.5))
                      : Text('Verify', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}