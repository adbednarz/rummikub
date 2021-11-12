part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLogged extends AuthState {
  AuthLogged(this.user);

  final User user;

  List<User> get props => [user];
}

class AuthLoggedOut extends AuthState {}

class AuthFailure extends AuthState {
  AuthFailure(this.errorMessage);

  final String errorMessage;

  List<Object> get props => [errorMessage];
}
