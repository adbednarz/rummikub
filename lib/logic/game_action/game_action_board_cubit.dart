import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rummikub/data/game_repository.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

part 'game_action_board_state.dart';

class GameActionBoardCubit extends Cubit<GameActionBoardState> {
  final GameRepository _repository;
  final String gameId;
  final String playerId;
  late StreamSubscription tilesSetsSubscription;
  List<TilesSet> setsBeforeModification = [];
  List<int> draggable = List.filled(2, -1, growable: false);
  bool initialMeld = false;

  GameActionBoardCubit(this._repository, this.gameId, this.playerId) : super(GameActionBoardInitial()) {
    tilesSetsSubscription = _repository.tilesSets(gameId).listen((result) {
      emit(BoardChanged(result));
      setsBeforeModification = result.map((set) => set.copy()).toList();
    });
  }

  void removeDraggable() {
    if (draggable[1] > 0 && draggable[1] < state.sets[draggable[0]].tiles.length-1) {
      state.sets.insert(
          draggable[0] + 1,
          TilesSet(
              state.sets[draggable[0]].position + draggable[1]+1,
              state.sets[draggable[0]].tiles.sublist(draggable[1]+1)
          )
      );
      state.sets[draggable[0]].tiles = state.sets[draggable[0]].tiles.sublist(0, draggable[1]);
    } else if (draggable[0] != -1) {  // -1 - kość jest z planszy
      if(draggable[1] == 0) {
        state.sets[draggable[0]].position += 1;
      }
      state.sets[draggable[0]].tiles.removeAt(draggable[1]);
      if (state.sets[draggable[0]].tiles.isEmpty) {
        state.sets.removeAt(draggable[0]);
      }
    }
    emit(BoardChanged(state.sets));
  }

  void addNewSet(int counter, int beforeSetIndex, Tile tile) {
    state.sets.insert(
        beforeSetIndex,
        TilesSet(counter, [tile])
    );
    if (beforeSetIndex <= draggable[0]) {
      draggable[0] += 1;
    }
    removeDraggable();
  }

  void combineTwoSet(int index, Tile tile) {
    // przesuwana kość nie znajduje się w łączących się zbiorach
    if (draggable[0] != index && draggable[0] != index + 1) {
      state.sets[index].tiles = state.sets[index].tiles + [tile] + state.sets[index+1].tiles;
      state.sets.removeAt(index+1);
      if (index + 1 < draggable[0]) {
        draggable[0] -= 1;
      }
      removeDraggable();
    } else if (draggable[0] == index) {  // przesuwana kość znajduje się w lewym zbiorze
      if (state.sets[index].tiles.length == 1) {
        state.sets[index+1].position -= 1;
        state.sets[index+1].tiles = [tile] + state.sets[index+1].tiles;
        removeDraggable();
      } else {
        state.sets[index+1].position = state.sets[index].position + draggable[1] + 1;
        state.sets[index+1].tiles = state.sets[index].tiles.sublist(draggable[1]+1) + [tile] + state.sets[index+1].tiles;
        state.sets[index].tiles = state.sets[index].tiles.sublist(0, draggable[1]);
        if (state.sets[index].tiles.isEmpty) {
          state.sets.removeAt(index);
        }
        emit(BoardChanged(state.sets));
      }
    } else { // przesuwana kość znajduje się w prawym zbiorze
      if (state.sets[index+1].tiles.length == 1) {
        state.sets[index].tiles += [tile];
        removeDraggable();
      } else {
        state.sets[index].tiles = state.sets[index].tiles + [tile] + state.sets[index+1].tiles.sublist(0, draggable[1]);
        state.sets[index+1].position = state.sets[index+1].position + draggable[1] + 1;
        state.sets[index+1].tiles = state.sets[index+1].tiles.sublist(draggable[1]+1);
        if (state.sets[index+1].tiles.isEmpty) {
          state.sets.removeAt(index+1);
        }
        emit(BoardChanged(state.sets));
      }
    }
  }

  void addToExistingSet(int index, Tile tile, String direction) {
    if (direction == 'start') {
      state.sets[index].tiles.insert(0, tile);
      state.sets[index].position -= 1;
      if (index == draggable[0]) {
        draggable[1] += 1;
      }
    } else {
      state.sets[index].tiles.add(tile);
    }
    removeDraggable();
  }

  bool wantToPutTiles() {
    if (_isValid()) {
      _repository.putTiles(gameId, state.sets);
      return true;
    }
    if (initialMeld) {
      emit(BoardInfo(state.sets, 'The board is not valid'));
    } else {
      emit(BoardInfo(state.sets, 'The board is not valid'));
      emit(BoardInfo(state.sets, 'You cannot modify others sets'));
      emit(BoardInfo(state.sets, 'A value of your tiles min 30'));
    }
    return false;
  }

  bool timePassed() {
    if (_isValid()) {
      _repository.putTiles(gameId, state.sets);
      return true;
    } else {
      _repository.putTiles(gameId, setsBeforeModification);
      emit(BoardChanged(setsBeforeModification.map((set) => set.copy()).toList()));
      return false;
    }
  }

  bool _isValid() {
    for (var set in state.sets) {
      if (set.tiles.length < 3 || (!_isRun(set.tiles) && !_isGroup(List.from(set.tiles)))) {
        return false;
      }
    }
    if (!initialMeld) {
      return _isInitialMeld();
    }
    return true;
  }

  bool _isRun(List<Tile> set) {
    var i = 0;
    var currentNumber = 0;
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

  bool _isGroup(List<Tile> set) {
    var size = set.length;
    set.removeWhere((e) => e.number == 0);
    var uniqueColors = set.map((tile) => tile.color).toSet();
    var uniqueNumbers = set.map((tile) => tile.number).toSet();
    return size < 5 && uniqueColors.length == set.length && uniqueNumbers.length == 1;
  }

  bool _isInitialMeld() {
    var previousTilesNumber = 0;
    var currentTilesNumber = 0;
    for (var set in setsBeforeModification) {
      previousTilesNumber += set.tiles.length;
    }
    for (var set in state.sets) {
      currentTilesNumber += set.tiles.length;
    }
    // gracz wysyła kości bez zmian
    if (previousTilesNumber == currentTilesNumber) {
      return true;
    }

    var setsCopy = List<TilesSet>.from(state.sets);
    var sum = 0;
    var currentSets = setsCopy.map((set) => set.tiles).toList();
    for (var set in currentSets) {
      // nie można modyfikować zbiorów na planszy
      var notMyTiles = set.where((tile) => tile.isMine == false).toList();
      if (notMyTiles.isNotEmpty) {
        return false;
      }
      if (_isRun(set)) {
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
    if (sum < 30) {
      return false;
    }
    initialMeld = true;
    return true;
  }

  @override
  Future<void> close() async {
    await tilesSetsSubscription.cancel();
    await super.close();
  }
}
