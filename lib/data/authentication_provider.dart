import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationProvider {
  final FirebaseAuth _firebaseAuth =  FirebaseAuth.instance;

  Future<void> signUp({
    required String email,
    required String username,
    required String password})
  async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (_) {
      throw Exception();
    }
  }

  Future<void> logIn({
    required String email,
    required String password})
  async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw LogInFailure.fromCode(e.code);
    } catch (_) {
      throw Exception();
    }
  }

  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      throw Exception();
    }
  }
}

class LogInFailure implements Exception {

  const LogInFailure([
    this.message = 'An exception occurred.',
  ]);

  factory LogInFailure.fromCode(String code) {
    if (code == 'user-not-found' || code == 'invalid-email' || code == 'wrong-password') {
      return const LogInFailure(
        'Email or password are incorrect.',
      );
    } else {
      return const LogInFailure();
    }
  }

  final String message;
}