import 'package:rummikub/shared/models/player.dart';

abstract class AuthRepository {
  Future<Player> signUp(String email, String username, String password);
  Future<Player> logIn(String email, String password);
  Future<void> logOut(String playerId);
  Stream<Map<String, String>> invitationToGame(String playerId);
  Stream<List<String>> activePlayers(String playerId);
}