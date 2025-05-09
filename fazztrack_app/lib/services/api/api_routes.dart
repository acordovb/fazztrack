import 'package:fazztrack_app/config/build.config.dart';

class API {
  static final String baseUrl = DeployConfig.baseUrl;
  static const String getUser = '/user';
  static const String getAllUsers = '/users';
  static const String getAllProducts = '/products';
  static const String getAllTransactions = '/transactions';
}
