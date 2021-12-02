import 'package:rummikub/shared/models/tile.dart';

import 'package:rummikub/shared/models/tiles_set.dart';

import 'bot_engine.dart';
import 'game.dart';

class BasicBot extends BotEngine {
  bool initialMeld = false;

  @override
  List<dynamic> move(List<TilesSet> boardSets, List<Tile> botRack) {
    var sets = List<TilesSet>.from(boardSets);
    var resultNewSets = _getSetsFromRack(botRack);
    if (resultNewSets[0].isNotEmpty) {
      if (!initialMeld) {
        if (isUnder30Points(resultNewSets[0])) {
          return [[], []];
        } else {
          initialMeld = true;
        }
      } else {
        var resultModifiedSets = _modifySets(sets, resultNewSets[1]);
        sets = resultModifiedSets[0];
        botRack = resultModifiedSets[1];
      }
      for (var set in resultNewSets[0]) {
        sets.add(TilesSet(-1, set));
      }
    }
    return [checkSetsPositions(sets, boardSets), botRack];
  }

  List<dynamic> _getSetsFromRack(List<Tile> rack) {
    var sets = <List<Tile>>[];
    rack.sort((x, y) => x.number.compareTo(y.number));
    var index = 0;
    while (index < rack.length - 2) {
      var result = _findRun(rack, index);
      if (result[0].isNotEmpty) {
        sets.add(result[0]);
        rack = result[1];
      }
      index = result[2];
    }
    index = 0;
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

  List<dynamic> _modifySets(List<TilesSet> sets, List<Tile> botRack) {
    for (var set in sets) {
      var botRackCopy = List.from(botRack);
      if (Game.isRun(set.tiles)) {
        for (var i = 0; i < botRackCopy.length; i++) {
          if (botRackCopy[i].color == set.tiles[0].color) {
            if (botRackCopy[i].number == set.tiles[0].number - 1) {
              set.tiles.insert(0, botRackCopy[i]);
              set.position -= 1;
              botRack.remove(i);
            } else if (botRackCopy[i].number == set.tiles[set.tiles.length - 1].number + 1) {
              set.tiles.add(botRackCopy[i]);
              botRack.remove(i);
            }
          }
        }
      } else {
        for (var i = 0; i < botRackCopy.length; i++) {
          if (botRackCopy[i].number == set.tiles[0].number && set.tiles.length < 4) {
            if (checkGroup(set.tiles + [botRackCopy[i]])) {
              set.tiles.add(botRackCopy[i]);
              botRack.remove(i);
            }
          }
        }
      }
    }
    return [sets, botRack];
  }

  List<dynamic> _findRun(List<Tile> rack, int index) {
    var set = [rack[index]];
    for (var tile in rack.skip(index + 1)) {
      if ((tile.number == set.last.number + 1 && tile.color == set.last.color) ||
          tile.number == 0 || set.last.number == 0) {
        set.add(tile);
      }
    }
    if (checkRun(set)) {
      for (var tile in set) {
        rack.remove(tile);
      }
      return [set, rack, index];
    }
    return [[], rack, index + 1];
  }

  List<dynamic> _findGroup(List<Tile> rack, int index) {
    var set = [rack[index]];
    for (var tile in rack.skip(index + 1)) {
      if ((tile.number == set.last.number && !set.contains(tile)) ||
          tile.number == 0 || set.last.number == 0) {
        set.add(tile);
      }
    }
    if (checkGroup(set)) {
      for (var tile in set) {
        rack.remove(tile);
      }
      return [set, rack, index];
    } else {
      return [[], rack, index + 1];
    }
  }

}



