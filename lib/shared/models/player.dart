import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final bool currentTurn;
  final String name;
  final playerId;

  Player(this.currentTurn, this.name, this.playerId);

  Player.fromDocument(DocumentSnapshot document): this(
    document['currentTurn'],
    document['name'],
    document.id
  );

}