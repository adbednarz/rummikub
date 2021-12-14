import 'package:firebase_auth/firebase_auth.dart';
import 'package:rummikub/data/auth_repository.dart';
import 'package:rummikub/data/firebase/authentication_provider.dart';
import 'package:rummikub/data/firebase/firestore_provider.dart';
import 'package:rummikub/data/firebase/functions_provider.dart';

class AuthFirebase implements AuthRepository  {
  final AuthenticationProvider _authenticationProvider = AuthenticationProvider();
  final FirestoreProvider _firestoreProvider = FirestoreProvider();

  @override
  Future<User> signUp(String email, String username, String password) async {
    await _firestoreProvider.checkUniqueness(username);
    var user = await _authenticationProvider.signUp(email: email, username: username, password: password);
    await _firestoreProvider.addUserData(username, user.uid);
    return user;
  }

  @override
  Future<User> logIn(String email, String password) async {
    var user = await _authenticationProvider.logIn(email: email, password: password);
    await _firestoreProvider.changeUserActiveStatus(user.uid, true);
    return user;
  }

  @override
  Future<void> logOut(String playerId) async {
    await _authenticationProvider.logOut();
    await _firestoreProvider.changeUserActiveStatus(playerId, false);
  }

  @override
  Stream<Map<String, String>> getUserDocumentChanges(String playerId) {
    return _firestoreProvider.getUserDocumentChanges(playerId);
  }

  @override
  Stream<List<String>> getActivePlayers(String playerId) {
    return _firestoreProvider.getActivePlayers(playerId);
  }

}