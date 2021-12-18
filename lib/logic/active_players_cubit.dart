import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/auth_repository.dart';

part 'active_players_state.dart';

class ActivePlayersCubit extends Cubit<ActivePlayersState> {
  final AuthRepository _repository;
  final String playerId;
  StreamSubscription? activePlayersListener;
  String filter = '';
  List<String> activePlayers = [];

  ActivePlayersCubit(this._repository, this.playerId) : super(ActivePlayersInitial()) {
    activePlayersListener = _repository.activePlayers(playerId).listen((change) {
      activePlayers = change;
      if (filter != '') {
        emit(ActivePlayersChanged(
            activePlayers.where((name) => name.toLowerCase().startsWith(filter)).take(30).toList(),
            state.selectedPlayers
        ));
      } else {
        emit(ActivePlayersChanged(activePlayers, state.selectedPlayers));
      }
    });
  }

  void filtrActivePlayers(String value) {
    filter = value;
    emit(ActivePlayersChanged(
      activePlayers.where((name) => name.toLowerCase().startsWith(filter)).take(30).toList(),
      state.selectedPlayers
    ));
  }

  void addPlayer(String player) {
    var selectedPlayers = state.selectedPlayers;
    if (selectedPlayers.contains(player)) {
      selectedPlayers.remove(player);
      emit(ActivePlayersChanged(state.activePlayers, selectedPlayers));
    } else if (selectedPlayers.length < 4) {
      selectedPlayers.add(player);
      emit(ActivePlayersChanged(state.activePlayers, selectedPlayers));
    }
  }

  @override
  Future<void> close() async {
    await activePlayersListener?.cancel();
    await super.close();
  }
}
