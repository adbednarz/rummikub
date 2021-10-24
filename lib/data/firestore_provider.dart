import 'package:rummikub/shared/custom_exception.dart';

class FirestoreProvider {
  //final Firestore _firestore = Firestore.instance;

  Future<void> checkUniqueness(String nickname) async {
    if (false) {
      throw new CustomException("The nickname is already in use by another account.");
    }
  }
}