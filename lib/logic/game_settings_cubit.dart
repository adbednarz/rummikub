import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'game_settings_state.dart';

class GameSettingsCubit extends Cubit<GameSettingsState> {
  GameSettingsCubit(this._firebaseRepository) : super(GameSettingsInitial());

  final Repository _firebaseRepository;
  String? gameID;
  StreamSubscription? missingPlayersNumberSubscription;

  Future<void> searchGame({
    required int playersNumber,
  }) async {
    emit(Loading());
    try {
      gameID = await _firebaseRepository.searchGame(playersNumber: playersNumber);
      missingPlayersNumberSubscription?.cancel();
      missingPlayersNumberSubscription = _firebaseRepository.getMissingPlayersNumberToStartGame(gameID!).listen((change) {
        if (state is Waiting)
          (state as Waiting) .missingPlayersNumber = change.toString();
        else
          emit(Waiting(change.toString()));
      });
    } on CustomException catch(error) {
      emit(Failure(error.cause));
    }
  }
}
