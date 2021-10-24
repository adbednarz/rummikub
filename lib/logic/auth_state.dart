part of 'auth_cubit.dart';

@immutable
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoaded extends AuthState {
  AuthLoaded(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  AuthFailure(this.errorMessage);

  final String? errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}
