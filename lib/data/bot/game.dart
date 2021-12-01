import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class Game {
  final List<Tile> pool = [];
  late final List<Tile> playerRack;
  List<Tile> botRack = [];
  List<TilesSet> sets = [];

  Game() {
    for (var i = 0; i < 2; i++) {
      for (var color in ['black', 'red', 'orange', 'blue']) {
        for (var j = 1; j < 14; j++) {
          pool.add(Tile(color, j, false));
        }
      }
    }
    for (var color in ['black', 'red']) {
      pool.add(Tile(color, 0, false));
    }
    pool.shuffle();
    playerRack = pool.take(14).map((tile) => Tile(tile.color, tile.number, true)).toList();
    pool.removeRange(0, 14);
    botRack = pool.take(14).toList();
    pool.removeRange(0, 14);
  }

  Tile? getTileFromPool() {
    if (pool.isNotEmpty) {
      var tile = pool.first;
      pool.removeAt(0);
      return tile;
    }
    return null;
  }

  List<String> pointTheWinner() {
    return [];
  }

  static bool isRun(List<Tile> set) {
    var i = 0;
    var currentNumber;
    if (set[0].number == 0 && set[1].number == 0) {
      i = 2;
    } else if (set[0].number == 0) {
      i = 1;
    }
    currentNumber = set[i].number;
    if ((i == 2 && currentNumber < 3) || (i == 1 && currentNumber < 2)) {
      return false;
    }
    i++;
    for (i; i < set.length; i++) {
      if (set[i].number != currentNumber + 1 && set[i].number != 0) {
        return false;
      }
      currentNumber += 1;
    }
    return true;
  }
}