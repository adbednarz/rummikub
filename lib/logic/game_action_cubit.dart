import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:rummikub/data/repository.dart';

part 'game_action_state.dart';

class GameActionCubit extends Cubit<GameActionState> {
  final Repository _firebaseRepository;
  late String gameId;
  late String playerId;
  late StreamSubscription playerTitlesSubscription;

  GameActionCubit(this._firebaseRepository, Map<String, String> params) : super(GameActionState()) {
    gameId = params['gameId']!;
    playerId = params['playerId']!;
    playerTitlesSubscription = _firebaseRepository.getPlayerTiles(gameId, playerId).listen((change) {

    });
  }

  @override
  Future<void> close() async {
    playerTitlesSubscription.cancel();
    super.close();
  }
}
