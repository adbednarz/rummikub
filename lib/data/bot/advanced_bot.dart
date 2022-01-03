import 'package:rummikub/data/bot/bot_engine.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class AdvancedBot extends BotEngine {
  final colors = ['black', 'blue', 'orange', 'red'];
  late List<Map<String, Result>> results;
  late List<List<Tile>> tiles;

  @override
  List<dynamic> move(List<TilesSet> sets, List<Tile> botRack) {
    results = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}];
    tiles = [[], [], [], [], [], [], [], [], [], [], [], [], []];
    if (initialMeld) {
      for (var set in sets) {
        for (var tile in set.tiles) {
          tiles[tile.number - 1].add(tile);
        }
      }
    }
    for (var tile in botRack) {
      tiles[tile.number - 1].add(tile);
    }
    var result = _maxScore(
        1,
        [[0, 0], [0, 0], [0, 0], [0, 0]],
        [[0, 0], [0, 0], [0, 0], [0, 0]]
    );
    var resultSets = <TilesSet>[];
    var botTiles = <Tile>[];
    if (!initialMeld) {
      if (result.scores < 30) {
        return [[], []];
      } else {
        initialMeld = true;
        _getSolution(resultSets, botTiles);
        return [checkSetsPositions(resultSets + sets, sets), botTiles];
      }
    } else {
      _getSolution(resultSets, botTiles);
      if (botTiles.length == botRack.length) {
        return [[], []];
      }
    }
    return [checkSetsPositions(resultSets, sets), botTiles];
  }

  Result _maxScore(int value, List<List<int>> runs, List<List<int>> tableTiles) {
    if (value > 13) {
      return Result.empty();
    }
    var runsKey = runs.expand((e) => e).map((e) => e.toString()).toList().join('');
    if (results[value - 1].containsKey(runsKey)) {
      return results[value - 1][runsKey]!;
    }

    // 754 jest to suma wszyskich kości, która zostanie zwrócona w przypadku, gdy wszystkie następne ruchy są nieprawidłowe
    // gwarantuje to nam, że ta ścieżka nie zostanie wybrana, nawet jeśli poprzednie ruchy dały dużo punktów
    results[value - 1][runsKey] = Result(-754, [[0, 0], [0, 0], [0, 0], [0, 0]]);
    for (var possibleRuns in _makeRuns(value, runs)) {
      var tableTilesCopy = [for (var sublist in tableTiles) [...sublist]]; // kopiowanie wielowymiarowych list
      var leftTiles = List<Tile>.from(tiles[value - 1]);
      var runScores = _getRunScores(possibleRuns, runs, tableTilesCopy, leftTiles, value);
      var groupScores = _getGroupScores(tableTilesCopy, leftTiles, value);
      if (runScores == -1 || groupScores == -1) {
        continue;
      }
      var maxResult = _maxScore(value + 1, possibleRuns, tableTilesCopy);
      var sum = runScores + groupScores + maxResult.scores;
      if (results[value - 1][runsKey]!.scores < sum) {
        results[value - 1][runsKey] = Result(sum, possibleRuns);
      }
    }
    return results[value - 1][runsKey]!;
  }

  List<List<List<int>>> _makeRuns(int value, List<List<int>> runs) {
    var colors = [0, 0, 0, 0];
    for (var tile in tiles[value - 1]) {
      if (tile.color == 'black') {
        colors[0] += 1;
      } else if (tile.color == 'blue') {
        colors[1] += 1;
      } else if (tile.color == 'orange') {
        colors[2] += 1;
      } else {
        colors[3] += 1;
      }
    }
    var possibleMoves = [[[0, 0]], [[0, 0]], [[0, 0]], [[0, 0]]];
    for (var i = 0; i < 4; i++) {
      var first = runs[i][0] == 3 ? 3 : runs[i][0] + 1;
      var last = runs[i][1] == 3 ? 3 : runs[i][1] + 1;
      if (colors[i] != 0) {
        possibleMoves[i].add([0, last]);
        if (runs[i][0] != runs[i][1]) {
          possibleMoves[i].add([first, 0]);
        }
      }
      if (colors[i] == 2) {
        possibleMoves[i].add([first, last]);
      }
    }
    var possibleRuns = <List<List<int>>>[];
    var possibleRun = [[0, 0], [0, 0], [0, 0], [0, 0]];
    for (var i = 0; i < possibleMoves[0].length; i++) {
      possibleRun[0] = possibleMoves[0][i];
      for (var j = 0; j < possibleMoves[1].length; j++) {
        possibleRun[1] = possibleMoves[1][j];
        for (var k = 0; k < possibleMoves[2].length; k++) {
          possibleRun[2] = possibleMoves[2][k];
          for (var l = 0; l < possibleMoves[3].length; l++) {
            possibleRun[3] = possibleMoves[3][l];
            possibleRuns.add(List.from(possibleRun));
          }
        }
      }
    }
    return possibleRuns;
  }

  int _getRunScores(List<List<int>> possibleRuns, List<List<int>> runs, List<List<int>> tableTiles, List<Tile> leftTiles, int value) {
    var score = 0;
    for (var i = 0; i < 4; i++) {
      var tableTilesCurrentValue = 0;
      for (var j = 0; j < 2; j++) {
        if (possibleRuns[i][j] != 0) {
          if (runs[i][j] == 2 && possibleRuns[i][j] == 3) {
            score += 3 * (value - 1);
            if (tableTiles[i][0] != 0) {
              tableTiles[i][0] -= 1;
            }
            if (tableTiles[i][1] != 0) {
              tableTiles[i][1] -= 1;
            }
          } else if (possibleRuns[i][j] == 3) {
            score += value;
          }
          var tile = Tile(colors[i], value, false);
          var index = leftTiles.indexWhere((element) => element.isEqual(tile));
          if (index != -1) {
            if (possibleRuns[i][j] != 3) {
              tableTilesCurrentValue += 1;
            }
            leftTiles.removeAt(index);
          } else {
            leftTiles.remove(tile);
          }
        }
      }
      if (possibleRuns[i][0] == 0 && possibleRuns[i][1] == 0) {
        if (tableTiles[i][0] != 0 || tableTiles[i][1] != 0) {
          return -1;
        }
      } else if (possibleRuns[i][0] == 0) {
        if (!_checkBoardTiles(runs[i][0], runs[i][1], tableTiles[i])) {
          return -1;
        }
      } else if ( possibleRuns[i][1] == 0) {
        if (!_checkBoardTiles(runs[i][1], runs[i][0], tableTiles[i])) {
          return -1;
        }
      }
      tableTiles[i].removeAt(0);
      tableTiles[i].add(tableTilesCurrentValue);
    }
    return score;
  }

  int _getGroupScores(List<List<int>> tableTiles, List<Tile> leftTiles, int value) {
    var sum = 0;
    var distinctColors = leftTiles.map((tile) => tile.color).toSet();
    if (distinctColors.length >= 3) {
      for (var color in distinctColors) {
        var tile = Tile(color, value, false);
        var index = leftTiles.indexWhere((element) => element.isEqual(tile));
        if (index != -1) {
          leftTiles.removeAt(index);
        } else {
          leftTiles.remove(tile);
          var i = colors.indexOf(color);
          if (tableTiles[i][1] > 0) {
            tableTiles[i][1] -= 1;
          }
        }
      }
      sum += distinctColors.length;
      if (leftTiles.length >= 3 || (leftTiles.length == 2 && distinctColors.length == 4)) {
        sum += leftTiles.length;
        leftTiles.clear();
      }
    }
    if (leftTiles.any((element) => element.isMine == false)) {
      return -1;
    }
    return sum * value;
  }

  // iteruje po najlepszych rozwiązaniach dla danej wartości kości i zwraca utworzone zbiory
  void _getSolution(List<TilesSet> sets, List<Tile> botTiles) {
    var result = Result.empty();
    var unfinishedRuns = <List<List<Tile>>>[[[], []], [[], []], [[], []], [[], []]];
    for (var i = 1; i <= 13; i++) {
      var runsKey = result.chosenRuns.expand((e) => e).map((e) => e.toString()).toList().join('');
      result = results[i-1][runsKey] ?? Result.empty();
      _getRuns(unfinishedRuns, result.chosenRuns, sets, botTiles, i);
      _getGroups(sets, botTiles, i);
    }
    _getRuns(unfinishedRuns, [[0, 0], [0, 0], [0, 0], [0, 0]], sets, botTiles, 0);
  }

  // tworzy jak największe grupy z kości o danej wartości liczbowej
  void _getGroups(List<TilesSet> sets, List<Tile> botTiles, int value) {
    var distinct = tiles[value-1].map((tile) => tile.color).toSet().map((color) => Tile(color, value, false)).toList();
    if (distinct.length >= 3) {
      for (var tile in distinct) {
        tiles[value-1].remove(tile);
      }
      if (tiles[value-1].length >= 3) {
        var tilesToAdd = tiles[value-1].map((tile) => Tile(tile.color, tile.number, false)).toList();
        tiles[value-1].clear();
        sets.add(TilesSet(-1, tilesToAdd));
      } else if (tiles[value-1].length == 2 && distinct.length == 4) {
        var index = distinct.indexWhere((tile) => !tiles[value-1].contains(tile));
        tiles[value-1].add(distinct[index]);
        distinct.removeAt(index);
        var tilesToAdd = tiles[value-1].map((tile) => Tile(tile.color, tile.number, false)).toList();
        tiles[value-1].clear();
        sets.add(TilesSet(-1, tilesToAdd));
      }
      sets.add(TilesSet(-1, distinct));
    }
    botTiles.addAll(tiles[value-1].map((tile) => Tile(tile.color, tile.number, true)).toList());
  }

  // odczytuje zakodowane serie w runs i na tej podstawie tworzy zbiory kości
  void _getRuns(List<List<List<Tile>>> unfinishedRuns, List<List<int>> runs, List<TilesSet> sets, List<Tile> botTiles, int value) {
    for (var i = 0; i < 4; i++) {
      for (var j = 0; j < 2; j++) {
        if (runs[i][j] == 0 && unfinishedRuns[i][j].isNotEmpty) {
          if (unfinishedRuns[i][j].length >= 3) {
            sets.add(TilesSet(-1, unfinishedRuns[i][j]));
          } else {
            for (var tile in unfinishedRuns[i][j]) {
              botTiles.add(Tile(tile.color, tile.number, true));
            }
          }
          unfinishedRuns[i][j] = [];
        } else if (runs[i][j] != 0) {
          unfinishedRuns[i][j].add(Tile(colors[i], value, false));
          tiles[value-1].remove(Tile(colors[i], value, false));
        }
      }
    }
  }

  // sprawdza, czy przerwanie serii, która ma długość mniejszą od 3 nie zawiera kości leżących na planszy
  bool _checkBoardTiles(int runsToDelete, int runs, List<int> tableTiles) {
    if (runsToDelete == 1) {
      if (runs == 1 || runs == 2) {
        if (tableTiles[1] == 2) {
          return false;
        }
      } else if (tableTiles[1] != 0) {
        return false;
      }
    } else if (runsToDelete == 2) {
      if (runs == 1) {
        if (tableTiles[0] != 0) {
          return false;
        }
        if (tableTiles[1] == 2) {
          return false;
        }
      } else if (runs == 2) {
        if (tableTiles[0] == 2 || tableTiles[1] == 2) {
          return false;
        }
      } else if (tableTiles[0] != 0 || tableTiles[1] != 0) {
        return false;
      }
    }
    return true;
  }

}

class Result {
  final int scores;
  final List<List<int>> chosenRuns;

  Result(this.scores, this.chosenRuns);

  Result.empty(): this(0, [[0, 0], [0, 0], [0, 0], [0, 0]]);

}