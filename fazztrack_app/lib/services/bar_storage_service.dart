import 'package:shared_preferences/shared_preferences.dart';

class BarStorageService {
  static const String _localKey = 'selected_local';

  static Future<bool> saveSelectedBar(String local) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_localKey, local);
  }

  static Future<String?> getSelectedBar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localKey);
  }

  static Future<bool> hasSelectedBar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_localKey);
  }
}
