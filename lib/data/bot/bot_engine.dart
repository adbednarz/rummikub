import 'package:flutter/foundation.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';
import 'game.dart';

abstract class BotEngine {

  List<dynamic> move(List<TilesSet> sets, List<Tile> botRack);

  List<TilesSet> checkSetsPositions(List<TilesSet> currentSets, List<TilesSet> previousSets) {
    var currentSetsCopy = List<TilesSet>.from(currentSets);
    currentSetsCopy.removeWhere((set) => previousSets.contains(set));
    if (currentSetsCopy.isEmpty) {
      return [];
    }
    var newSets = List<TilesSet>.from(currentSets);
    newSets.removeWhere((set) => set.position != -1);
    var modifiedSets = List<TilesSet>.from(currentSets);
    modifiedSets.removeWhere((set) => set.position == -1);
    var takenPlacesList = <List<int>>[];

    var setsToChange = <TilesSet>[];
    for (var set in modifiedSets) {
      if (_checkBoard(set.position, set.position + set.tiles.length - 1) == -1) {
        takenPlacesList.add([for (var i = set.position; i < set.position + set.tiles.length; i++) i]);
      } else {
        setsToChange.add(set);
      }
    }

    for (var set in setsToChange) {
      modifiedSets.remove(set);
    }
    newSets.addAll(setsToChange);

    for (var set in newSets) {
      var newTakenPlaces = [for (var i = 0; i < set.tiles.length; i++) i];

      for (var takenPlaces in takenPlacesList) {
        if (newTakenPlaces.any((place) => takenPlaces.contains(place))) {
          newTakenPlaces = [for (var i = takenPlaces.last + 2; i < takenPlaces.last + 2 + set.tiles.length; i++) i];
          var offset = _checkBoard(newTakenPlaces.first, newTakenPlaces.last);
          if (offset != -1) {
            newTakenPlaces = [for (var i = takenPlaces.first + offset; i < takenPlaces.last + 1 + offset; i++) i];
          }
        } else {
          break;
        }
      }
      takenPlacesList.add(newTakenPlaces);
      takenPlacesList.sort((x, y) => x.first.compareTo(y.first));
      set.position = newTakenPlaces.first;
    }

    modifiedSets.addAll(newSets);
    modifiedSets.sort((a, b) => a.position.compareTo(b.position));
    return modifiedSets;
  }

  bool isUnder30Points(List<List<Tile>> sets) {
    var sum = 0;
    for (var set in sets) {
      if (Game.isRun(set)) {
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

}