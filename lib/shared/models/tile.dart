import 'package:cloud_firestore/cloud_firestore.dart';

class Tile {
  final String color;
  final int number;
  final bool isMine;
  late final isJoker = number == 0;

  Tile(this.color, this.number, this.isMine);

  Tile.fromDocument(DocumentSnapshot document, bool isMine): this(
    document['color'],
    document['number'],
    isMine
  );

  @override
  bool operator == (other) {
    return (other is Tile) && other.color == color && other.number == number;
  }

  Map<String, dynamic> asMap() => {'color' : color, 'number' : number};

  bool isEqual(Tile tile) {
    return color == tile.color && number == tile.number && isMine == tile.isMine;
  }
}