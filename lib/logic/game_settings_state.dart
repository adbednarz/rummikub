part of 'game_settings_cubit.dart';

@immutable
abstract class GameSettingsState {}

class GameSettingsInitial extends GameSettingsState {}

class Loading extends GameSettingsState {}

class Waiting extends GameSettingsState {}

class GameFound extends GameSettingsState {}

class Failure extends GameSettingsState {
  Failure(this.errorMessage);

  final String errorMessage;

  List<Object> get props => [errorMessage];
}
