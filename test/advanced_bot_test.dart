import 'package:flutter_test/flutter_test.dart';
import 'package:rummikub/data/bot/advanced_bot.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

void main() {
  test('Bot should return correct score', () {
    final bot = AdvancedBot();
    var tiles2 = [
      Tile('black', 5, false),
      Tile('blue', 5, false),
      Tile('orange', 5, false),
      Tile('orange', 6, true),
      Tile('orange', 7, true),
      Tile('black', 6, true),
      Tile('black', 7, true),
      Tile('black', 8, true)
    ];
    bot.move([], tiles2);
  });
}