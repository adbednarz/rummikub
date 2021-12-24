import 'package:rummikub/data/bot/bot_engine.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class AdvancedBot extends BotEngine {
  final List<Map<List<List<int>>, Result>> results = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}];
  final List<List<Tile>> tiles = [[], [], [], [], [], [], [], [], [], [], [], [], [], []]; // 0 - joker
  final colors = ['black', 'blue', 'orange', 'red'];
  List<Tile> botRack = [];

  @override
  List<dynamic> move(List<TilesSet> sets, List<Tile> botRack) {
    for (var set in sets) {
      for (var tile in set.tiles) {
        tiles[tile.number].add(tile);
      }
    }
    for (var tile in botRack) {
      tiles[tile.number].add(tile);
    }
    this.botRack = botRack;
    var result = _maxScore(1, [[0, 0], [0, 0], [0, 0], [0, 0]]);
    if (!initialMeld) {
      if (result.scores < 30) {
        return [[], []];
      } else {
        initialMeld = true;
      }
    } else {
      if (result.leftTiles.length == botRack.length) {
        return [[], []];
      }
    }
    return [checkSetsPositions(sets, result.sets), result.leftTiles];
  }

  Result _maxScore(int value, List<List<int>> runs) {
    if (value > 13) {
      return Result.empty();
    }
    if (results[value - 1].containsKey(runs)) {
      return results[value - 1][runs]!;
    }
    for (var possibleRuns in _makeRuns(value, runs)) {
      var sets = <TilesSet>[];
      var leftTiles = List<Tile>.from(tiles[value]);
      var runScores = _checkRuns(possibleRuns, runs, leftTiles, value);
      var groupScores = _totalGroupSize(leftTiles, sets, value);
      if (groupScores == -1) {
        continue;
      }
      var maxResult = _maxScore(value + 1, possibleRuns);
      var scores = runScores + groupScores + maxResult.scores;
      if ((results[value - 1][runs]?.scores ?? -1) < scores) {
        leftTiles.addAll(maxResult.leftTiles);
        var unfinishedRuns = _getRuns(maxResult.unfinishedRuns, possibleRuns, sets, leftTiles, value);
        if (value == 1 && unfinishedRuns != null) {
          _getRuns(unfinishedRuns, runs, sets, leftTiles, value);
        }
        if (unfinishedRuns == null) {
          continue;
        }
        sets.addAll(maxResult.sets);
        results[value - 1][runs] = Result(scores, unfinishedRuns, sets, leftTiles);
      }
    }
    return results[value - 1][runs] ?? Result.empty();
  }

  List<List<List<int>>> _makeRuns(int value, List<List<int>> runs) {
    var colors = [0, 0, 0, 0];
    for (var tile in tiles[value]) {
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
        possibleMoves[i].add([runs[i][0], last]);
        if (runs[i][0] != runs[i][1]) {
          possibleMoves[i].add([first, runs[i][1]]);
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

  int _checkRuns(List<List<int>> possibleRuns, List<List<int>> runs, List<Tile> leftTiles, int value) {
    var score = 0;
    for (var i = 0; i < 4; i++) {
      for (var j = 0; j < 2; j++) {
        if (possibleRuns[i][j] != 0) {
          if (runs[i][j] == 2 && possibleRuns[i][j] == 3) {
            score += 3 * (value - 1);
          } else if (possibleRuns[i][j] == 3) {
            score += value;
          }
          leftTiles.remove(Tile(colors[i], value, false));
        }
      }
    }
    return score;
  }

  List<List<List<Tile>>>? _getRuns(List<List<List<Tile>>> unfinishedRuns, List<List<int>> runs, List<TilesSet> sets, List<Tile> leftTiles, int value) {
    for (var i = 0; i < 4; i++) {
      for (var j = 0; j < 2; j++) {
        if (runs[i][j] == 0 && unfinishedRuns[i][j].isNotEmpty) {
          if (unfinishedRuns[i][j].length >= 3) {
            sets.add(TilesSet(-1, unfinishedRuns[i][j]));
          } else {
            if (_checkTileProperty(unfinishedRuns[i][j][0], leftTiles) == false) {
              return null;
            }
            if (unfinishedRuns[i][j].length == 2) {
              if (_checkTileProperty(unfinishedRuns[i][j][1], leftTiles) == false) {
                return null;
              }
            }
          }
          unfinishedRuns[i][j] = [];
        } else if (runs[i][j] != 0) {
          unfinishedRuns[i][j].insert(0, Tile(colors[i], value, false));
        }
      }
    }
    return unfinishedRuns;
  }

  int _totalGroupSize(List<Tile> leftTiles, List<TilesSet> sets, int value) {
    var sum = 0;
    var distinctColors = leftTiles.map((tile) => tile.color).toSet();
    if (distinctColors.length >= 3) {
      var distinctTiles = <Tile>[];
      for (var color in distinctColors) {
        var tile = Tile(color, value, false);
        var index = leftTiles.indexWhere((element) => element.isEqual(tile));
        if (index != -1) {
          distinctTiles.add(tile);
          leftTiles.removeAt(index);
        } else {
          distinctTiles.add(Tile(color, value, true));
          leftTiles.remove(tile);
        }
      }
      if (leftTiles.length >= 3) {
        sets.add(TilesSet(-1, List.of(leftTiles)));
        sum += leftTiles.length;
        leftTiles.clear();
      } else if (leftTiles.length == 2 && distinctTiles.length == 4) {
        var tile = distinctTiles.last;
        distinctTiles.removeLast();
        sets.add(TilesSet(-1, List.of(leftTiles) + [tile]));
        sum += leftTiles.length + 1;
        leftTiles.clear();
      }
      sum += distinctTiles.length;
      sets.add(TilesSet(-1, distinctTiles));
    }
    if (leftTiles.any((element) => element.isMine == false)) {
      return -1;
    }
    return sum * value;
  }

  bool _checkTileProperty(Tile tile, List<Tile> leftTiles) {
    leftTiles.add(Tile(tile.color, tile.number, true));
    var res1 = botRack.map((element) => element == tile ? 1 : 0).reduce((value, element) => value + element);
    var res2 = leftTiles.map((element) => element == tile ? 1 : 0).reduce((value, element) => value + element);
    if (res1 < res2) {
      return false;
    }
    return true;
  }

}

class Result {
  int scores;
  List<List<List<Tile>>> unfinishedRuns;
  List<TilesSet> sets;
  List<Tile> leftTiles;

  Result(this.scores, this.unfinishedRuns, this.sets, this.leftTiles);

  Result.empty(): this(0, [[[], []], [[], []], [[], []], [[], []]], [], []);

}