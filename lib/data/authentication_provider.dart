import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rummikub/shared/custom_exception.dart';

class AuthenticationProvider {
  final FirebaseAuth _firebaseAuth =  FirebaseAuth.instance;

  AuthenticationProvider() {
    String localhost = kIsWeb ? 'localhost' : '156.17.235.49';
    _firebaseAuth.useAuthEmulator(localhost, 9090);
  }

  Future<User> signUp({
    required String email,
    required String username,
    required String password})
  async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;
      user.updateDisplayName(username);
      return user;
    } on FirebaseException catch (e) {
      throw new CustomException(e.message ?? "Error occurred");
    } catch(error) {
      print(error);
      throw new CustomException("Error occurred");
    }
  }

  Future<User> logIn({
    required String email,
    required String password})
  async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user!;
    }
    on FirebaseException catch (e) {
    throw new CustomException(e.message ?? "Error occurred");
    } catch(error) {
      print(error);
      throw new CustomException("Error occurred");
    }
  }

  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch(error) {
      print(error);
      throw new CustomException("Error occurred");
    }
  }
}