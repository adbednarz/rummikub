import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/models/tile.dart';

part 'game_action_rack_state.dart';

class GameActionRackCubit extends Cubit<GameActionRackState> {
  final Repository _firebaseRepository;
  late String gameId;
  late String playerId;
  late StreamSubscription playerTitlesSubscription;

  GameActionRackCubit(this._firebaseRepository, Map<String, String> params) : super(GameActionRackInitial()) {
    gameId = params['gameId']!;
    playerId = params['playerId']!;
    playerTitlesSubscription = _firebaseRepository.getPlayerTiles(gameId, playerId).listen((result) {
      List<Tile?> rack = List.from(state.rack);
      int counter = 0;
      for (int i = 0; i < rack.length; i++) {
        if (counter == result.length) {
          break;
        }
        if (rack[i] == null) {
          rack[i] = result[counter];
          counter++;
        }
      }
      while(counter < result.length) {
        rack.add(result[counter]);
        counter++;
      }
      if (rack.length % 2 != 0) {
        rack.add(null);
      }
      emit(RackChanged(rack));
    });
  }

  changeRack(int index, Tile? tile) {
    List<Tile?> rack = List.from(state.rack);
    rack[index] = tile;
    emit(RackChanged(rack));
  }

  @override
  Future<void> close() async {
    playerTitlesSubscription.cancel();
    super.close();
  }
}
