import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

import 'bot_engine.dart';

class BasicBot extends BotEngine {

  @override
  List<dynamic> move(List<TilesSet> boardSets, List<Tile> botRack) {
    var sets = boardSets.map((set) => set.copy()).toList();
    var setsFromRack = _getSetsFromRack(botRack);
    // jeżeli bot wyłożył swoje pierwsze rozdanie, może modyfikować inne zbiory
    if (initialMeld) {
      _modifySets(sets, botRack);
    }
    if (setsFromRack.isNotEmpty) {
      if (!initialMeld) {
        if (_isUnder30Points(setsFromRack)) {
          return [[], []];
        } else {
          initialMeld = true;
        }
      }
      // mapowanie kości gracza na kości znajdujące się na planszy (zmiana parametru isMine)
      for (var set in setsFromRack) {
        var tilesToAdd = set.map((tile) => Tile(tile.color, tile.number, false)).toList();
        sets.add(TilesSet(-1, tilesToAdd));
      }
    }
    return [checkSetsPositions(sets, boardSets), botRack];
  }

  List<List<Tile>> _getSetsFromRack(List<Tile> rack) {
    var sets = <List<Tile>>[];
    rack.sort((x, y) => x.number.compareTo(y.number));
    var index = 0;
    while (index < rack.length - 2) {
      var result = _findRun(rack, index);
      if (result[0].isNotEmpty) {
        sets.add(result[0]);
      }
      index = result[1];
    }
    index = 0;
    while (index < rack.length - 2) {
      var result = _findGroup(rack, index);
      if (result[0].isNotEmpty) {
        sets.add(result[0]);
      }
      index = result[1];
    }
    return sets;
  }

  void _modifySets(List<TilesSet> sets, List<Tile> botRack) {
    for (var set in sets) {
      var tileToDelete = <int>[];
      if (isRun(set.tiles)) {
        for (var i = 0; i < botRack.length; i++) {
          var setSize = set.tiles.length;
          if (botRack[i].number == 0) {
            if (set.tiles[0].number > 1) {
              set.tiles.insert(0, Tile(botRack[i].color, botRack[i].number, false));
            } else if (set.tiles.last.number != 13 && set.tiles.last.number != 0) {
              set.tiles.add(Tile(botRack[i].color, botRack[i].number, false));
            }
          } else if (botRack[i].color == set.tiles[0].color) {
            if (botRack[i].number == set.tiles[0].number - 1) {
              set.tiles.insert(0, Tile(botRack[i].color, botRack[i].number, false));
            } else if (botRack[i].number == set.tiles[set.tiles.length - 1].number + 1) {
              set.tiles.add(Tile(botRack[i].color, botRack[i].number, false));
            }
          }
          if (setSize != set.tiles.length) {
            tileToDelete.add(i);
          }
        }
      } else {
        for (var i = 0; i < botRack.length; i++) {
          if (set.tiles.length < 4) {
            if (botRack[i].number == set.tiles[0].number || botRack[i].number == 0) {
              if (!set.tiles.contains(botRack[i])) {
                set.tiles.add(Tile(botRack[i].color, botRack[i].number, false));
                tileToDelete.add(i);
              }
            }
          }
        }
      }
      if (tileToDelete.isNotEmpty) {
        set.position = -1;
      }
      for (var index in tileToDelete) {
        botRack.removeAt(index);
      }
    }
  }

  List<dynamic> _findRun(List<Tile> rack, int index) {
    var set = [rack[index]];
    for (var tile in rack.skip(index + 1)) {
      if ((tile.number == set.last.number + 1 && tile.color == set.last.color) ||
          tile.number == 0 || set.last.number == 0) {
        set.add(tile);
      }
    }
    if (_checkRun(set)) {
      for (var tile in set) {
        rack.remove(tile);
      }
      return [set, index];
    }
    return [[], index + 1];
  }

  List<dynamic> _findGroup(List<Tile> rack, int index) {
    var set = [rack[index]];
    for (var tile in rack.skip(index + 1)) {
      if ((tile.number == set.last.number && !set.contains(tile)) ||
          tile.number == 0 || set.last.number == 0) {
        set.add(tile);
      }
    }
    if (_checkGroup(set)) {
      for (var tile in set) {
        rack.remove(tile);
      }
      return [set, index];
    } else {
      return [[], index + 1];
    }
  }

  // sprawdza, czy joker został w prawidlowy sposób dodany do serii
  bool _checkRun(List<Tile> set) {
    if (set.length < 3) {
      return false;
    }

    var tilesToRemoved = [];

    if (set[0].number == 0 && set[1].number == 0 && set[2].number < 3) {
      tilesToRemoved.add(set[0]);
      if (set[2].number == 1) {
        tilesToRemoved.add(set[1]);
      }
    }
    if (set[0].number == 0 && set[1].number == 1) {
      tilesToRemoved.add(set[0]);
    }
    if (set[set.length - 3].number >= 12 && set[set.length - 2].number == 0 && set[set.length - 1].number == 0) {
      tilesToRemoved.add(set[set.length - 1]);
      if (set[2].number == 13) {
        tilesToRemoved.add(set[set.length - 2]);
      }
    }
    if (set[set.length - 2].number == 13 && set[set.length - 1].number == 0) {
      tilesToRemoved.add(set[set.length - 1]);
    }

    set.removeWhere((tile) => tilesToRemoved.contains(tile));

    if (set.length < 3) {
      return false;
    }
    return true;
  }

  // sprawdza, czy joker został w prawidlowy sposób dodany do grupy
  bool _checkGroup(List<Tile> set) {
    if (set.length < 3) {
      return false;
    }
    while (set.length > 4) {
      for (var i = 0; i < set.length; i++) {
        if (set[i].number == 0) {
          set.removeAt(i);
          break;
        }
      }
    }
    return true;
  }

  bool _isUnder30Points(List<List<Tile>> sets) {
    var sum = 0;
    for (var set in sets) {
      if (isRun(set)) {
        var firstNumber = set[0].number;
        if (set[0].number == 0 && set[1].number == 0) {
          firstNumber = set[2].number - 3;
        } else if (set[0].number == 0) {
          firstNumber = set[1].number - 1;
        }
        for (var i = 0; i < set.length; i++) {
          sum += firstNumber;
          firstNumber += 1;
        }
      } else {
        for (var tile in set) {
          if (tile.number != 0) {
            sum += tile.number * set.length;
            break;
          }
        }
      }
    }
    return sum < 30;
  }

}
