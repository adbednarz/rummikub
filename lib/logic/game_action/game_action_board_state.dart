part of 'game_action_board_cubit.dart';

@immutable
abstract class GameActionBoardState extends Equatable {
  final List<TilesSet> sets;

  GameActionBoardState(this.sets);

  List<Object> get props => [sets];

}

class GameActionBoardInitial extends GameActionBoardState {
  GameActionBoardInitial() : super([]);
}

class BoardChanged extends GameActionBoardState {
  BoardChanged(List<TilesSet> sets) : super(sets);
}
