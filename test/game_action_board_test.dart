import 'package:flutter_test/flutter_test.dart';
import 'package:rummikub/logic/game_action/game_action_board_cubit.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

import 'game_repository_mock.dart';

void main() {
  test('Validation board sets', () {
    final repository = GameRepositoryMock();
    final boardCubit = GameActionBoardCubit(repository, '0', '0');

    var tiles = [
      Tile('black', 10, true),
      Tile('blue', 10, true),
      Tile('orange', 10, true)
    ];
    var set = TilesSet(-1, tiles);
    boardCubit.emit(BoardChanged([set]));
    expect(boardCubit.putTiles(), isTrue);

    boardCubit.initialMeld = true;
    tiles = [
      Tile('black', 5, true),
      Tile('blue', 5, true),
      Tile('orange', 5, true)
    ];
    set = TilesSet(-1, tiles);
    boardCubit.emit(BoardChanged([set]));
    expect(boardCubit.putTiles(), isTrue);
  });
}