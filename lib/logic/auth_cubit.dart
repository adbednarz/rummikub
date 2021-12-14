import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Repository _firebaseRepository;
  StreamSubscription? userDocument;

  AuthCubit(this._firebaseRepository) : super(AuthInitial());

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      var user = await _firebaseRepository.signUp(email, username, password);
      emit(AuthLogged(user));
      listenToChangesInUserDocument();
    } on CustomException catch(error) {
      emit(AuthFailure(state.user, error.cause));
    }
  }

  Future<void> logIn(String email, String password) async {
    emit(AuthLoading());
    try {
      var user = await _firebaseRepository.logIn(email, password);
      emit(AuthLogged(user));
      listenToChangesInUserDocument();
    } on CustomException catch(error) {
      emit(AuthFailure(state.user, error.cause));
    }
  }

  void listenToChangesInUserDocument() {
    userDocument = _firebaseRepository.getUserDocumentChanges(state.user!.uid).listen((change) {
      if (change.isNotEmpty) {
        emit(AuthInvited(state.user, change['gameId']!, change['player']!));
      }
    });
  }

  Future<void> logOut() async {
    try {
      var playerId = state.user!.uid;
      emit(AuthLoading());
      await _firebaseRepository.logOut(playerId);
      emit(AuthLoggedOut());
    } on CustomException catch(error) {
      emit(AuthFailure(state.user, error.cause));
    } catch (error) {
      print(error);
      emit(AuthFailure(state.user, 'Error occurred'));
    }
  }

  void acceptInvitation(bool accepted) {
    _firebaseRepository.joinGame(accepted, (state as AuthInvited).gameId);
  }

  @override
  Future<void> close() async {
    await userDocument?.cancel();
    await super.close();
  }

}
