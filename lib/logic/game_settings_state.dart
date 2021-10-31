part of 'game_settings_cubit.dart';

abstract class GameSettingsState {}

class GameSettingsInitial extends GameSettingsState {}

class Loading extends GameSettingsState {}

class Waiting extends GameSettingsState {
  Waiting(this.missingPlayersNumber);

  String missingPlayersNumber;

  List<Object> get props => [missingPlayersNumber];
}

class GameFound extends GameSettingsState {}

class Failure extends GameSettingsState {
  Failure(this.errorMessage);

  final String errorMessage;

  List<Object> get props => [errorMessage];
}
