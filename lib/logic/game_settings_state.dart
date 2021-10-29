part of 'game_settings_cubit.dart';

@immutable
abstract class GameSettingsState {}

class GameSettingsInitial extends GameSettingsState {}

class Loading extends GameSettingsState {
  @override
  List<Object> get props => [];
}

class Failure extends GameSettingsState {
  Failure(this.errorMessage);

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}
