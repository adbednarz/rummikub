import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rummikub/data/bot/basic_bot.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

import 'bot_engine.dart';
import 'game.dart';

class LocalGame implements Repository {
  final Game game = Game();
  final BotEngine botEngine = BasicBot();

  final StreamController<Map<String, dynamic>> gameStatusController = StreamController<Map<String, dynamic>>();
  final StreamController<List<Tile>> playerTilesController = StreamController<List<Tile>>();
  final StreamController<List<TilesSet>> tilesSetsController = StreamController<List<TilesSet>>();

  @override
  Stream<Map<String, dynamic>> getGameStatus(String gameId) {
    gameStatusController.add({'currentTurn': '0'});
    return gameStatusController.stream;
  }

  @override
  Stream<List<Tile>> getPlayerTiles(String gameId, String playerId) {
    playerTilesController.add(game.playerRack);
    return playerTilesController.stream;
  }

  @override
  Stream<List<Player>> getPlayersQueue(String gameId) {
    var players = <Player>[Player('You', '0'), Player('Bot', '1')];
    var controller = StreamController<List<Player>>();
    controller.add(players);
    return controller.stream;
  }

  @override
  Stream<List<TilesSet>> getTilesSets(String gameId) {
    return tilesSetsController.stream;
  }

  @override
  Future<void> putTiles(String gameId, List<TilesSet> tiles) async {
    var playerTiles = tiles.expand((set) => set.tiles.map((tile) => Tile(tile.color, tile.number, false)).toList()).toList();
    var previousTiles = game.sets.expand((set) => set.tiles).toList();
    var tilesToDeleteFromPlayerRack = [];
    for (var tile in playerTiles) {
      if (previousTiles.contains(tile)) {
        previousTiles.remove(tile);
      } else {
        tilesToDeleteFromPlayerRack.add(tile);
      }
    }
    if (tilesToDeleteFromPlayerRack.isEmpty) {
      var tile = game.getTileFromPool();
      if (tile != null) {
        playerTilesController.add([Tile(tile.color, tile.number, true)]);
        game.playerRack.add(tile);
      } else {
        var winner = game.pointTheWinner();
        gameStatusController.add({'winner': winner});
        return;
      }
    } else {
      game.sets = List.from(tiles);
      for (var tile in tilesToDeleteFromPlayerRack) {
        game.playerRack.remove(tile);
      }
    }
    _botMove();
  }

  void _botMove() {
    gameStatusController.add({'currentTurn': '1'});
    var result = botEngine.move(List.from(game.sets), List.from(game.botRack));
    if (result[0].isNotEmpty) {
      tilesSetsController.add(List.from(result[0]));
      game.botRack = result[1];
    } else {
      var tile = game.getTileFromPool();
      if (tile != null) {
        game.botRack.add(tile);
      } else {
        var winner = game.pointTheWinner();
        gameStatusController.add({'winner': winner});
        return;
      }
    }
    gameStatusController.add({'currentTurn': '0'});
  }

  @override
  Future<void> leaveGame(String gameId, String playerId, bool isFinished) async {}

  @override
  Stream<int> getMissingPlayersNumberToStartGame(String gameId) {
    throw UnimplementedError();
  }

  @override
  Future<User> logIn(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> logOut(String playerId) {
    throw UnimplementedError();
  }

  @override
  Future<String> searchGame(String playerId, int playersNumber, int timeForMove) {
    throw UnimplementedError();
  }

  @override
  Future<User> signUp(String email, String username, String password) {
    throw UnimplementedError();
  }

}