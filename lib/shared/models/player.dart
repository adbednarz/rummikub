import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String name;
  final String playerId;

  Player(this.name, this.playerId);

  Player.fromDocument(DocumentSnapshot document): this(
    document['name'],
    document.id
  );

}