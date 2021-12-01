import 'package:flutter/cupertino.dart';
import 'package:rummikub/data/bot/bot_engine.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class BasicBot extends BotEngine {

  @override
  List<TilesSet> move(List<TilesSet> sets, List<Tile> botRack) {
    var allTiles = <Tile>[];
    for (var set in sets) {
      for (var tile in set.tiles) {
        allTiles.add(tile);
      }
    }
    for (var tile in botRack) {
      allTiles.add(tile);
    }
    _doAlgorithm(allTiles);
    return [];
  }

  List<List<Tile>> _doAlgorithm(List<Tile> allTiles) {
    var possibleMoves = [];
    for (var i = 0; i < allTiles.length; i++) {
      var tilesLeft = List<Tile>.from(allTiles);
      var strat = [];
      var points = 0;
      var result = check_runs(List.from(allTiles), i);
      if (result[0].isNotEmpty) {
        strat.add(result[0]);
        tilesLeft = result[1];
      }
      result = check_groups(List.from(tilesLeft));
      if (result[0].isNotEmpty) {
        strat.add(result[0]);
        tilesLeft = result[1];
      }
      for (var tile in tilesLeft) {
        points += tile.number;
      }
      var output = [strat, points];
      possibleMoves.add(output);
    }
    possibleMoves.sort((x, y) => x[1].compareTo(y[1]));
    return possibleMoves.first[0];
  }

  List check_runs(List<Tile> allTiles, int index) {
    var total_results = [];
    var sub_results = [];
    allTiles.sort((x, y) => x.number.compareTo(y.number));
    for (var i = 0; i < allTiles.length; i++) {
      sub_results.add(allTiles[index]);
      for (var item1 in allTiles.take(allTiles.length - index - 1)) {
        if ((item1.number == sub_results.last.number + 1 && allTiles[i].color == item1.color) || item1.number == 0) {
          sub_results.add(item1);
        }
      }
      if (sub_results.length >= 3) {
        for (var item in sub_results) {
          allTiles.remove(item);
        }
        total_results.add(sub_results);
        sub_results = [];
      } else {
        sub_results = [];
      }
    }
    return [total_results, allTiles];
  }

  List check_groups(List<Tile> tilesLeft) {
    var total_results = [];
    var sub_results = [];
    tilesLeft.sort((x, y) => x.number.compareTo(y.number));
    for (var i = tilesLeft.length - 1; i >= 0; i--) {
      sub_results.add(tilesLeft[i]);
      for (var item1 in tilesLeft) {
        if ((item1.number == sub_results.last.number && tilesLeft[i].color != item1.color) || item1.number == 0) {
          sub_results.add(item1);
        }
      }
      if (sub_results.length >= 3) {
        for (var item in sub_results) {
          tilesLeft.remove(item);
        }
        total_results.add(sub_results);
        sub_results = [];
      } else {
        sub_results = [];
      }
    }
    return [total_results, tilesLeft];
  }

}