import 'package:cloud_firestore/cloud_firestore.dart';

class Tile {
  final String color;
  final int number;

  Tile(this.color, this.number);

  Tile.fromDocument(DocumentSnapshot document): this(
    document['color'],
    document['number'],
  );

  Map<String, dynamic> asMap() => {'color' : color, 'number' : number};
}