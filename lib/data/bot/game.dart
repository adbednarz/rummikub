import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class Game {
  final List<Tile> pool = [];
  late final List<Tile> playerRack;
  late final List<Tile> botRack;
  List<TilesSet> sets = [];

  Game() {
    for (var i = 0; i < 2; i++) {
      for (var color in ['black', 'red', 'orange', 'blue']) {
        for (var j = 1; j < 14; j++) {
          pool.add(Tile(color, j, true));
        }
      }
    }
    for (var color in ['black', 'red']) {
      pool.add(Tile(color, 0, true));
    }
    pool.shuffle();
    playerRack = pool.take(14).toList();
    pool.removeRange(0, 13);
    botRack = pool.take(14).toList();
    pool.removeRange(0, 13);
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

}