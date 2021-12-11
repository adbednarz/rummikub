import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';

part 'active_players_state.dart';

class ActivePlayersCubit extends Cubit<ActivePlayersState> {
  final Repository _repository;
  final String playerId;
  StreamSubscription? getActivePlayers;
  String filter = '';
  List<String> activePlayers = [];
  List<String> selectedPlayers = [];

  ActivePlayersCubit(this._repository, this.playerId) : super(ActivePlayersInitial()) {
    getActivePlayers = _repository.getActivePlayers.listen((change) {
      activePlayers = change;
      if (filter != '') {
        emit(ActivePlayersChanged(
            activePlayers.where((name) => name.toLowerCase().startsWith(filter)).toList()
        ));
      } else {
        emit(ActivePlayersChanged(activePlayers));
      }
    });
  }

  void filtrActivePlayers(String value) {
    filter = value;
    emit(ActivePlayersChanged(
        activePlayers.where((name) => name.toLowerCase().startsWith(filter)).toList()
    ));
  }

  bool addPlayer(String player) {
    if (selectedPlayers.length < 4) {
      selectedPlayers.add(player);
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<void> close() async {
    await getActivePlayers?.cancel();
    await super.close();
  }
}
