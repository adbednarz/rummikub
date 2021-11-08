import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'game_creating_state.dart';

class GameCreatingCubit extends Cubit<GameCreatingState> {
  GameCreatingCubit(this._firebaseRepository) : super(GameCreatingInitial());

  final Repository _firebaseRepository;
  String? gameID;
  StreamSubscription? missingPlayersSubscription;

  Future<void> searchGame({
    required int playersNumber,
  }) async {
    emit(Waiting(''));
    try {
      gameID = await _firebaseRepository.searchGame(playersNumber: playersNumber);
      missingPlayersSubscription?.cancel();
      missingPlayersSubscription = _firebaseRepository.getMissingPlayersNumberToStartGame(gameID!).listen((change) {
        if (change == 0)
          emit(GameFound());
        else
          emit(Waiting(change.toString()));
      });
    } on CustomException catch(error) {
      emit(Failure(error.cause));
    }
  }

  @override
  Future<void> close() async {
    missingPlayersSubscription?.cancel();
    super.close();
  }
}
