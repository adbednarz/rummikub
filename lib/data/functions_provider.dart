import 'package:cloud_functions/cloud_functions.dart';
import 'package:rummikub/shared/custom_exception.dart';

class FunctionsProvider {
  FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> searchGame(int playersNumber) async {
    try {
      final results = await _functions.httpsCallable('searchGame').call({"playersNumber": playersNumber});
      print(results.data);
      return results.data['gameID'];
    } catch(error) {
      print(error);
      throw new CustomException("Error occurred");
    }
  }
}