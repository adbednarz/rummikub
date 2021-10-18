import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/data/firebase_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final Repository _firebaseRepository = FirebaseRepository();

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    //emit(AuthLoading());

    _firebaseRepository.signUp(email: email, username: username, password: password);

    //emit(AuthConnected(user));
  }
}
