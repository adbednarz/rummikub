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
  List<int> draggable = new List.filled(2, -1, growable: false);

  GameActionBoardCubit(this._firebaseRepository, Map<String, String> params) : super(GameActionBoardInitial()) {
    gameId = params['gameId']!;
    playerId = params['playerId']!;
    playerTitlesSubscription = _firebaseRepository.getPlayerTiles(gameId, playerId).listen((result) {

    });
  }

  removeDraggable(List<TilesSet> sets) {
    if (draggable[1] > 0 && draggable[1] < sets[draggable[0]].tiles.length-1) {
      sets.insert(
          draggable[0] + 1,
          new TilesSet(sets[draggable[0]].position + draggable[1]+1, sets[draggable[0]].tiles.sublist(draggable[1]+1))
      );
      sets[draggable[0]].tiles = sets[draggable[0]].tiles.sublist(0, draggable[1]);
    } else if (draggable[0] != -1) {  // kość nie jest z planszy
      if(draggable[1] == 0) {
          sets[draggable[0]].position += 1;
      }
      sets[draggable[0]].tiles.removeAt(draggable[1]);
      if (sets[draggable[0]].tiles.isEmpty) {
        sets.removeAt(draggable[0]);
      }
    }
    draggable = [-1, -1];
  }

  addNewSet(int counter, int previousSetIndex, Tile tile) {
    List<TilesSet> sets = new List.from(state.sets);
    sets.insert(
        previousSetIndex + 1,
        new TilesSet(counter, [tile])
    );
    if (previousSetIndex < draggable[0]) {
      draggable[0] += 1;
    }
    removeDraggable(sets);
    emit(BoardChanged(sets));
  }

  combineTwoSet(int index, Tile tile) {
    List<TilesSet> sets = new List.from(state.sets);
    // przesuwana kość nie znajduje się w łączących się zbiorach
    if (draggable[0] != index && draggable[0] != index + 1) {
      sets[index].tiles = sets[index].tiles + [tile] + sets[index+1].tiles;
      sets.removeAt(index+1);
      if (index + 1 < draggable[0]) {
        draggable[0] -= 1;
      }
      removeDraggable(sets);
    } else if (draggable[0] == index) {
      if (sets[index].tiles.length == 1) {
        sets[index+1].position -= 1;
        sets[index+1].tiles = [tile] + sets[index+1].tiles;
      } else {
        sets[index+1].position = sets[index].position + draggable[1] + 1;
        sets[index+1].tiles = sets[index].tiles.sublist(draggable[1]+1) + [tile] + sets[index+1].tiles;
        sets[index].tiles = sets[index].tiles.sublist(0, draggable[1]);
      }
      draggable = [-1, -1];
    } else {
      if (sets[index+1].tiles.length == 1) {
        sets[index].tiles = sets[index+1].tiles + [tile];
      } else {
        sets[index].tiles = sets[index].tiles + [tile] + sets[index+1].tiles.sublist(0, draggable[1]);
        sets[index+1].position = sets[index+1].position + draggable[1] + 1;
        sets[index+1].tiles = sets[index].tiles.sublist(draggable[1]+1);
      }
      draggable = [-1, -1];
    }
    emit(BoardChanged(sets));
  }

  addToExistingSet(int index, Tile tile, String direction) {
    List<TilesSet> sets = new List.from(state.sets);
    if (direction == 'start') {
      sets[index].tiles.insert(0, tile);
      sets[index].position -= 1;
      if (index == draggable[0]) {
        draggable[1] += 1;
      }
    } else {
      sets[index].tiles.add(tile);
    }
    removeDraggable(sets);
    emit(BoardChanged(sets));
  }

  @override
  Future<void> close() async {
    playerTitlesSubscription.cancel();
    super.close();
  }
}
