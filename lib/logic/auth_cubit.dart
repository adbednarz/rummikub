import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/auth_repository.dart';
import 'package:rummikub/data/game_repository.dart';
import 'package:rummikub/shared/custom_exception.dart';
import 'package:rummikub/shared/models/player.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final GameRepository _gameRepository;
  StreamSubscription? invitationToGame;

  AuthCubit(this._authRepository, this._gameRepository) : super(AuthInitial());

  Future<void> register(String email, String username, String password) async {
    emit(AuthLoading());
    try {
      var user = await _authRepository.signUp(email, username, password).then((value) => null);
      emit(AuthLogged(user));
      listenToInvitationToGame();
    } on CustomException catch(error) {
      emit(AuthFailure(state.user, error.cause));
    }
  }

  Future<void> logIn(String email, String password) async {
    emit(AuthLoading());
    try {
      var user = await _authRepository.logIn(email, password);
      emit(AuthLogged(user));
      listenToInvitationToGame();
    } on CustomException catch(error) {
      emit(AuthFailure(state.user, error.cause));
    }
  }

  void listenToInvitationToGame() {
    var playerId = state.user!.playerId;
    invitationToGame = _authRepository.invitationToGame(playerId).listen((change) {
      if (change.isNotEmpty) {
        emit(AuthInvited(state.user, change['gameId']!, change['player']!));
      }
    });
  }

  Future<void> logOut() async {
    try {
      var playerId = state.user!.playerId;
      emit(AuthLoading());
      await _authRepository.logOut(playerId);
      emit(AuthLoggedOut());
    } on CustomException catch(error) {
      emit(AuthFailure(state.user, error.cause));
    } catch (error) {
      print(error);
      emit(AuthFailure(state.user, 'Error occurred'));
    }
  }

  void acceptInvitation(bool accepted) {
    _gameRepository.joinGame(accepted, (state as AuthInvited).gameId);
  }

  @override
  Future<void> close() async {
    await invitationToGame?.cancel();
    await super.close();
  }

}
