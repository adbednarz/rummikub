import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final bool currentTurn;
  final String name;

  Player(this.currentTurn, this.name);

  Player.fromDocument(DocumentSnapshot document): this(
    document['currentTurn'],
    document['name'],
  );

}