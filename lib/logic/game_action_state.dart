part of 'game_action_cubit.dart';

abstract class GameActionState extends Equatable {
  late final List<Map<String, int>> tiles;
  List<Object> get props => [tiles];
}

class GameActionInitial extends GameActionState {
  GameActionInitial(List<Map<String, int>> tiles) {
    this.tiles = tiles;
  }
}

class TilesLoaded extends GameActionState {
  TilesLoaded(List<Map<String, int>> tiles) {
    this.tiles = tiles;
  }
}