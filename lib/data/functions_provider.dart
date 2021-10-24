import 'package:cloud_functions/cloud_functions.dart';

class FunctionsProvider {
  FirebaseFunctions functions = FirebaseFunctions.instance;

  Future<void> tmp() async {
    HttpsCallable  callable = functions.httpsCallable('tmp');
    final results = await callable();
    List tmp = results.data;
  }
}