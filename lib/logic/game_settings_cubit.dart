import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'game_settings_state.dart';

class GameSettingsCubit extends Cubit<GameSettingsState> {
  GameSettingsCubit(this._firebaseRepository) : super(GameSettingsInitial());

  final Repository _firebaseRepository;

  Future<void> searchGame({
    required int playersNumber,
  }) async {
    emit(Loading());
    try {
      String gameID = await _firebaseRepository.searchGame(playersNumber: playersNumber);
      emit(Waiting());
    } on CustomException catch(error) {
      emit(Failure(error.cause));
    }
  }
}
