import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._auth, this._googleSignIn);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // 1. Email/Password Registration
  Future<void> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') throw Exception('The password provided is too weak.');
      if (e.code == 'email-already-in-use') throw Exception('An account already exists for that email.');
      throw Exception(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 2. Email/Password Login
  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // FIREBASE ENUMERATION PATCH
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
        throw Exception('This user does not exist or the password is incorrect.');
      }
      throw Exception(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 3. Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // 4. Phone Auth: Trigger SMS
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // 5. Phone Auth: Verify OTP
  Future<UserCredential> verifyOTP({required String verificationId, required String smsCode}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw Exception('The code you entered is incorrect.');
      }
      throw Exception(e.message ?? 'Failed to verify code.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 5b. Phone Auth: Auto-SignIn (Android)
  Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  // 6. Global Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}