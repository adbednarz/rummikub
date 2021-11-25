import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

part 'game_action_board_state.dart';

class GameActionBoardCubit extends Cubit<GameActionBoardState> {
  final Repository _firebaseRepository;
  late String gameId;
  late String playerId;
  late StreamSubscription tilesSetsSubscription;
  List<int> draggable = new List.filled(2, -1, growable: false);

  GameActionBoardCubit(this._firebaseRepository, Map<String, String> params) : super(GameActionBoardInitial()) {
    gameId = params['gameId']!;
    playerId = params['playerId']!;
    tilesSetsSubscription = _firebaseRepository.getTilesSets(gameId).listen((result) {
      emit(BoardChanged(result));
    });
  }

  removeDraggable(List<TilesSet> sets) {
    if (draggable[1] > 0 && draggable[1] < sets[draggable[0]].tiles.length-1) {
      sets.insert(
          draggable[0] + 1,
          new TilesSet(sets[draggable[0]].position + draggable[1]+1, sets[draggable[0]].tiles.sublist(draggable[1]+1))
      );
      sets[draggable[0]].tiles = sets[draggable[0]].tiles.sublist(0, draggable[1]);
    } else if (draggable[0] != -1) {  // -1, gdy kość nie jest z planszy
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

  addNewSet(int counter, int beforeSetIndex, Tile tile) {
    state.sets.insert(
        beforeSetIndex,
        new TilesSet(counter, [tile])
    );
    if (beforeSetIndex <= draggable[0]) {
      draggable[0] += 1;
    }
    removeDraggable(state.sets);
    emit(BoardChanged(state.sets));
  }

  combineTwoSet(int index, Tile tile) {
    // przesuwana kość nie znajduje się w łączących się zbiorach
    if (draggable[0] != index && draggable[0] != index + 1) {
      state.sets[index].tiles = state.sets[index].tiles + [tile] + state.sets[index+1].tiles;
      state.sets.removeAt(index+1);
      if (index + 1 < draggable[0]) {
        draggable[0] -= 1;
      }
      removeDraggable(state.sets);
    } else if (draggable[0] == index) {  // przesuwana kość znajduje się w lewym zbiorze
      if (state.sets[index].tiles.length == 1) {
        state.sets[index+1].position -= 1;
        state.sets[index+1].tiles = [tile] + state.sets[index+1].tiles;
        removeDraggable(state.sets);
      } else {
        state.sets[index+1].position = state.sets[index].position + draggable[1] + 1;
        state.sets[index+1].tiles = state.sets[index].tiles.sublist(draggable[1]+1) + [tile] + state.sets[index+1].tiles;
        state.sets[index].tiles = state.sets[index].tiles.sublist(0, draggable[1]);
        if (state.sets[index].tiles.isEmpty) {
          state.sets.removeAt(index);
        }
        draggable = [-1, -1];
      }
    } else { // przesuwana kość znajduje się w prawym zbiorze
      if (state.sets[index+1].tiles.length == 1) {
        state.sets[index].tiles += [tile];
        removeDraggable(state.sets);
      } else {
        state.sets[index].tiles = state.sets[index].tiles + [tile] + state.sets[index+1].tiles.sublist(0, draggable[1]);
        state.sets[index+1].position = state.sets[index+1].position + draggable[1] + 1;
        state.sets[index+1].tiles = state.sets[index+1].tiles.sublist(draggable[1]+1);
        if (state.sets[index+1].tiles.isEmpty) {
          state.sets.removeAt(index+1);
        }
        draggable = [-1, -1];
      }
    }
    emit(BoardChanged(state.sets));
  }

  addToExistingSet(int index, Tile tile, String direction) {
    if (direction == 'start') {
      state.sets[index].tiles.insert(0, tile);
      state.sets[index].position -= 1;
      if (index == draggable[0]) {
        draggable[1] += 1;
      }
    } else {
      state.sets[index].tiles.add(tile);
    }
    removeDraggable(state.sets);
    emit(BoardChanged(state.sets));
  }

  bool wantToPutTiles() {
    _firebaseRepository.putTiles(gameId, state.sets);
    return true;
  }

  @override
  Future<void> close() async {
    tilesSetsSubscription.cancel();
    super.close();
  }
}
