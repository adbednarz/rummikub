import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

abstract class BotEngine {
  bool initialMeld = false;

  List<dynamic> move(List<TilesSet> sets, List<Tile> botRack);

  List<TilesSet> checkSetsPositions(List<TilesSet> currentSets, List<TilesSet> previousSets) {
    var currentSetsCopy = currentSets.map((set) => set.copy()).toList();
    currentSetsCopy.removeWhere((set) => previousSets.contains(set));
    if (currentSetsCopy.isEmpty) {
      return [];
    }

    var setsToChange = <TilesSet>[];
    var otherSets = <TilesSet>[];
    for (var set in currentSets) {
      if (set.position == -1) {
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
        if (setToChangeStart <= setEnd + 1 && setStart - 1 <= setToChangeEnd) {
          setToChangeStart = setEnd + 2;
          setToChangeEnd = setToChangeStart + setToChange.tiles.length - 1;
          var offset = _checkBoard(setToChangeStart, setToChangeEnd);
          if (offset != -1) {
            setToChangeStart += offset;
            setToChangeEnd += offset;
          }
        }
      }
      setToChange.position = setToChangeStart;
      otherSets.add(setToChange);
      otherSets.sort((a, b) => a.position.compareTo(b.position));
    }
    return otherSets;
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