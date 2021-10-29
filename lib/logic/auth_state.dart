part of 'auth_cubit.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLogged extends AuthState {
  AuthLogged(this.user);

  final User user;

  @override
  List<User> get props => [user];
}

class AuthLoggedOut extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthFailure extends AuthState {
  AuthFailure(this.errorMessage);

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}
