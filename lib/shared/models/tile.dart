import 'package:cloud_firestore/cloud_firestore.dart';

class Tile {
  final String color;
  final int number;
  final bool isMine;

  Tile(this.color, this.number, this.isMine);

  Tile.fromDocument(DocumentSnapshot document, bool isMine): this(
    document['color'],
    document['number'],
    isMine
  );

  Map<String, dynamic> asMap() => {'color' : color, 'number' : number};
}