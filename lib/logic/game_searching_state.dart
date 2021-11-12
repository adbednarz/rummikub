part of 'game_searching_cubit.dart';

@immutable
abstract class GameSearchingState {}

class GameSearchingInitial extends GameSearchingState {}

class Loading extends GameSearchingState {}

class Waiting extends GameSearchingState {
  final int missingPlayersNumber;

  Waiting(this.missingPlayersNumber);

  List<Object> get props => [missingPlayersNumber];
}

class GameFound extends GameSearchingState {
  final String gameId;

  GameFound(this.gameId);

  List<Object> get props => [gameId];
}

class Failure extends GameSearchingState {
  final String errorMessage;

  Failure(this.errorMessage);

  List<Object> get props => [errorMessage];
}
