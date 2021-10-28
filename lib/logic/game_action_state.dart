part of 'game_action_cubit.dart';

abstract class GameActionState extends Equatable {
  const GameActionState();
}

class GameActionInitial extends GameActionState {
  @override
  List<Object> get props => [];
}
