import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

abstract class BotEngine {
  bool initialMeld = false;

  List<dynamic> move(List<TilesSet> sets, List<Tile> botRack);

  List<TilesSet> checkSetsPositions(List<TilesSet> currentSets, List<TilesSet> previousSets) {
    var currentSetsCopy = List<TilesSet>.from(currentSets);
    currentSetsCopy.removeWhere((set) => previousSets.contains(set));
    if (currentSetsCopy.isEmpty) {
      return [];
    }

    var setsToChange = <TilesSet>[];
    var otherSets = <TilesSet>[];
    for (var set in currentSets) {
      if (set.position == -1 || _checkBoard(set.position, set.position + set.tiles.length - 1) != -1) {
        setsToChange.add(set);
      } else {
        otherSets.add(set);
      }
    }

    for (var setToChange in setsToChange) {
      var setToChangeStart = 0;
      var setToChangeEnd = setToChange.tiles.length - 1;
      for (var set in otherSets) {
        var setStart = set.position;
        var setEnd = set.position + set.tiles.length - 1;
        if (setToChangeStart <= setEnd && setStart <= setToChangeEnd) {
          setToChangeStart += 2;
          setToChangeEnd += 2;
        } else {
          var offset = _checkBoard(setToChangeStart, setToChangeEnd);
          if (offset != -1) {
            setToChangeStart += offset;
            setToChangeEnd += offset;
          }  else {
            break;
          }
        }
      }
      setToChange.position = setToChangeStart;
    }

    otherSets.addAll(setsToChange);
    otherSets.sort((a, b) => a.position.compareTo(b.position));
    return otherSets;
  }

  bool isUnder30Points(List<List<Tile>> sets) {
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

  bool checkRun(List<Tile> set) {
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

  bool checkGroup(List<Tile> set) {
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

  int _checkBoard(x, y) {
    var firstPosition = x % 13;
    var lastPosition = y % 13;
    if (lastPosition < firstPosition) {
      var offset = 0;
      while ((firstPosition + offset) % 13 != 0) {
        offset++;
      }
      return offset;
    }
    return -1;
  }

  bool isRun(List<Tile> set) {
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