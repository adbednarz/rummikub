part of 'game_settings_cubit.dart';

@immutable
abstract class GameSettingsState extends Equatable {
  final int playersNumber;
  final int timeForMove;

  GameSettingsState(this.playersNumber, this.timeForMove);

  @override
  List<Object> get props => [playersNumber, timeForMove];
}

class GameSettingsInitial extends GameSettingsState {
  GameSettingsInitial() : super(2, 60);
}

class GameChangingSettings extends GameSettingsState {
  GameChangingSettings(int playersNumber, int timeForMove) : super(playersNumber, timeForMove);
}

class Loading extends GameSettingsState {
  Loading(int playersNumber, int timeForMove) : super(playersNumber, timeForMove);
}

class Waiting extends GameSettingsState {
  final int missingPlayersNumber;

  Waiting(this.missingPlayersNumber, int playersNumber, int timeForMove) : super(playersNumber, timeForMove);

  @override
  List<Object> get props => [missingPlayersNumber, playersNumber, timeForMove];
}

class GameFound extends GameSettingsState {
  final String gameId;

  GameFound(this.gameId, int playersNumber, int timeForMove) : super(playersNumber, timeForMove);

  @override
  List<Object> get props => [gameId, playersNumber, timeForMove];
}

class Failure extends GameSettingsState {
  final String message;

  Failure(this.message, int playersNumber, int timeForMove) : super(playersNumber, timeForMove);

  @override
  List<Object> get props => [message, playersNumber, timeForMove];
}
