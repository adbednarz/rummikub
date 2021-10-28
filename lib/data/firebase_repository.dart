import 'package:firebase_auth/firebase_auth.dart';
import 'package:rummikub/data/authentication_provider.dart';
import 'package:rummikub/data/firestore_provider.dart';
import 'package:rummikub/data/functions_provider.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/shared/custom_exception.dart';

class FirebaseRepository implements Repository {
  final AuthenticationProvider _authenticationProvider = AuthenticationProvider();
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  final FunctionsProvider _functionsProvider = FunctionsProvider();

  Future<User> signUp({required String email, required String username, required String password}) async {
    await _firestoreProvider.checkUniqueness(username);
    User user = await _authenticationProvider.signUp(email: email, username: username, password: password);
    _firestoreProvider.addUserData(username, user.uid);
    return user;
  }

  Future<User> logIn({required String email, required String password}) async {
      User user = await _authenticationProvider.logIn(email: email, password: password);
      _firestoreProvider.changeUserActiveStatus(user.uid, true);
      return user;
  }

  Future<void> logOut({required String userID}) async {
    _authenticationProvider.logOut();
    _firestoreProvider.changeUserActiveStatus(userID, false);
  }
}