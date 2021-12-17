import 'package:rummikub/data/auth_repository.dart';
import 'package:rummikub/data/firebase/authentication_provider.dart';
import 'package:rummikub/data/firebase/firestore_provider.dart';
import 'package:rummikub/shared/models/player.dart';

class AuthFirebase implements AuthRepository  {
  final AuthenticationProvider _authenticationProvider = AuthenticationProvider();
  final FirestoreProvider _firestoreProvider;

  AuthFirebase(this._firestoreProvider);

  @override
  Future<Player> signUp(String email, String username, String password) async {
    await _firestoreProvider.checkUniqueness(username);
    var user = await _authenticationProvider.signUp(email, username, password);
    await _firestoreProvider.addUserData(username, user.uid);
    return Player(user.displayName ?? user.uid, user.uid);
  }

  @override
  Future<Player> logIn(String email, String password) async {
    var user = await _authenticationProvider.logIn(email, password);
    await _firestoreProvider.changeUserActiveStatus(user.uid, true);
    return Player(user.displayName ?? user.uid, user.uid);
  }

  @override
  Future<void> logOut(String playerId) async {
    await _authenticationProvider.logOut();
    await _firestoreProvider.changeUserActiveStatus(playerId, false);
  }

  @override
  Stream<Map<String, String>> invitationToGame(String playerId) {
    return _firestoreProvider.getUserDocumentChanges(playerId);
  }

  @override
  Stream<List<String>> activePlayers(String playerId) {
    return _firestoreProvider.getActivePlayers(playerId);
  }

}