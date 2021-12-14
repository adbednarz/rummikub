import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User> signUp(String email, String username, String password);
  Future<User> logIn(String email, String password);
  Future<void> logOut(String playerId);
  Stream<Map<String, String>> getUserDocumentChanges(String playerId);
  Stream<List<String>> getActivePlayers(String playerId);
}