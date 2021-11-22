import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

part 'game_action_board_state.dart';

class GameActionBoardCubit extends Cubit<GameActionBoardState> {
  final Repository _firebaseRepository;
  late String gameId;
  late String playerId;
  late StreamSubscription playerTitlesSubscription;

  GameActionBoardCubit(this._firebaseRepository, Map<String, String> params) : super(GameActionBoardInitial()) {
    gameId = params['gameId']!;
    playerId = params['playerId']!;
    playerTitlesSubscription = _firebaseRepository.getPlayerTiles(gameId, playerId).listen((result) {

    });
  }

  removeTile(String key, Tile tile) {
    Map<String, TilesSet> sets = Map.from(state.sets);
    sets[key]!.tiles.remove(tile);
    if (sets[key]!.tiles.isEmpty) {
      sets.remove(key);
    }
    emit(BoardChanged(sets));
  }

  addNewSet(int counter, Tile tile) {
    Map<String, TilesSet> sets = Map.from(state.sets);
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    sets[time] = TilesSet(counter, [tile]);
    emit(BoardChanged(sets));
  }

  combineTwoSet(String key1, String key2, Tile tile) {
    Map<String, TilesSet> sets = Map.from(state.sets);
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    sets[key1]!.tiles.addAll([tile] + sets[key2]!.tiles);
    sets[time] = sets[key1]!;
    sets.remove(key1);
    sets.remove(key2);
    emit(BoardChanged(sets));
  }

  addToExistingSet(String key, Tile tile, String direction) {
    if (tile == this.state.sets[key]!.tiles[0]) {
      addNewSet(this.state.sets[key]!.position - 1, tile);
    } else {
      Map<String, TilesSet> sets = Map.from(state.sets);
      if (direction == 'start') {
        sets[key]!.tiles.insert(0, tile);
        sets[key]!.position -= 1;
      } else {
        sets[key]!.tiles.add(tile);
      }
      emit(BoardChanged(sets));
    }
  }

  @override
  Future<void> close() async {
    playerTitlesSubscription.cancel();
    super.close();
  }
}
