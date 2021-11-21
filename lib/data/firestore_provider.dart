import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rummikub/shared/custom_exception.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  FirestoreProvider() {
    String localhost = kIsWeb ? 'localhost' : '192.168.198.172';
    _firestore.useFirestoreEmulator(localhost, 8080);
  }

  Future<void> checkUniqueness(String nickname) async {
    QuerySnapshot querySnapshot = await _firestore.collection('users')
        .where('name', isEqualTo: nickname)
        .get();
    if (querySnapshot.size != 0)
            throw new CustomException('The nickname is already in use by another account.');
  }

  Future<void> addUserData(String nickname, String playerId) async {
    _firestore.collection('users')
        .doc(playerId)
        .set({'name': nickname, 'active': true})
        .catchError((error) {
          print(error);
          throw new CustomException('Error occurred');
        });
  }

  Future<void> changeUserActiveStatus(String playerId, bool isActive) async {
    _firestore.collection('users')
        .doc(playerId)
        .update({'active': isActive})
        .catchError((error) {
          print(error);
          throw new CustomException('Error occurred');
        });
  }

  Stream<int> getMissingPlayersNumberToStartGame(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots()
              .map((snapshots) => snapshots.get('available'));
  }

  Stream<List<Player>> getPlayersQueue(String gameId) {
    return _firestore.collection('games/' + gameId + '/playersQueue').snapshots()
        .map((snapshots) {
          return snapshots.docs.map((doc) => Player.fromDocument(doc)).toList();
        });
  }

  Stream<List<Tile>> getPlayerTiles(String gameId, String playerId) {
    return _firestore.collection('games/' + gameId + '/playersRacks/' + playerId + '/rack').snapshots()
        .map((snapshots) {
          List<DocumentChange> docChanges = snapshots.docChanges;
          docChanges.removeWhere((element) => element.type == DocumentChangeType.removed);
          return docChanges.map((snapshot) => Tile.fromDocument(snapshot.doc, true)).toList();
        });
  }

  /*Stream<List<List<Tile>>> getBoardSets(String gameId, String playerId) {
    return _firestore.collection('games/' + gameId + '/board/').snapshots()
        .map((snapshots) {
      List<DocumentChange> docChanges = snapshots.docChanges;
      docChanges.removeWhere((element) => element.type == DocumentChangeType.removed);
      return docChanges.map((snapshot) => Tile.fromDocument(snapshot.doc, true)).toList();
    });
  }*/

}