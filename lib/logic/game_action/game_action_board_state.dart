part of 'game_action_board_cubit.dart';

@immutable
abstract class GameActionBoardState extends Equatable {
  final List<Tile?> board;

  GameActionBoardState(this.board);

  List<Object> get props => [board];

}

class GameActionBoardInitial extends GameActionBoardState {
  GameActionBoardInitial() : super([]);
}

class BoardChanged extends GameActionBoardState {
  BoardChanged(List<Tile?> board) : super(board);
}
