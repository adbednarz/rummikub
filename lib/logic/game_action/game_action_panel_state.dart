part of 'game_action_panel_cubit.dart';

@immutable
abstract class GameActionPanelState extends Equatable {
  final List<Player> players;
  final int procent;

  GameActionPanelState(this.players, this.procent);

  List<Object> get props => [players, procent];

}

class GameActionPanelInitial extends GameActionPanelState {
  GameActionPanelInitial() : super([], 0);
}

class CurrentPlayersQueue extends GameActionPanelState {
  CurrentPlayersQueue(List<Player> players, int procent) : super(players, procent);
}

class PanelInfo extends GameActionPanelState {
  final String message;
  PanelInfo(List<Player> players, int procent, this.message) : super(players, procent);

  @override
  List<Object> get props => [players, procent, message];
}

class GameCancelled extends GameActionPanelState {
  final String message = "The game left the last player.";

  GameCancelled(List<Player> players, int procent) : super(players, procent);

  @override
  List<Object> get props => [players, procent, message];
}
