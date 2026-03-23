import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/responsive_wrapper.dart';
import '../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _keepLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13),
              ),
            ),
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

  InputDecoration _customInputDecoration({required String hint, required IconData prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0xFF9E9E9E), fontSize: 16, fontWeight: FontWeight.w400),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF9E9E9E), size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF1E1E2C), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF1E1E2C), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF1E1E2C), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).loginWithEmail(email, password);
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final creds = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (creds != null) {
        final navContext = rootNavigatorKey.currentContext;
        if (navContext != null) {
          if (creds.user?.displayName == null || creds.user!.displayName!.isEmpty) {
            navContext.go('/name-entry');
          } else {
            navContext.go('/welcome');
          }
        }
      }
    } catch (e) {
      _showError('Google Sign-In failed.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth > 600 ? 1.25 : 1.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 72,
        leading: Center(
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
                const SizedBox(height: 40),

                Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 48 * textScale,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E1E2C),
                  ),
                ),

                const SizedBox(height: 60),

                TextFormField(
                  controller: _emailController,
                  decoration: _customInputDecoration(
                    hint: 'Email',
                    prefixIcon: Icons.mail_outline,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _customInputDecoration(
                    hint: 'Password',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF9E9E9E),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _keepLogin = !_keepLogin),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _keepLogin,
                              activeColor: const Color(0xFF1E1E2C),
                              onChanged: (v) => setState(() => _keepLogin = v ?? false),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Keep Login',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2C), fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF08080),
                    foregroundColor: const Color(0xFF1E1E2C),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E1E2C)),
                  )
                      : Text(
                    'Login',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),

                const SizedBox(height: 24),

                // EXPANDED WIDGET TREE TO PREVENT COMPILER AST PARSING CRASHES
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isLoading ? null : _signInWithGoogle,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('assets/icons/google_logo.svg', width: 20 * textScale),
                            const SizedBox(width: 10),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15 * textScale),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => context.pushReplacement('/register'),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(color: const Color(0xFF6B6E8C), fontSize: 14 * textScale),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Register',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF1E1E2C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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