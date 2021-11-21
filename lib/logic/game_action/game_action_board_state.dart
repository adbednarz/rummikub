part of 'game_action_board_cubit.dart';

@immutable
abstract class GameActionBoardState extends Equatable {
  final List<List<Tile?>> board;

  GameActionBoardState(this.board);

  List<Object> get props => [board];

}

class GameActionBoardInitial extends GameActionBoardState {
  GameActionBoardInitial() : super(List.filled(140, [null])) {
    this.board[0] = [Tile("blue", 0, false)];
  }
}

class BoardChanged extends GameActionBoardState {
  BoardChanged(List<List<Tile?>> board) : super(board);
}
