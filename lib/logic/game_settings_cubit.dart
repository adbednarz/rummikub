import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/game_repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'game_settings_state.dart';

class GameSettingsCubit extends Cubit<GameSettingsState> {
  final GameRepository repository;
  final String playerId;
  List<String>? selectedPlayers;
  int? gameSize;
  StreamSubscription? missingPlayersNumber;
  String? gameId;

  GameSettingsCubit(this.repository, this.playerId, {this.selectedPlayers, this.gameSize, String? gameId}) : super(GameSettingsInitial()) {
    if (gameId != null) {
      _waitingToStartGame(gameId);
    }
  }

  Future<void> searchGame() async {
    try {
      emit(Loading(state.playersNumber, state.timeForMove));
      gameId = await repository.searchGame(playerId, state.playersNumber, state.timeForMove);
      _waitingToStartGame(gameId!);
    } on CustomException catch(error) {
      emit(Failure(error.cause, state.playersNumber, state.timeForMove));
    }
  }

  Future<void> createGame() async {
    try {
      emit(Loading(state.playersNumber, state.timeForMove));
      var gameId = await repository.createGame(playerId, selectedPlayers!, state.timeForMove);
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
    missingPlayersNumber?.cancel();
    missingPlayersNumber = repository.getMissingPlayersNumberToStartGame(gameId).listen((change) {
      if (change == 0) {
        emit(GameFound(gameId, state.playersNumber, state.timeForMove));
        missingPlayersNumber?.cancel();
      } else {
        emit(Waiting(change, state.playersNumber, state.timeForMove));
      }
    });
  }

  @override
  Future<void> close() async {
    await missingPlayersNumber?.cancel();
    if (gameId != null) {
      await repository.leaveGame(gameId!, playerId, false);
    }
    await super.close();
  }

}


