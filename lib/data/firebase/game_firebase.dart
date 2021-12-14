import 'package:firebase_auth/firebase_auth.dart';
import 'package:rummikub/data/auth_repository.dart';
import 'package:rummikub/data/firebase/authentication_provider.dart';
import 'package:rummikub/data/firebase/firestore_provider.dart';
import 'package:rummikub/data/firebase/functions_provider.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

import '../game_repository.dart';

class GameFirebase implements GameRepository  {
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  final FunctionsProvider _functionsProvider = FunctionsProvider();

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
  Stream<int> getMissingPlayersNumberToStartGame(String gameId) {
    return _firestoreProvider.getMissingPlayersNumberToStartGame(gameId);
  }

  @override
  Stream<List<Tile>> getPlayerTiles(String gameId, String playerId) {
    return _firestoreProvider.getPlayerTiles(gameId, playerId);
  }

  @override
  Stream<List<Player>> getPlayersQueue(String gameId) {
    return _firestoreProvider.getPlayersQueue(gameId);
  }

  @override
  Stream<Map<String, dynamic>> getGameStatus(String gameId) {
    return _firestoreProvider.getGameStatus(gameId);
  }

  @override
  Future<void> putTiles(String gameId, List<TilesSet> tiles) async {
    await _functionsProvider.putTiles(gameId, tiles);
  }

  @override
  Stream<List<TilesSet>> getTilesSets(String gameId) {
    return _firestoreProvider.getTilesSets(gameId);
  }

  @override
  Future<void> leaveGame(String gameId, String playerId, bool isFinished) async {
    if (!isFinished) {
      await _functionsProvider.leftGame(gameId);
    }
    await _firestoreProvider.changeUserActiveStatus(playerId, true);
  }

}