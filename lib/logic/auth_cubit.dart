import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._firebaseRepository) : super(AuthInitial());

  final Repository _firebaseRepository;

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      User user = await _firebaseRepository.signUp(email: email, username: username, password: password);
      emit(AuthLogged(user));
    } on CustomException catch(error) {
      emit(AuthFailure(error.cause));
    }
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      User user = await _firebaseRepository.logIn(email: email, password: password);
      emit(AuthLogged(user));
    } on CustomException catch(error) {
      emit(AuthFailure(error.cause));
    }
  }

  Future<void> logOut() async {
    try {
      String userID = (state as AuthLogged) .user.uid;
      emit(AuthLoading());
      _firebaseRepository.logOut(userID: userID);
      emit(AuthLoggedOut());
    } on CustomException catch(error) {
      emit(AuthFailure(error.cause));
    } catch (error) {
      print(error);
      emit(AuthFailure('Error occurred'));
    }
  }

  @override
  Future<void> close() async {
    if (state is AuthLogged) {
      String userID = (state as AuthLogged).user.uid;
      _firebaseRepository.logOut(userID: userID);
    }
    super.close();
  }
}
