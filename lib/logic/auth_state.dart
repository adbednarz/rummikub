part of 'auth_cubit.dart';

@immutable
abstract class AuthState {
  final User? user;

  AuthState(this.user);

  List<Object?> get props => [user];
}

class AuthInitial extends AuthState {
  AuthInitial() : super(null);
}

class AuthLoading extends AuthState {
  AuthLoading() : super(null);
}

class AuthLogged extends AuthState {
  AuthLogged(User? user) : super(user);
}

class AuthInvited extends AuthState {
  final String gameId;
  final String player;

  AuthInvited(User? user, this.gameId, this.player) : super(user);

  @override
  List<Object?> get props => [user, gameId, player];
}

class AuthLoggedOut extends AuthState {
  AuthLoggedOut() : super(null);
}

class AuthFailure extends AuthState {
  final String errorMessage;

  AuthFailure(User? user, this.errorMessage) : super(user);

  @override
  List<Object?> get props => [user, errorMessage];
}
