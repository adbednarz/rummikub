import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rummikub/shared/custom_exception.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // FirestoreProvider() {
  //   var localhost = kIsWeb ? 'localhost' : '192.168.8.104';
  //   _firestore.useFirestoreEmulator(localhost, 8080);
  // }

  Future<void> checkUniqueness(String nickname) async {
    QuerySnapshot querySnapshot = await _firestore.collection('users')
        .where('name', isEqualTo: nickname)
        .get();
    if (querySnapshot.size != 0) {
      throw CustomException('The nickname is already in use by another account.');
    }
  }

  Future<void> addUserData(String nickname, String playerId) async {
    await _firestore.collection('users')
        .doc(playerId)
        .set({'name': nickname, 'active': true})
        .catchError((error) {
          print(error);
          throw CustomException('Error occurred');
        });
  }

  Future<void> changeUserActiveStatus(String playerId, bool isActive) async {
    await _firestore.collection('users')
        .doc(playerId)
        .update({'active': isActive})
        .catchError((error) {
          print(error);
          throw CustomException('Error occurred');
        });
  }

  Stream<Map<String, String>> getUserDocumentChanges(String playerId) {
    return _firestore.collection('users').doc(playerId).snapshots()
        .map((snapshots) {
          if (snapshots.data()!.containsKey('invitation')) {
            var snap = snapshots.get('invitation');
            return {'gameId': snap['gameId'], 'player': snap['player']};
          } else {
            return {};
          }
        });
  }

  Stream<List<String>> getActivePlayers(String playerId) {
    return _firestore.collection('users')
        .where('active', isEqualTo: true)
        .where(FieldPath.documentId, isNotEqualTo: playerId).snapshots()
        .map((snapshots) {
          return snapshots.docs.map((doc) => doc.get('name').toString()).toList();
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

  Stream<Map<String, dynamic>> getGameStatus(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots()
        .map((snapshots) {
          if (snapshots.data()!.containsKey('winner')) {
            return {'winner': snapshots.get('winner')};
          }
          return {
            'currentTurn': snapshots.get('currentTurn'),
            'timeForMove': snapshots.get('timeForMove')
          };
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

  Stream<List<TilesSet>> getTilesSets(String gameId) {
    return _firestore.collection('games/' + gameId + '/state').doc('sets').snapshots()
        .map((snapshots) {
          var sets = <TilesSet>[];
          if (snapshots.data() != null) {
            snapshots.data()!.forEach((key, value) {
              var tiles = <Tile>[];
              value.forEach((tile) {
                tiles.add(Tile(tile['color'], tile['number'], false));
              });
              sets.add(TilesSet(int.parse(key), tiles));
            });
          }
          sets.sort((a, b) => a.position.compareTo(b.position));
          return sets;
        });
  }

}