import 'package:flutter_test/flutter_test.dart';
import 'package:rummikub/data/bot/advanced_bot.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

void main() {
  test('Bot should return correct score', () {
    final bot = AdvancedBot();
    var tiles2 = [Tile('orange', 9, true),
      Tile('orange', 10, true),
      Tile('orange', 8, true)
    ];
    bot.move([], tiles2);
  });
}