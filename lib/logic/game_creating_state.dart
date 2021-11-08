part of 'game_creating_cubit.dart';

abstract class GameCreatingState {}

class GameCreatingInitial extends GameCreatingState {}

class Loading extends GameCreatingState {}

class Waiting extends GameCreatingState {
  Waiting(this.missingPlayersNumber);

  String missingPlayersNumber;

  List<Object> get props => [missingPlayersNumber];
}

class GameFound extends GameCreatingState {}

class Failure extends GameCreatingState {
  Failure(this.errorMessage);

  final String errorMessage;

  List<Object> get props => [errorMessage];
}
