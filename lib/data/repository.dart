import 'package:firebase_auth/firebase_auth.dart';

abstract class Repository {

  Future<User> signUp({required String email, required String username, required String password});
  Future<User> logIn({required String email, required String password});
  Future<void> logOut({required String playerId});
  Future<String> searchGame(String playerId, int playersNumber);
  Stream<int> getMissingPlayersNumberToStartGame(String gameId);
  Stream<List<Map<String, int>>> getPlayerTiles(String gameId, String playerId);
}
