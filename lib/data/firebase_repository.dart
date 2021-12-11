import 'package:firebase_auth/firebase_auth.dart';
import 'package:rummikub/data/authentication_provider.dart';
import 'package:rummikub/data/firestore_provider.dart';
import 'package:rummikub/data/functions_provider.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';

class FirebaseRepository implements Repository {
  final AuthenticationProvider _authenticationProvider = AuthenticationProvider();
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  final FunctionsProvider _functionsProvider = FunctionsProvider();

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
  Future<String> searchGame(String playerId, int playersNumber, int timeForMove) async {
    await _firestoreProvider.changeUserActiveStatus(playerId, false);
    return await _functionsProvider.searchGame(playersNumber, timeForMove);
  }

  @override
  Stream<int> getMissingPlayersNumberToStartGame(String gameId) {
    return _firestoreProvider.getMissingPlayersNumberToStartGame(gameId);
  }

  @override
  Stream<List<Tile>> getPlayerTiles(String gameId, String playerId) {
    return _firestoreProvider.getPlayerTiles(gameId, playerId);
  }

  @override
  Stream<List<Player>> getPlayersQueue(String gameId) {
    return _firestoreProvider.getPlayersQueue(gameId);
  }

  @override
  Stream<Map<String, dynamic>> getGameStatus(String gameId) {
    return _firestoreProvider.getGameStatus(gameId);
  }

  @override
  Future<void> putTiles(String gameId, List<TilesSet> tiles) async {
    await _functionsProvider.putTiles(gameId, tiles);
  }

  @override
  Stream<List<TilesSet>> getTilesSets(String gameId) {
    return _firestoreProvider.getTilesSets(gameId);
  }

  @override
  Future<void> leaveGame(String gameId, String playerId, bool isFinished) async {
    if (!isFinished) {
      await _functionsProvider.leftGame(gameId);
    }
    await _firestoreProvider.changeUserActiveStatus(playerId, true);
  }

}