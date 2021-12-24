import 'package:flutter_test/flutter_test.dart';
import 'package:rummikub/data/bot/advanced_bot.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

void main() {
  test('Bot should return correct score', () {
    final bot = AdvancedBot();
    // var tiles = [Tile('black', 4, false), Tile('black', 5, false),
    //   Tile('black', 6, false), Tile('black', 7, false), Tile('blue', 6, false),
    //   Tile('orange', 6, false), Tile('black', 6, false), Tile('red', 6, false),
    //   Tile('black', 6, false), Tile('blue', 6, false), Tile('red', 6, false),
    //   Tile('blue', 1, false), Tile('blue', 2, false), Tile('blue', 3, false),
    //   Tile('blue', 7, false), Tile('orange', 7, false)];
    var tiles2 = [Tile('orange', 11, true), Tile('red', 12, true), Tile('red', 10, true)];
   // var tileSet = TilesSet(0, tiles);
    bot.move([], tiles2);
  });
}