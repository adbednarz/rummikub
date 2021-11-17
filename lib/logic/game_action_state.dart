part of 'game_action_cubit.dart';

abstract class GameActionState extends Equatable {
  late final List<Tile?> rack;
  late final List<Tile?> board;
  List<Object> get props => [rack];
}

class GameActionInitial extends GameActionState {
  GameActionInitial() {
    this.rack = [];
    this.board = List.filled(140, null);
  }
}

class RackChanged extends GameActionState {
  RackChanged(List<Tile?> playerRack, List<Tile> tiles, List<Tile?> board) {
    this.rack = List.from(playerRack);
    this.board = board;
    int counter = 0;
    for (int i = 0; i < this.rack.length; i++) {
      if (counter == tiles.length) {
        break;
      }
      if (this.rack[i] == null) {
        this.rack[i] = tiles[counter];
        counter++;
      }
    }
    while(counter < tiles.length) {
      this.rack.add(tiles[counter]);
      counter++;
    }
    while(this.rack.length < 14 || this.rack.length % 2 != 0) {
      this.rack.add(null);
    }
  }
}

class BoardChanged extends GameActionState {
  BoardChanged(List<Tile?> rack, List<Tile?> board) {
    this.rack = List.from(rack);
    this.board = List.from(board);
  }
}

class Failure extends GameActionState {
  final String message;
  Failure(List<Tile?> track, this.message) {
    this.rack = track;
  }

  @override
  List<Object> get props => [rack, message];
}
