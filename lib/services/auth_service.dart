import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '825104550139-nii1vpkbq7mj6qrihh8dt4tv4m5a4q1a.apps.googleusercontent.com',
  );

  // ─── Current user stream ───────────────────────────────────────────────────
  Stream<User?> get userStream => _auth.authStateChanges();

  // ─── Current user ─────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ─── REGISTER with Email & Password ───────────────────────────────────────
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    // Send email verification automatically after registration
    await credential.user?.sendEmailVerification();
    return credential;
  }

  // ─── LOGIN with Email & Password ──────────────────────────────────────────
  Future<UserCredential?> loginWithEmail(
    String email,
    String password,
  ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return credential;
  }

  // ─── GOOGLE SIGN-IN ───────────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In interactive flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled the sign-in
      if (googleUser == null) return null;

      // Obtain auth details (access token, id token)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // ─── FORGOT PASSWORD ──────────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ─── SIGN OUT ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore if google sign-in was not used
    }
    await _auth.signOut();
  }

  // ─── Reload current user (to check email verification) ───────────────────
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // ─── Is email verified ────────────────────────────────────────────────────
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
}
