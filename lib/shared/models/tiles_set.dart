import 'package:rummikub/shared/models/tile.dart';

class TilesSet {
  int position;
  List<Tile> tiles;

  TilesSet(this.position, this.tiles);

  TilesSet copy() {
    return TilesSet(position, List.from(tiles));
  }
}