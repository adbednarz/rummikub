import 'package:rummikub/shared/models/tile.dart';

import 'package:rummikub/shared/models/tiles_set.dart';

import 'bot_engine.dart';
import 'game.dart';

class BasicBot extends BotEngine {
  bool initialMeld = false;

  @override
  List<TilesSet> move(List<TilesSet> sets, List<Tile> botRack) {
    var result = _getSetsFromRack(List.from(botRack));
    if (isUnder30Points(result[0])) {
      return [];
    }
    for (var set in result[0]) {
      sets.add(TilesSet(-1, set));
    }
    botRack.removeWhere((tile) => !result[1].contains(tile));

    if (initialMeld) {
      for (var set in sets) {
        var botRackCopy = List.from(botRack);
        if (Game.isRun(set.tiles)) {
          for (var i = 0; i < botRackCopy.length; i++) {
            if (botRackCopy[i].number == set.tiles[0].number - 1 ||
                set.tiles[0].number == 0) {
              set.tiles.insert(0, botRackCopy[i]);
              set.position -= 1;
              botRack.remove(i);
            } else if (botRackCopy[i].number == set.tiles[set.tiles.length - 1].number + 1 ||
                set.tiles[set.tiles.length - 1].number == 0) {
              set.tiles.add(botRackCopy[i]);
              botRack.remove(i);
            }
          }
        } else {
          for (var i = 0; i < botRackCopy.length; i++) {
            if ((botRackCopy[i].color == set.tiles[0].color ||
                set.tiles[0].number == 0) && set.tiles.length < 4) {
              set.tiles.add(botRackCopy[i]);
              botRack.remove(i);
            }
          }
        }
      }
    }

    return checkSetsPositions(sets);
  }

  List<dynamic> _getSetsFromRack(List<Tile> rack) {
    var sets = <List<Tile>>[];
    rack.sort((x, y) => x.number.compareTo(y.number));
    var index = 0;
    while (index < rack.length - 2) {
      var result = _findRun(rack, index);
      if (result[0].isNotEmpty) {
        sets.add(result[0]);
      }
      rack = result[1];
      index = result[2];
    }
    while (index < rack.length - 2) {
      var result = _findGroup(rack, index);
      if (result[0].isNotEmpty) {
        sets.add(result[0]);
      }
      rack = result[1];
      index = result[2];
    }
    return [sets, rack];
  }

  List<dynamic> _findRun(List<Tile> rack, int index) {
    var set = [rack[index]];
    for (var tile in rack.skip(index + 1)) {
      if ((tile.number == set.last.number + 1 &&
          tile.color == set.last.color) || tile.number == 0) {
        set.add(tile);
      }
    }

    if (checkRun(set)) {
      rack.removeWhere((element) => set.contains(element));
      return [set, rack, 0];
    }
    return [[], rack, index + 1];
  }

  List<dynamic> _findGroup(List<Tile> rack, int index) {
    var set = [rack[index]];
    for (var tile in rack.skip(index + 1)) {
      if ((tile.number == set.last.number &&
          tile.color != set.last.color) || tile.number == 0) {
        set.add(tile);
      }
    }

    if (checkGroup(set)) {
      rack.removeWhere((element) => set.contains(element));
      return [set, rack, 0];
    } else {
      return [[], rack, index + 1];
    }
  }

}



