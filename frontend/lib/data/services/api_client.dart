import 'package:http/http.dart' as http;

const _baseUrl = 'http://10.0.2.2:5175';

class ApiClient {
  static const String baseUrl = _baseUrl;

  static Future<http.Response> get(String path) =>
      _withRetry(() => http
          .get(Uri.parse('$_baseUrl$path'), headers: _jsonHeaders)
          .timeout(const Duration(seconds: 30)));

  static Future<http.Response> post(String path, String body) =>
      _withRetry(() => http
          .post(Uri.parse('$_baseUrl$path'), headers: _jsonHeaders, body: body)
          .timeout(const Duration(seconds: 30)));

  static Future<http.Response> put(String path, String body) =>
      _withRetry(() => http
          .put(Uri.parse('$_baseUrl$path'), headers: _jsonHeaders, body: body)
          .timeout(const Duration(seconds: 30)));

  static Future<http.Response> patch(String path, String body) =>
      _withRetry(() => http
          .patch(Uri.parse('$_baseUrl$path'), headers: _jsonHeaders, body: body)
          .timeout(const Duration(seconds: 30)));

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  static Future<http.Response> _withRetry(
    Future<http.Response> Function() fn, {
    int retries = 3,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        return await fn();
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw Exception('All retries exhausted');
  }
}
