import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'game_searching_state.dart';

class GameSearchingCubit extends Cubit<GameSearchingState> {
  final Repository _repository;
  late final String playerId;
  List<String>? selectedPlayers;
  StreamSubscription? missingPlayersNumberSubscription;

  GameSearchingCubit(this._repository, dynamic params) : super(GameSearchingInitial()) {
    if (params is String) {
      playerId = params;
    } else {
      playerId = params['playerId']!;
      selectedPlayers = params['selectedPlayers']!;
    }
  }

  Future<void> searchGame() async {
    var playersNumber = state.playersNumber;
    var timeForMove = state.timeForMove;
    try {
      emit(Loading());
      var gameId = await _repository.searchGame(playerId, playersNumber, timeForMove);
      await missingPlayersNumberSubscription?.cancel();
      missingPlayersNumberSubscription = _repository.getMissingPlayersNumberToStartGame(gameId).listen((change) {
        if (change == 0) {
          emit(GameFound(gameId, timeForMove));
          missingPlayersNumberSubscription?.cancel();
        } else {
          emit(Waiting(change));
        }
      });
    } on CustomException catch(error) {
      emit(Failure(error.cause));
    }
  }

  Future<void> createGame() async {
    var timeForMove = state.timeForMove;
    try {
      emit(Loading());
      var gameId = await _repository.createGame(playerId, selectedPlayers, timeForMove);
      await missingPlayersNumberSubscription?.cancel();
      missingPlayersNumberSubscription = _repository.getMissingPlayersNumberToStartGame(gameId).listen((change) {
        if (change == selectedPlayers!.length * -1) {
          emit(GameFound(gameId, timeForMove));
          missingPlayersNumberSubscription?.cancel();
        } else {
          emit(Waiting(selectedPlayers!.length + change));
        }
      });
    } on CustomException catch(error) {
      emit(Failure(error.cause));
    }
  }

  changePlayersNumber(int value) {
    emit(GameChangingSettings(value, state.timeForMove));
  }

  changeTimeForMove(int value) {
    emit(GameChangingSettings(state.playersNumber, value));
  }

  @override
  Future<void> close() async {
    await missingPlayersNumberSubscription?.cancel();
    await super.close();
  }

}


