import 'package:rummikub/data/authentication_provider.dart';
import 'package:rummikub/data/firestore_provider.dart';
import 'package:rummikub/data/repository.dart';

class FirebaseRepository implements Repository {
  final AuthenticationProvider _authenticationProvider = AuthenticationProvider();
  final FirestoreProvider _firestoreProvider = FirestoreProvider();

  Future<void> signUp({required String email, required String username, required String password}) =>
    _authenticationProvider.signUp(email: email, username: username, password: password);

  Future<void> logIn({required String email, required String password}) =>
      _authenticationProvider.logIn(email: email, password: password);
}