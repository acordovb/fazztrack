import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _localKey = 'selected_local';
  static late SharedPreferences _prefs;

  // Método de inicialización para evitar MissingPluginException
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Guardar el local seleccionado
  static Future<bool> saveSelectedLocal(String local) async {
    return _prefs.setString(_localKey, local);
  }

  // Obtener el local seleccionado
  static Future<String?> getSelectedLocal() async {
    return _prefs.getString(_localKey);
  }

  // Verificar si ya existe un local seleccionado
  static Future<bool> hasSelectedLocal() async {
    return _prefs.containsKey(_localKey);
  }
}
