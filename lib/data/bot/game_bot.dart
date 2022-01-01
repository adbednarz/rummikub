import 'dart:async';
import 'package:rummikub/data/bot/basic_bot.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

import '../game_repository.dart';
import 'advanced_bot.dart';
import 'bot_engine.dart';
import 'game.dart';

class GameBot implements GameRepository {
  final List<BotEngine> bots = [];
  final String botType;
  late final Game game = Game(botType);
  late final int timeForMove;

  final gameStatusController = StreamController<Map<String, dynamic>>();
  final playerTilesController = StreamController<List<Tile>>();
  final tilesSetsController = StreamController<List<TilesSet>>();

  GameBot(this.botType);

  @override
  Future<String> searchGame(Player player, int playersNumber, timeForMove) async {
    this.timeForMove = timeForMove;
    for (var i = 0; i < playersNumber - 1; i++) {
      bots.add(botType == 'basicBot' ? BasicBot() : AdvancedBot());
    }
    game.initialize(playersNumber - 1);
    return '0';
  }

  @override
  Stream<int> missingPlayers(String gameId) {
    final missingPlayersController = StreamController<int>();
    missingPlayersController.add(0);
    return missingPlayersController.stream;
  }

  @override
  Stream<Map<String, dynamic>> gameStatus(String gameId) {
    gameStatusController.add(
        {'currentTurn': '0', 'timeForMove': timeForMove});
    return gameStatusController.stream;
  }

  @override
  Stream<List<Tile>> playerTiles(String gameId, String playerId) {
    playerTilesController.add(game.playerRack);
    return playerTilesController.stream;
  }

  @override
  Stream<List<Player>> playersQueue(String gameId) {
    var players = <Player>[Player('You', '0')];
    for (var i = 1; i <= game.botsRacks.length; i++) {
      players.add(Player('Bot ' + i.toString(), i.toString()));
    }
    var controller = StreamController<List<Player>>();
    controller.add(players);
    return controller.stream;
  }

  @override
  Stream<List<TilesSet>> tilesSets(String gameId) {
    return tilesSetsController.stream;
  }

  @override
  Future<void> putTiles(String gameId, List<TilesSet> tiles) async {
    var playerTiles = tiles.expand((set) => set.tiles).toList();
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
        playerTilesController.add([tile]);
        game.playerRack.add(tile);
      } else {
        var winner = game.pointTheWinner();
        gameStatusController.add({'winner': winner});
        return;
      }
    } else {
      //  aktualizacja stanu gry
      var sets = tiles.map((set) => set.copy()).toList();
      game.sets.clear();
      // kolejno dodawanie zbiorów do planszy, każda kość planszy -> isMine = false
      for (var set in sets) {
        if (set.tiles.any((element) => element.isMine == true)) {
          set.tiles = set.tiles.map((e) => Tile(e.color, e.number, false)).toList();
        }
        game.sets.add(set);
      }
      for (var tile in tilesToDeleteFromPlayerRack) {
        game.playerRack.remove(tile);
      }
      if (game.playerRack.isEmpty) {
        gameStatusController.add({'winner': ['0']});
        return;
      }
    }
    await _botMove();
  }

  @override
  Future<void> leaveGame(String gameId, String playerId) async {}

  Future<void> _botMove() async {
    for (var i = 0; i < game.botsRacks.length; i++) {
      gameStatusController.add({'currentTurn': (i + 1).toString()});
      final stopwatch = Stopwatch()..start();
      var result = bots[i].move(game.sets, game.botsRacks[i]);
      var time = stopwatch.elapsed.inSeconds;
      // if (time < 5) {
      //   await Future.delayed(
      //       Duration(seconds: 5 + Random().nextInt(timeForMove - 5)));
      // }
      if (result[0].isNotEmpty) {
        List<TilesSet> tilesSets = result[0].cast<TilesSet>();
        tilesSetsController.add(tilesSets.map((set) => set.copy()).toList());
        game.sets = result[0];
        game.botsRacks[i] = result[1];
        if (game.botsRacks[i].isEmpty) {
          gameStatusController.add({'winner': [(i+1).toString()]});
          return;
        }
      } else {
        var tile = game.getTileFromPool();
        if (tile != null) {
          game.botsRacks[i].add(tile);
        } else {
          var winner = game.pointTheWinner();
          gameStatusController.add({'winner': winner});
          break;
        }
      }
    }
    gameStatusController.add({'currentTurn': '0'});
  }

  // w przypadku gry z botami:
  // nie dołączamy do istniejących gier
  @override
  Future<void> joinGame(Player player, bool accepted, String gameId) async {
    throw UnimplementedError();
  }

  // nie zapraszamy innych graczy do gry
  @override
  Future<String> createGame(Player player, List<String> playersSelected, int timeForMove) {
    throw UnimplementedError();
  }

}