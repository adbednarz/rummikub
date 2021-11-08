import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rummikub/shared/custom_exception.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  FirestoreProvider() {
    String localhost = kIsWeb ? 'localhost' : '156.17.235.49';
    _firestore.useFirestoreEmulator(localhost, 8080);
  }

  Future<void> checkUniqueness(String nickname) async {
    QuerySnapshot querySnapshot = await _firestore.collection('users')
        .where('name', isEqualTo: nickname)
        .get();
    if (querySnapshot.size != 0)
      throw new CustomException('The nickname is already in use by another account.');
  }

  Future<void> addUserData(String nickname, String userID) async {
    _firestore.collection('users')
        .doc(userID)
        .set({'name': nickname, 'active': true})
        .catchError((error) {
          print(error);
          throw new CustomException('Error occurred');
        });
  }

  Future<void> changeUserActiveStatus(String userID, bool isActive) async {
    _firestore.collection('users')
        .doc(userID)
        .update({'active': isActive})
        .catchError((error) {
          print(error);
          throw new CustomException('Error occurred');
        });
  }

  Stream<int> getMissingPlayersNumberToStartGame(String gameID) {
    return _firestore.collection('games').doc(gameID).snapshots().map((snapshot) {
      return snapshot.data()?['size'] - snapshot.data()?['players'].length;
    });
  }

}