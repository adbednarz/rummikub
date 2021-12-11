part of 'game_searching_cubit.dart';

@immutable
abstract class GameSearchingState extends Equatable {
  final int playersNumber = 2;
  final int timeForMove = 60;

  @override
  List<Object> get props => [playersNumber, timeForMove];
}

class GameSearchingInitial extends GameSearchingState {
  @override
  List<Object> get props => [];
}

class GameChangingSettings extends GameSearchingState {
  final int playersNumber;
  final int timeForMove;

  GameChangingSettings(this.playersNumber, this.timeForMove);

  @override
  List<Object> get props => [playersNumber, timeForMove];
}

class Loading extends GameSearchingState {}

class Waiting extends GameSearchingState {
  final int missingPlayersNumber;

  Waiting(this.missingPlayersNumber);

  List<Object> get props => [missingPlayersNumber];
}

class GameFound extends GameSearchingState {
  final String gameId;
  final int timeForMove;

  GameFound(this.gameId, this.timeForMove);

  List<Object> get props => [gameId];
}

class Failure extends GameSearchingState {
  final String errorMessage;

  Failure(this.errorMessage);

  List<Object> get props => [errorMessage];
}
