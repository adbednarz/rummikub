import 'package:rummikub/data/bot/bot_engine.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class BasicBot extends BotEngine {

  @override
  List<dynamic> move(List<TilesSet> sets, List<Tile> botRack) {
    var allTiles = <Tile>[];
    for (var set in sets) {
      allTiles.addAll(set.tiles);
    }
    allTiles.addAll(botRack);
    allTiles.sort((x, y) => x.number.compareTo(y.number));
    var result = _doAlgorithm(allTiles);
    return [checkSetsPositions(sets, result[0]), result[1]];
  }

  List _doAlgorithm(List<Tile> tiles) {
    var first_combinations = [[[], tiles]];
    var all_combinations = [];

    var output_runs_combination = runs_try(
        first_combinations[0][0], first_combinations[0][1], all_combinations);
    if (output_runs_combination.length == 1) {
      return output_runs_combination[0];
    }

    for (var runs_combination in output_runs_combination.skip(1)) {
      groups_try(runs_combination[0], runs_combination[1], all_combinations);
    }
    var new_combinations = [];
    for (var combination in all_combinations.reversed) {
      var hand = combination[0];
      List<Tile> tilesLeft = combination[1];
      var score = 0;
      for (var tile in tilesLeft) {
        score += tile.number;
      }
      new_combinations.add([hand.toList(), tilesLeft.toList(), score]);
    }

    new_combinations.sort((x, y) => x[2].compareTo(y[2]));
    return new_combinations;
  }

  List runs_try(List suit, List lefts, List all_combinations) {
    var run = [];
    var leftscopy = List.from(lefts);
    if (all_combinations.length > 1) {
      if (lefts == all_combinations[-2][-1]) {
        suit = [];
        return [];
      }
    }
    for (var i = 0; i < leftscopy.length; i++) {
      run.add(leftscopy[i]);
      for (Tile tile in leftscopy.skip(i+1)) {
        if (tile.number == run.last.number + 1 && tile.color == leftscopy[i].color) {
          run.add(tile);
          if (run.length >= 3) {
            var cards_left = List.from(leftscopy);
            for (var tile in run) {
              cards_left.remove(tile);
            }
            if (cards_left.length == 0) {
              return [[[List.from(suit) + List.from(run), cards_left], 0]];
            }
            all_combinations.add([List.from(suit) + List.from(run), cards_left]);

            runs_try(List.from(suit) + List.from(run), List.from(cards_left), all_combinations);
          }
        }
      }
    }
    run = [];
    return all_combinations;
  }

  List groups_try(List suit, List lefts, List all_combinations) {
    var sub_results = [];
    var subsuit = List.from(suit);
    var leftscopy = List.from(lefts);
    if (all_combinations.length > 1) {
      if (lefts == all_combinations[-2][-1]) {
        suit = [];
        return [];
      }
    }
    for (var i = 0; i < leftscopy.length; i++) {
      sub_results.add(leftscopy[i]);
      for (var tile in leftscopy.skip(i+1)) {
        if (tile.number == sub_results.last.number && !sub_results.contains(tile)) {
          sub_results.add(tile);
          if (sub_results.length >= 3) {
            var cards_left = List.from(leftscopy);
            for (var tile in sub_results) {
              cards_left.remove(tile);
            }
            all_combinations.add([List.from(suit) + List.from(sub_results), cards_left]);
            groups_try(List.from(suit) + List.from(sub_results), List.from(cards_left), all_combinations);
          }
        }
      }
      sub_results = [];
    }
    return [subsuit, leftscopy];
  }

}