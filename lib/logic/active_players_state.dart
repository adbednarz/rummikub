part of 'active_players_cubit.dart';

@immutable
abstract class ActivePlayersState {
  final List<String> activePlayers;
  final List<String> selectedPlayers;

  ActivePlayersState(this.activePlayers, this.selectedPlayers);
}

class ActivePlayersInitial extends ActivePlayersState {
  ActivePlayersInitial() : super([], []);
}

class ActivePlayersChanged extends ActivePlayersState {
  ActivePlayersChanged(List<String> activePlayers, List<String> selectedPlayers)
      : super(activePlayers, selectedPlayers);
}

class Message extends ActivePlayersState {
  final String message;

  Message(this.message, List<String> activePlayers, List<String> selectedPlayers)
      : super(activePlayers, selectedPlayers);

}