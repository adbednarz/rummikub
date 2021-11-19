import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';
import 'package:rummikub/shared/models/tile.dart';

part 'game_action_state.dart';

class GameActionCubit extends Cubit<GameActionState> {
  final Repository _firebaseRepository;
  late String gameId;
  late String playerId;
  late StreamSubscription playerTitlesSubscription;

  GameActionCubit(this._firebaseRepository, Map<String, String> params) : super(GameActionInitial()) {
    gameId = params['gameId']!;
    playerId = params['playerId']!;
    playerTitlesSubscription = _firebaseRepository.getPlayerTiles(gameId, playerId).listen((result) {
      if (result.length != 0) {
        emit(RackChanged(state.rack, result, state.board));
      }
    });
  }

  Future<void> putTiles() async {
    List<List<Tile>> tiles = [];
    try {
      _firebaseRepository.putTiles(gameId, tiles);
    } on CustomException catch(error) {
      emit(Failure(state.rack, error.cause));
    }
  }
  
  addToRack(String from, Tile tile, int newIndex) {
    if (from.startsWith("rack")) {
      int index = int.parse(from.replaceRange(0, 5, ""));
      List<Tile?> newRack = List.from(state.rack);
      newRack[index] = null;
      newRack[newIndex] = tile;
      emit(RackChanged(newRack, [], state.board));
    } else {
      int index = int.parse(from.replaceRange(0, 6, ""));
      List<Tile?> newRack = List.from(state.rack);
      newRack[newIndex] = tile;
      List<Tile?> newBoard = List.from(state.board);
      newBoard[index] = null;
      emit(BoardChanged(newRack, newBoard));
    }
  }

  addToBoard(String from, Tile tile, int newIndex) {
    if (from.startsWith("rack")) {
      int index = int.parse(from.replaceRange(0, 5, ""));
      List<Tile?> newRack = List.from(state.rack);
      newRack[index] = null;
      List<Tile?> newBoard = List.from(state.board);
      newBoard[newIndex] = tile;
      emit(BoardChanged(newRack, newBoard));
    } else {
      int index = int.parse(from.replaceRange(0, 6, ""));
      List<Tile?> newBoard = List.from(state.board);
      newBoard[index] = null;
      newBoard[newIndex] = tile;
      emit(BoardChanged(state.rack, newBoard));
    }
  }

  @override
  Future<void> close() async {
    playerTitlesSubscription.cancel();
    super.close();
  }
}
