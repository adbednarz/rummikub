import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'game_settings_state.dart';

class GameSettingsCubit extends Cubit<GameSettingsState> {
  final Repository _repository;
  late final String playerId;
  List<String>? selectedPlayers;
  int? gameSize;
  StreamSubscription? missingPlayersNumberSubscription;

  GameSettingsCubit(this._repository, Map<String, dynamic> params) : super(GameSettingsInitial()) {
    playerId = params['playerId']!;
    if (params['joinGame'] != null) {
      _waitingToStartGame(params['joinGame']);
    } else if( params['selectedPlayers'] != null) {
      selectedPlayers = params['selectedPlayers'];
      gameSize = selectedPlayers!.length + 1;
    }
  }

  Future<void> searchGame() async {
    try {
      emit(Loading(state.playersNumber, state.timeForMove));
      var gameId = await _repository.searchGame(playerId, state.playersNumber, state.timeForMove);
      _waitingToStartGame(gameId);
    } on CustomException catch(error) {
      emit(Failure(error.cause, state.playersNumber, state.timeForMove));
    }
  }

  Future<void> createGame() async {
    try {
      emit(Loading(state.playersNumber, state.timeForMove));
      var gameId = await _repository.createGame(playerId, selectedPlayers!, state.timeForMove);
      _waitingToStartGame(gameId);
    } on CustomException catch(error) {
      emit(Failure(error.cause, state.playersNumber, state.timeForMove));
    }
  }

  void changePlayersNumber(int value) {
    emit(GameChangingSettings(value, state.timeForMove));
  }

  void changeTimeForMove(int value) {
    emit(GameChangingSettings(state.playersNumber, value));
  }

  void _waitingToStartGame(String gameId) {
    missingPlayersNumberSubscription?.cancel();
    missingPlayersNumberSubscription = _repository.getMissingPlayersNumberToStartGame(gameId).listen((change) {
      if (change == 0) {
        emit(GameFound(gameId, state.playersNumber, state.timeForMove));
        missingPlayersNumberSubscription?.cancel();
      } else {
        emit(Waiting(change, state.playersNumber, state.timeForMove));
      }
    });
  }

  @override
  Future<void> close() async {
    await missingPlayersNumberSubscription?.cancel();
    await super.close();
  }

}


