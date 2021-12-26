import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class Game {
  final List<Tile> pool = [];
  late final List<Tile> playerRack;
  List<List<Tile>> botsRacks = [];
  List<TilesSet> sets = [];

  Game(String botType) {
    for (var i = 0; i < 2; i++) {
      for (var color in ['black', 'red', 'orange', 'blue']) {
        for (var j = 1; j < 14; j++) {
          pool.add(Tile(color, j, false));
        }
      }
    }
    if (botType == 'basicBot') {
      for (var color in ['black', 'red']) {
        pool.add(Tile(color, 0, false));
      }
    }
    pool.shuffle();
    playerRack = pool.take(14).map((tile) => Tile(tile.color, tile.number, true)).toList();
    pool.removeRange(0, 14);
  }

  void initialize(int number) {
    for (var i = 0; i < number; i++) {
      var botRack = pool.take(14).map((tile) => Tile(tile.color, tile.number, true)).toList();
      pool.removeRange(0, 14);
      botsRacks.add(botRack);
    }
  }

  Tile? getTileFromPool() {
    if (pool.isNotEmpty) {
      var tile = pool.last;
      pool.removeLast();
      return tile;
    }
    return null;
  }

  List<String> pointTheWinner() {
    var sums = [];
    var min = 0;

    var playerSum = 0;
    for (var tile in playerRack) {
      playerSum += tile.number;
    }
    sums.add(playerSum);
    min = playerSum;

    for (var botRack in botsRacks) {
      var botSum = 0;
      for (var tile in botRack) {
        botSum += tile.number;
      }
      sums.add(botSum);
      if (min > botSum) {
        min = botSum;
      }
    }

    var winners = <String>[];
    for (var i = 0; i <= botsRacks.length; i++) {
      if (sums[i] == min) {
        winners.add(i.toString());
      }
    }
    return winners;
  }

}