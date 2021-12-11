part of 'active_players_cubit.dart';

@immutable
abstract class ActivePlayersState {
  final List<String> activePlayers;

  ActivePlayersState(this.activePlayers);
}

class ActivePlayersInitial extends ActivePlayersState {
  ActivePlayersInitial() : super([]);
}

class ActivePlayersChanged extends ActivePlayersState {
  ActivePlayersChanged(List<String> activePlayers) : super(activePlayers);
}

class Message extends ActivePlayersState {
  final String message;

  Message(this.message, List<String> activePlayers) : super(activePlayers);

}