import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'game_searching_state.dart';

class GameSearchingCubit extends Cubit<GameSearchingState> {
  final Repository _repository;
  final String playerId;
  StreamSubscription? missingPlayersNumberSubscription;

  GameSearchingCubit(this._repository, this.playerId) : super(GameSearchingInitial());

  Future<void> searchGame({
    required int playersNumber,
  }) async {
    emit(Loading());
    try {
      String gameId = await _repository.searchGame(playerId, playersNumber);
      missingPlayersNumberSubscription?.cancel();
      missingPlayersNumberSubscription = _repository.getMissingPlayersNumberToStartGame(gameId).listen((change) {
        if (change == 0) {
          emit(GameFound(gameId));
          this.missingPlayersNumberSubscription?.cancel();
        } else {
          emit(Waiting(change));
        }
      });
    } on CustomException catch(error) {
      emit(Failure(error.cause));
    }
  }

  @override
  Future<void> close() async {
    missingPlayersNumberSubscription?.cancel();
    super.close();
  }
}


