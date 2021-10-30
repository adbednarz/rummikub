import 'dart:io' show Platform;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:rummikub/shared/custom_exception.dart';

class FunctionsProvider {
  FirebaseFunctions _functions = FirebaseFunctions.instance;

  FunctionsProvider() {
    String localhost = Platform.isAndroid ? '192.168.8.104' : 'localhost';
    _functions.useFunctionsEmulator(localhost, 5001);
  }

  Future<String> searchGame(int playersNumber) async {
    try {
      final results = await _functions.httpsCallable('searchGame').call({"playersNumber": playersNumber});
      return results.data['gameID'];
    } catch(error) {
      print(error);
      throw new CustomException("Error occurred");
    }
  }
}