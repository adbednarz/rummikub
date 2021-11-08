import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:rummikub/shared/custom_exception.dart';

class FunctionsProvider {
  FirebaseFunctions _functions = FirebaseFunctions.instance;

  FunctionsProvider() {
    String localhost = kIsWeb ? 'localhost' : '156.17.235.49';
    _functions.useFunctionsEmulator(localhost, 5001);
  }

  Future<String> searchGame(int playersNumber) async {
    try {
      final results = await _functions.httpsCallable('searchGame').call({"playersNumber": playersNumber});
      return results.data['gameId'];
    } catch(error) {
      print(error);
      throw new CustomException("Error occurred");
    }
  }
}