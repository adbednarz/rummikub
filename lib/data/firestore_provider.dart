import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rummikub/shared/custom_exception.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        .catchError((onError) => throw new CustomException('Error while adding user data'));
  }

  Future<void> changeUserActiveStatus(String userID, bool isActive) async {
    _firestore.collection('users')
        .doc(userID)
        .update({'active': isActive})
        .catchError((onError) => throw new CustomException('Error while adding user data'));
  }

}