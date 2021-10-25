import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/data/firebase_repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final Repository _firebaseRepository = FirebaseRepository();

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
    emit(AuthLoading());
    try {
      _firebaseRepository.logOut();
      emit(AuthLoggedOut());
    } on CustomException catch(error) {
      emit(AuthFailure(error.cause));
    }
  }
}
