import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'game_action_state.dart';

class GameActionCubit extends Cubit<GameActionState> {
  GameActionCubit() : super(GameActionInitial());
}
