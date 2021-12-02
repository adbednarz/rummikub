import 'package:flutter/foundation.dart';
import 'package:rummikub/shared/models/tile.dart';

class TilesSet {
  int position;
  List<Tile> tiles;

  TilesSet(this.position, this.tiles);

  TilesSet copy() {
    return TilesSet(position, List.from(tiles));
  }

  @override
  bool operator == (other) {
    return (other is TilesSet) && other.position == position && listEquals(other.tiles, tiles);
  }
}