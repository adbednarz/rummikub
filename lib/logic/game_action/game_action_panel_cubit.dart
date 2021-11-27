import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/models/player.dart';

part 'game_action_panel_state.dart';

class GameActionPanelCubit extends Cubit<GameActionPanelState> {
  final Repository _firebaseRepository;
  late final playerId;
  late final gameId;
  late String currentTurn;
  late final StreamSubscription playersQueue;
  late final StreamSubscription currentTurnPlayerId;
  Timer? _timer;

  GameActionPanelCubit(this._firebaseRepository, Map<String, String> params) : super(GameActionPanelInitial()) {
    gameId = params['gameId']!;
    playerId = params['playerId']!;
    playersQueue = _firebaseRepository.getPlayersQueue(gameId).listen((result) {
      this._changePanel(result);
    });
    currentTurnPlayerId = _firebaseRepository.getGameStatus(gameId).listen((result) {
      if (result['winner'] != null) {
        List<String> winners = result['winner'];
        List<Player> players = state.players;
        players.removeWhere((player) => winners.contains(player.playerId));
        emit(GameFinished(state.players, state.procent, players.map((player) => player.name).toList()));
      } else {
        print(result['currentTurn']);
        this.currentTurn = result['currentTurn'];
        this._changeTurn();
      }
    });
  }

  _changePanel(List<Player> players) {
    if (players.length == 1) {
      emit(GameCancelled(players, state.procent));
    } else if (state.players.length > players.length) {
      Player removedPlayer = state.players.where((e) => !players.contains(e)).first;
      emit(PanelInfo(players, state.procent, 'Player ' + removedPlayer.name + ' left the game.'));
    } else if (players.length != state.players.length) {
      emit(CurrentPlayersQueue(players, state.procent));
    }
  }

  _changeTurn() {
    this._timer?.cancel();
    emit(CurrentPlayersQueue(state.players, 60));
    this._timer = Timer.periodic(new Duration(seconds: 1), (timer) {
      if (timer.tick > 60) {
        timer.cancel();
        if(isMyTurn()) {
          emit(PanelInfo(state.players, 0, 'Your turn is missed.'));
        }
      } else {
        emit(CurrentPlayersQueue(state.players, timer.tick > 60 ? 0 : 60 - timer.tick));
      }
    });
  }

  tilesWasPut() {
    // this.currentTurn = "";
    this._timer?.cancel();
    emit(CurrentPlayersQueue(state.players, 0));
  }

  isMyTurn() {
    return playerId == currentTurn;
  }

  @override
  Future<void> close() async {
    playersQueue.cancel();
    currentTurnPlayerId.cancel();
    super.close();
  }

}
