import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:rummikub/shared/custom_exception.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class FunctionsProvider {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  FunctionsProvider() {
    var localhost = kIsWeb ? 'localhost' : '192.168.8.104';
    _functions.useFunctionsEmulator(localhost, 5001);
  }

  Future<String> createGame(String playerName, List<String> playersSelected, int timeForMove) async {
    try {
      final results = await _functions.httpsCallable('createGame')
          .call({'playerName': playerName, 'playersSelected': playersSelected, 'timeForMove': timeForMove});
      return results.data['gameId'];
    } catch(error) {
      print(error);
      throw CustomException('Error occurred');
    }
  }

  Future<String> searchGame(String playerName, int playersNumber, int timeForMove) async {
    try {
      final results = await _functions.httpsCallable('searchGame')
          .call({'playerName': playerName, 'playersNumber': playersNumber, 'timeForMove': timeForMove});
      return results.data['gameId'];
    } catch(error) {
      print(error);
      throw CustomException('Error occurred');
    }
  }

  Future<void> joinGame(String playerName, bool accepted, String gameId) async {
    try {
      await _functions.httpsCallable('addToExistingGame')
          .call({'playerName': playerName, 'accepted': accepted, 'gameId': gameId});
    } catch(error) {
      print(error);
      throw CustomException('Error occurred');
    }
  }

  Future<void> putTiles(String gameId, List<TilesSet> sets) async {
    try {
      await _functions.httpsCallable('putTiles').call({
        'gameId': gameId,
        'newBoard': { for (var v in sets) v.position.toString() : v.tiles.map((tile) => tile.asMap()).toList() }
      });
    } catch(error) {
      print(error);
      throw CustomException(error.toString());
    }
  }

  Future<void> leftGame(String gameId) async {
    try {
      await _functions.httpsCallable('leftGame').call({'gameId': gameId});
    } catch(error) {
      print(error);
      throw CustomException(error.toString());
    }
  }
}