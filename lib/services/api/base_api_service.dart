import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseApiService {
  static const String baseHostDomain = 'wildtrace-production.up.railway.app';
  static const String _apiPath = '/api';
  static const String _storagePath = '/storage/';
  static const String _rootPath = '/';

  static String get baseUrl => 'https://$baseHostDomain$_apiPath';
  static String get storageUrl => 'https://$baseHostDomain$_storagePath';
  static String get baseHostUrl => 'https://$baseHostDomain$_rootPath';

  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    if (cleanPath.startsWith('storage/')) return 'https://$baseHostDomain/$cleanPath';
    return '$baseHostUrl$cleanPath';
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = Uri.https(baseHostDomain, '$_apiPath/$cleanEndpoint');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response, endpoint);
    } catch (_) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body, String? token}) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = Uri.https(baseHostDomain, '$_apiPath/$cleanEndpoint');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response, endpoint);
    } catch (_) {
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body, String? token}) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = Uri.https(baseHostDomain, '$_apiPath/$cleanEndpoint');
    
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response, endpoint);
    } catch (_) {
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {String? token}) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = Uri.https(baseHostDomain, '$_apiPath/$cleanEndpoint');
    
    try {
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response, endpoint);
    } catch (_) {
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response, String endpoint) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      
      String body = response.body.trim();
      
      if (!body.startsWith('{') && !body.startsWith('[')) {
        int firstBrace = body.indexOf('{');
        int firstBracket = body.indexOf('[');
        int start = -1;
        if (firstBrace != -1 && (firstBracket == -1 || firstBrace < firstBracket)) {
          start = firstBrace;
        } else if (firstBracket != -1) {
          start = firstBracket;
        }
        if (start != -1) body = body.substring(start);
      }
      
      if (!body.endsWith('}') && !body.endsWith(']')) {
        int lastBrace = body.lastIndexOf('}');
        int lastBracket = body.lastIndexOf(']');
        int end = -1;
        if (lastBrace != -1 && (lastBracket == -1 || lastBrace > lastBracket)) {
          end = lastBrace;
        } else if (lastBracket != -1) {
          end = lastBracket;
        }
        if (end != -1) body = body.substring(0, end + 1);
      }

      try {
        return json.decode(body);
      } catch (_) {
        throw Exception('Failed to decode server data.');
      }
    } else {
      String? errorMessage;
      try {
        final error = json.decode(response.body);
        errorMessage = error['message'];
      } catch (_) {}

      if (errorMessage == null) {
        switch (response.statusCode) {
          case 401: errorMessage = 'Session expired. Please login again.'; break;
          case 403: errorMessage = 'Permission denied.'; break;
          case 404: errorMessage = 'Server route not found.'; break;
          case 500: errorMessage = 'Internal server error.'; break;
          default: errorMessage = 'Unexpected error (Status ${response.statusCode})';
        }
      }
      throw Exception(errorMessage);
    }
  }
}
