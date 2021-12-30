import 'package:flutter_test/flutter_test.dart';
import 'package:rummikub/data/bot/advanced_bot.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

void main() {
  test('Bot should return correct score', () {
    final bot = AdvancedBot();
    var tiles2 = [Tile('orange', 1, false),
      Tile('orange', 2, false),
      Tile('orange', 3, false)
    ];
    bot.move([], tiles2);
  });
}