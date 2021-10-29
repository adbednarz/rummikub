import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/firebase_repository.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/logic/auth_cubit.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'game_settings_state.dart';

class GameSettingsCubit extends Cubit<GameSettingsState> {
  GameSettingsCubit(this._authCubit) : super(GameSettingsInitial());

  final Repository _firebaseRepository = FirebaseRepository();
  final AuthCubit _authCubit;

  Future<void> searchGame({
    required int playersNumber,
  }) async {
    emit(Loading());
    try {
      String userID = (_authCubit.state as AuthLogged) .user.uid;
      await _firebaseRepository.searchGame(playersNumber: playersNumber, userID: userID);
    } on CustomException catch(error) {
      emit(Failure(error.cause));
    }
  }
}
