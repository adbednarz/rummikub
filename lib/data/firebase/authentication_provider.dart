import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rummikub/shared/custom_exception.dart';

class AuthenticationProvider {
  final FirebaseAuth _firebaseAuth =  FirebaseAuth.instance;

  AuthenticationProvider() {
    var localhost = kIsWeb ? 'localhost' : '192.168.8.104';
    _firebaseAuth.useAuthEmulator(localhost, 9090);
  }

  Future<User> signUp(String email, String username, String password) async {
    try {
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      var user = result.user!;
      await user.updateDisplayName(username);
      return user;
    } on FirebaseException catch (e) {
      throw CustomException(e.message ?? 'Error occurred');
    } catch(error) {
      print(error);
      throw CustomException('Error occurred');
    }
  }

  Future<User> logIn(String email, String password) async {
    try {
      var result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user!;
    }
    on FirebaseException catch (e) {
      throw CustomException(e.message ?? 'Error occurred');
    } catch(error) {
      print(error);
      throw CustomException('Error occurred');
    }
  }

  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseException catch (e) {
      throw CustomException(e.message ?? 'Error occurred');
    } catch(error) {
      print(error);
      throw CustomException('Error occurred');
    }
  }
}