import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

abstract class GameRepository {
  Future<String> createGame(String playerId, List<String> playersSelected, int timeForMove);
  Future<String> searchGame(String playerId, int playersNumber, int timeForMove);
  Future<void> joinGame(bool accepted, String gameId);
  Stream<int> missingPlayers(String gameId);
  Stream<List<Tile>> playerTiles(String gameId, String playerId);
  Stream<List<Player>> playersQueue(String gameId);
  Stream<Map<String, dynamic>> gameStatus(String gameId);
  Stream<List<TilesSet>> tilesSets(String gameId);
  Future<void> putTiles(String gameId, List<TilesSet> tiles);
  Future<void> leaveGame(String gameId, String playerId);
}
