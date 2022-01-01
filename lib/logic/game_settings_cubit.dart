import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/game_repository.dart';
import 'package:rummikub/shared/custom_exception.dart';
import 'package:rummikub/shared/models/player.dart';

part 'game_settings_state.dart';

class GameSettingsCubit extends Cubit<GameSettingsState> {
  final GameRepository repository;
  final Player player;
  List<String>? selectedPlayers;
  int? gameSize;
  StreamSubscription? missingPlayers;
  String? gameId;

  GameSettingsCubit(this.repository, this.player, {this.selectedPlayers, this.gameSize, String? gameId}) : super(GameSettingsInitial()) {
    if (gameId != null) {
      _waitingToStartGame(gameId);
    }
  }

  Future<void> searchGame() async {
    try {
      emit(Loading(state.playersNumber, state.timeForMove));
      gameId = await repository.searchGame(player, state.playersNumber, state.timeForMove);
      _waitingToStartGame(gameId!);
    } on CustomException catch(error) {
      emit(Failure(error.cause, state.playersNumber, state.timeForMove));
    }
  }

  Future<void> createGame() async {
    try {
      emit(Loading(state.playersNumber, state.timeForMove));
      var gameId = await repository.createGame(player, selectedPlayers!, state.timeForMove);
      _waitingToStartGame(gameId);
    } on CustomException catch(error) {
      emit(Failure(error.cause, state.playersNumber, state.timeForMove));
    }
  }

  void changePlayersNumber(int value) {
    emit(GameSettingsChanged(value, state.timeForMove));
  }

  void changeTimeForMove(int value) {
    emit(GameSettingsChanged(state.playersNumber, value));
  }

  void _waitingToStartGame(String gameId) {
    missingPlayers?.cancel();
    missingPlayers = repository.missingPlayers(gameId).listen((change) {
      if (change == 0) {
        emit(GameFound(gameId, state.playersNumber, state.timeForMove));
        missingPlayers?.cancel();
      } else {
        emit(Waiting(change, state.playersNumber, state.timeForMove));
      }
    });
  }

  @override
  Future<void> close() async {
    await missingPlayers?.cancel();
    if (gameId != null) {
      await repository.leaveGame(gameId!, player.playerId);
    }
    await super.close();
  }

}


