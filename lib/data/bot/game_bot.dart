import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rummikub/data/bot/basic_bot.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

import '../game_repository.dart';
import 'advanced_bot.dart';
import 'bot_engine.dart';
import 'game.dart';

class GameBot implements GameRepository {
  final Game game = Game();
  final String botType;
  final List<BotEngine> bots = [];

  final StreamController<
      Map<String, dynamic>> gameStatusController = StreamController<
      Map<String, dynamic>>();
  final StreamController<List<Tile>> playerTilesController = StreamController<
      List<Tile>>();
  final StreamController<List<TilesSet>> tilesSetsController = StreamController<
      List<TilesSet>>();

  GameBot(this.botType);

  @override
  Future<String> searchGame(String playerId, int playersNumber, int timeForMove) async {
    for (var i = 0; i < playersNumber - 1; i++) {
      bots.add(botType == 'basicBot' ? BasicBot() : AdvancedBot());
    }
    game.initialize(playersNumber - 1, timeForMove);
    return '0';
  }

  @override
  Stream<int> getMissingPlayersNumberToStartGame(String gameId) {
    final missingPlayersController = StreamController<int>();
    missingPlayersController.add(0);
    return missingPlayersController.stream;
  }

  @override
  Stream<Map<String, dynamic>> getGameStatus(String gameId) {
    gameStatusController.add(
        {'currentTurn': '0', 'timeForMove': game.timeForMove});
    return gameStatusController.stream;
  }

  @override
  Stream<List<Tile>> getPlayerTiles(String gameId, String playerId) {
    playerTilesController.add(game.playerRack);
    return playerTilesController.stream;
  }

  @override
  Stream<List<Player>> getPlayersQueue(String gameId) {
    var players = <Player>[Player('You', '0')];
    for (var i = 1; i <= game.botsRacks.length; i++) {
      players.add(Player('Bot ' + i.toString(), i.toString()));
    }
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
    var playerTiles = tiles.expand((set) =>
        set.tiles.map((tile) => Tile(tile.color, tile.number, false)).toList())
        .toList();
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
    await _botMove();
  }

  Future<void> _botMove() async {
    for (var i = 0; i < game.botsRacks.length; i++) {
      gameStatusController.add({'currentTurn': (i + 1).toString()});
      final stopwatch = Stopwatch()..start();
      var result = bots[i].move(List.from(game.sets), List.from(game.botsRacks[i]));
      var time = stopwatch.elapsed.inSeconds;
      if (time < 5) {
        await Future.delayed(
            Duration(seconds: 5 + Random().nextInt(game.timeForMove - 5)));
      }
      if (result[0].isNotEmpty) {
        tilesSetsController.add(List.from(result[0]));
        game.botsRacks[i] = result[1];
      } else {
        var tile = game.getTileFromPool();
        if (tile != null) {
          game.botsRacks[i].add(tile);
        } else {
          var winner = game.pointTheWinner();
          gameStatusController.add({'winner': winner});
          continue;
        }
      }
    }
    gameStatusController.add({'currentTurn': '0'});
  }

  @override
  Future<void> leaveGame(String gameId, String playerId, bool isFinished) async {}

  @override
  Future<void> joinGame(bool accepted, String gameId) async {}

  @override
  Future<String> createGame(String playerId, List<String> plyersSelected, int timeForMove) {
    throw UnimplementedError();
  }

}