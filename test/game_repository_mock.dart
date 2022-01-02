
import 'dart:async';

import 'package:rummikub/data/game_repository.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class GameRepositoryMock implements GameRepository {
  @override
  Future<String> createGame(Player player, List<String> playersSelected, int timeForMove) async {
    return '0';
  }

  @override
  Stream<Map<String, dynamic>> gameStatus(String gameId) {
    return StreamController<Map<String, dynamic>>().stream;
  }

  @override
  Future<void> joinGame(Player player, bool accepted, String gameId) async {}

  @override
  Future<void> leaveGame(String gameId, String playerId) async {}

  @override
  Stream<int> missingPlayers(String gameId) {
    return StreamController<int>().stream;
  }

  @override
  Stream<List<Tile>> playerTiles(String gameId, String playerId) {
    return StreamController<List<Tile>>().stream;
  }

  @override
  Stream<List<Player>> playersQueue(String gameId) {
    return StreamController<List<Player>>().stream;
  }

  @override
  Future<void> putTiles(String gameId, List<TilesSet> tiles) async {}

  @override
  Future<String> searchGame(Player player, int playersNumber, int timeForMove) async {
    return '0';
  }

  @override
  Stream<List<TilesSet>> tilesSets(String gameId) {
    return StreamController<List<TilesSet>>().stream;
  }

}