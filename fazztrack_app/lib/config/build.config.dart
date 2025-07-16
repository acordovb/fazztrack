import 'package:fazztrack_app/config/general.config.dart';
import 'package:fazztrack_app/config/env.config.dart';

class BuildConfig {
  static final String appLevel = AppConfig.appLevel.admin;

  // Obtener la URL base desde variables de entorno o archivo local
  static final String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: EnvConfig.baseUrl, // Usa la URL del archivo de entorno
  );
}
