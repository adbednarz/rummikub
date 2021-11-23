part of 'game_action_board_cubit.dart';

abstract class GameActionBoardState {
  final List<TilesSet> sets;

  GameActionBoardState(this.sets);
}

class GameActionBoardInitial extends GameActionBoardState {
  GameActionBoardInitial() : super([]);
}

class BoardChanged extends GameActionBoardState {
  BoardChanged(List<TilesSet> sets) : super(sets) {
    sets.forEach((element) {
      print(element.tiles.length);
    });
    print('-------');
  }
}
