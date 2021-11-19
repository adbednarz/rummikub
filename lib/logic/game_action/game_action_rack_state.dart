part of 'game_action_rack_cubit.dart';

@immutable
abstract class GameActionRackState extends Equatable {
  final List<Tile?> rack;

  GameActionRackState(this.rack);

  List<Object> get props => [rack];

}

class GameActionRackInitial extends GameActionRackState {
  GameActionRackInitial() : super([]);
}

class RackChanged extends GameActionRackState {
  RackChanged(List<Tile?> rack) : super(rack);
}
