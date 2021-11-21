import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/models/tile.dart';

part 'game_action_board_state.dart';

class GameActionBoardCubit extends Cubit<GameActionBoardState> {
  final Repository _firebaseRepository;
  late String gameId;
  late String playerId;
  late StreamSubscription playerTitlesSubscription;
  List<int> setsIndexes = [];

  GameActionBoardCubit(this._firebaseRepository, Map<String, String> params) : super(GameActionBoardInitial()) {
    gameId = params['gameId']!;
    playerId = params['playerId']!;
    playerTitlesSubscription = _firebaseRepository.getPlayerTiles(gameId, playerId).listen((result) {

    });
  }

  removeTile(int i, int j) {

  }

  addTile(int i, Tile tile) {
    List<List<Tile?>> board = List.from(state.board);
    if (i > 0 && i-1 < board.length) {
      if (board[i-1] == [null] && board[i+1] == [null]) {
        
      }
    }

    board[i] = [tile];
    emit(BoardChanged(board));
  }

  @override
  Future<void> close() async {
    playerTitlesSubscription.cancel();
    super.close();
  }
}
