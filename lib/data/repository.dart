import 'package:firebase_auth/firebase_auth.dart';

abstract class Repository {

  Future<User> signUp({required String email, required String username, required String password});
  Future<User> logIn({required String email, required String password});
  Future<void> logOut({required String userID});
  Future<String> searchGame({required int playersNumber});
}