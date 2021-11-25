import 'package:firebase_auth/firebase_auth.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

abstract class Repository {
  Future<User> signUp({required String email, required String username, required String password});
  Future<User> logIn({required String email, required String password});
  Future<void> logOut({required String playerId});
  Future<String> searchGame(String playerId, int playersNumber);
  Stream<int> getMissingPlayersNumberToStartGame(String gameId);
  Stream<List<Tile>> getPlayerTiles(String gameId, String playerId);
  Stream<List<Player>> getPlayersQueue(String gameId);
  Stream<String> getCurrentTurnPlayerId(String gameId);
  Stream<List<TilesSet>> getTilesSets(String gameId);
  Future<void> putTiles(String gameId, List<TilesSet> tiles);
}
