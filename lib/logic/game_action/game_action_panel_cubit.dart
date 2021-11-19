import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/models/player.dart';

part 'game_action_panel_state.dart';

class GameActionPanelCubit extends Cubit<GameActionPanelState> {
  final Repository _firebaseRepository;
  final gameId;
  bool initialMeld = false;
  late final StreamSubscription playersQueue;
  Timer? _timer;

  GameActionPanelCubit(this._firebaseRepository, this.gameId) : super(GameActionPanelInitial()) {
    playersQueue = _firebaseRepository.getPlayersQueue(gameId).listen((result) {
      this._changePanel(result);
    });
  }

  _changePanel(List<Player> players) {
    if (players.length == 0) {
      emit(GameCancelled());
    } else if (state.players.length > players.length) {
      Player removedPlayer = state.players.where((e) => !players.contains(e)).first;
      emit(PanelInfo(players, state.procent, "Player " + removedPlayer.name + " left the game."));
    } else {
      this._timer?.cancel();
      emit(CurrentPlayersQueue(players, 60));
      this._timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        if (timer.tick > 60) {
          emit(PanelInfo(state.players, 0, "Your tour is missed."));
          timer.cancel();
        } else {
          emit(CurrentPlayersQueue(state.players, timer.tick > 60 ? 0 : 60 - timer.tick));
        }
      });
    }
  }

  @override
  Future<void> close() async {
    playersQueue.cancel();
    super.close();
  }

}
