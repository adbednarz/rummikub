import 'package:flutter_test/flutter_test.dart';
import 'package:rummikub/data/bot/advanced_bot.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

void main() {
  test('Bot should return correct score', () {
    final bot = AdvancedBot();
    var tiles2 = [Tile('orange', 9, true),
      Tile('orange', 10, true),
      Tile('orange', 3, true),
      Tile('orange', 9, true),
      Tile('blue', 9, true),
      Tile('black', 3, true),
      Tile('red', 8, true),
      Tile('black', 11, true),
      Tile('orange', 7, true),
      Tile('orange', 2, true),
      Tile('red', 13, true),
      Tile('blue', 12, true),
      Tile('black', 8, true),
      Tile('black', 13, true),
    ];
    bot.move([], tiles2);
  });
}