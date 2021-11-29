part of 'game_action_panel_cubit.dart';

@immutable
abstract class GameActionPanelState extends Equatable {
  final List<Player> players;
  final int procent;

  GameActionPanelState(this.players, this.procent);

  @override
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

class MissedTurn extends GameActionPanelState {
  MissedTurn(List<Player> players, int procent) : super(players, procent);
}

class GameCancelled extends GameActionPanelState {
  final String message = 'The game left the last player.';

  GameCancelled(List<Player> players, int procent) : super(players, procent);

  @override
  List<Object> get props => [players, procent, message];
}

class GameFinished extends GameActionPanelState {
  late final String message;

  GameFinished(List<Player> players, int procent, List<String> winners) : super(players, procent) {
    if (winners.length == 1) {
      message = 'The winner is ' + winners[0];
    } else {
      var tmp = 'The winners are';
      for (var playerName in winners) {
        tmp += ' ' + playerName;
      }
      message = tmp;
    }
  }

  @override
  List<Object> get props => [players, procent, message];
}

class GameAbandoned extends GameActionPanelState {
  GameAbandoned() : super([], 0);
}
