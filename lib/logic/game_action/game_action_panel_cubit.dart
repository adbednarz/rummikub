import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/models/player.dart';

part 'game_action_panel_state.dart';

class GameActionPanelCubit extends Cubit<GameActionPanelState> {
  final Repository _firebaseRepository;
  late final String playerId;
  late final String gameId;
  late final StreamSubscription playersQueue;
  late final StreamSubscription gameStatus;
  int? timeForMove;
  String? currentTurn;
  Timer? _timer;

  GameActionPanelCubit(this._firebaseRepository, Map<String, String> params) : super(GameActionPanelInitial()) {
    gameId = params['gameId']!;
    playerId = params['playerId']!;
    playersQueue = _firebaseRepository.getPlayersQueue(gameId).listen((result) {
      _changePanel(result);
    });
    gameStatus = _firebaseRepository.getGameStatus(gameId).listen((result) {
      if (result['winner'] != null) {
        var winners = <String>[...result['winner']];
        var players = List<Player>.from(state.players);
        players.removeWhere((player) => !winners.contains(player.playerId));
        emit(GameFinished(state.players, state.procent, players.map((player) => player.name).toList()));
      } else {
        currentTurn = result['currentTurn'];
        timeForMove ??= result['timeForMove'];
        _changeTurn(timeForMove!);
      }
    });
  }

  void _changePanel(List<Player> players) {
    if (players.length == 1) {
      leaveGame();
    } else if (state.players.length > players.length) {
      var removedPlayer = state.players.where((e) => !players.contains(e)).first;
      emit(PanelInfo(players, state.procent, 'Player ' + removedPlayer.name + ' left the game.'));
    } else if (players.length != state.players.length) {
      emit(CurrentPlayersQueue(players, state.procent));
    }
  }

  void _changeTurn(int timeForMove) {
    _timer?.cancel();
    emit(CurrentPlayersQueue(state.players, timeForMove));
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick > timeForMove) {
        timer.cancel();
        if(isMyTurn()) {
          emit(MissedTurn(state.players, 0));
        }
      } else {
        emit(CurrentPlayersQueue(state.players, timer.tick > timeForMove ? 0 : timeForMove - timer.tick));
      }
    });
  }

  void tilesWasPut() {
    currentTurn = '';
    _timer?.cancel();
    emit(CurrentPlayersQueue(state.players, 0));
  }

  bool isMyTurn() {
    return playerId == currentTurn;
  }

  void leaveGameBeforeEnd() {
    _firebaseRepository.leaveGame(gameId, playerId, false);
    emit(GameAbandoned());
  }

  void leaveGame() {
    _firebaseRepository.leaveGame(gameId, playerId, true);
    emit(GameCancelled(state.players, state.procent));
  }

  @override
  Future<void> close() async {
    await playersQueue.cancel();
    await gameStatus.cancel();
    await super.close();
  }

}
