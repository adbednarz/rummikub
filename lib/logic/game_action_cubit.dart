import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';
import 'package:rummikub/shared/models/tile.dart';

part 'game_action_state.dart';

class GameActionCubit extends Cubit<GameActionState> {
  final Repository _firebaseRepository;
  late String gameId;
  late String playerId;
  late StreamSubscription playerTitlesSubscription;

  GameActionCubit(this._firebaseRepository, Map<String, String> params) : super(GameActionInitial([])) {
    gameId = params['gameId']!;
    playerId = params['playerId']!;
    playerTitlesSubscription = _firebaseRepository.getPlayerTiles(gameId, playerId).listen((result) {
      result.forEach((element) {
        print(element.color);
        print(element.number);
      });
      emit(TilesLoaded(state.tiles + result));
    });
  }

  Future<void> putTiles() async {
    List<List<Tile>> tiles = [[Tile("orange", 7), Tile("black", 11), Tile("red", 11)], [Tile("red", 9)]];
    try {
      _firebaseRepository.putTiles(gameId, tiles);
    } on CustomException catch(error) {
      emit(Failure(state.tiles, error.cause));
    }
  }

  @override
  Future<void> close() async {
    playerTitlesSubscription.cancel();
    super.close();
  }
}
