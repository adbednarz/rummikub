import 'package:firebase_auth/firebase_auth.dart';
import 'package:rummikub/data/authentication_provider.dart';
import 'package:rummikub/data/firestore_provider.dart';
import 'package:rummikub/data/functions_provider.dart';
import 'package:rummikub/data/repository.dart';

class FirebaseRepository implements Repository {
  final AuthenticationProvider _authenticationProvider = AuthenticationProvider();
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  final FunctionsProvider _functionsProvider = FunctionsProvider();

  @override
  Future<User> signUp({required String email, required String username, required String password}) async {
    await _firestoreProvider.checkUniqueness(username);
    User user = await _authenticationProvider.signUp(email: email, username: username, password: password);
    _firestoreProvider.addUserData(username, user.uid);
    return user;
  }

  @override
  Future<User> logIn({required String email, required String password}) async {
      User user = await _authenticationProvider.logIn(email: email, password: password);
      _firestoreProvider.changeUserActiveStatus(user.uid, true);
      return user;
  }

  @override
  Future<void> logOut({required String playerId}) async {
    _authenticationProvider.logOut();
    _firestoreProvider.changeUserActiveStatus(playerId, false);
  }

  @override
  Future<String> searchGame(String playerId, int playersNumber) async {
    await _firestoreProvider.changeUserActiveStatus(playerId, false);
    return await _functionsProvider.searchGame(playersNumber);
  }

  @override
  Stream<int> getMissingPlayersNumberToStartGame(String gameId) {
    return _firestoreProvider.getMissingPlayersNumberToStartGame(gameId);
  }

  @override
  Stream<List<Map<String, int>>> getPlayerTiles(String gameId, String playerId) {
    return _firestoreProvider.getPlayerTiles(gameId, playerId);
  }

  @override
  Future<void> putTiles(String gameId) async {
    await _functionsProvider.putTiles(gameId);
  }
}