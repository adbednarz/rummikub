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
    return await _authenticationProvider.signUp(email: email, username: username, password: password);
  }

  Future<User> logIn({required String email, required String password}) async {
      return await _authenticationProvider.logIn(email: email, password: password);
  }

  Future<void> logOut() async {
    _authenticationProvider.logOut();
  }
}