import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_routes.dart';

class ApiService {
  final String baseUrl;

  ApiService() : baseUrl = API.baseUrl;

  Future<http.Response> get(String path) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.get(url);
      _handleResponse(response);
      return response;
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      throw Exception('PATCH request failed: $e');
    }
  }

  Future<http.Response> delete(String path) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.delete(url);
      _handleResponse(response);
      return response;
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP error: ${response.statusCode} - ${response.body}');
    }
  }
}
