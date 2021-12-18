import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/game_repository.dart';
import 'package:rummikub/shared/models/tile.dart';

part 'game_action_rack_state.dart';

class GameActionRackCubit extends Cubit<GameActionRackState> {
  final GameRepository _repository;
  final String gameId;
  final String playerId;
  late StreamSubscription playerTitlesListener;
  late List<Tile?> rackBeforeModification;

  GameActionRackCubit(this._repository, this.gameId, this.playerId) : super(GameActionRackInitial()) {
    playerTitlesListener = _repository.playerTiles(gameId, playerId).listen((result) {
      var rack = List<Tile?>.from(state.rack);
      _addTilesToRack(rack, result);
      rackBeforeModification = List.from(rack);
      emit(RackChanged(rack));
    });
  }

  void changeRack(int index, Tile? tile) {
    var rack = List<Tile?>.from(state.rack);
    rack[index] = tile;
    emit(RackChanged(rack));
  }

  void confirmRackModifications() {
    rackBeforeModification = List.from(state.rack);
  }

  void restorePreviousRack() {
    emit(RackChanged(List.from(rackBeforeModification)));
  }

  void _addTilesToRack(List<Tile?> rack, List<Tile> result) {
    var counter = 0;
    for (var i = 0; i < rack.length; i++) {
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
  }

  @override
  Future<void> close() async {
    await playerTitlesListener.cancel();
    await super.close();
  }
}
