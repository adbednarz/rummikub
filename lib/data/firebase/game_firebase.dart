import 'package:rummikub/data/firebase/firestore_provider.dart';
import 'package:rummikub/data/firebase/functions_provider.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

import '../game_repository.dart';

class GameFirebase implements GameRepository  {
  final FirestoreProvider _firestoreProvider;
  final FunctionsProvider _functionsProvider = FunctionsProvider();

  GameFirebase(this._firestoreProvider);

  @override
  Future<String> createGame(String playerId, List<String> playersSelected, int timeForMove) async {
    await _firestoreProvider.changeUserActiveStatus(playerId, false);
    return _functionsProvider.createGame(playersSelected, timeForMove);
  }

  @override
  Future<String> searchGame(String playerId, int playersNumber, int timeForMove) async {
    await _firestoreProvider.changeUserActiveStatus(playerId, false);
    return _functionsProvider.searchGame(playersNumber, timeForMove);
  }

  @override
  Future<void> joinGame(bool accepted, String gameId) async {
    await _functionsProvider.joinGame(accepted, gameId);
  }

  @override
  Stream<int> missingPlayers(String gameId) {
    return _firestoreProvider.getMissingPlayersNumberToStartGame(gameId);
  }

  @override
  Stream<List<Tile>> playerTiles(String gameId, String playerId) {
    return _firestoreProvider.getPlayerTiles(gameId, playerId);
  }

  @override
  Stream<List<Player>> playersQueue(String gameId) {
    return _firestoreProvider.getPlayersQueue(gameId);
  }

  @override
  Stream<Map<String, dynamic>> gameStatus(String gameId) {
    return _firestoreProvider.getGameStatus(gameId);
  }

  @override
  Future<void> putTiles(String gameId, List<TilesSet> tiles) async {
    await _functionsProvider.putTiles(gameId, tiles);
  }

  @override
  Stream<List<TilesSet>> tilesSets(String gameId) {
    return _firestoreProvider.getTilesSets(gameId);
  }

  @override
  Future<void> leaveGame(String gameId, String playerId) async {
    await _functionsProvider.leftGame(gameId);
  }

}