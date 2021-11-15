part of 'game_action_cubit.dart';

abstract class GameActionState extends Equatable {
  late final List<Tile> tiles;
  List<Object> get props => [tiles];
}

class GameActionInitial extends GameActionState {
  GameActionInitial(List<Tile> tiles) {
    this.tiles = tiles;
  }
}

class TilesLoaded extends GameActionState {
  TilesLoaded(List<Tile> tiles) {
    this.tiles = tiles;
  }
}

class Failure extends GameActionState {
  final String message;
  Failure(List<Tile> tiles, this.message) {
    this.tiles = tiles;
  }
  List<Object> get props => [tiles, message];
}
