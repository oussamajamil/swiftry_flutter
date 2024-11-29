import 'dart:convert';
import 'package:http/http.dart' as http;

class IntraAPI {
  final String baseUrl;
  String? _accessToken;
  final String clientId;
  final String clientSecret;

  IntraAPI({
    required this.baseUrl,
    required this.clientId,
    required this.clientSecret,
    String? accessToken,
  }) : _accessToken = accessToken;

  /// Fetch user details
  Future<List<dynamic>> getUserDetail(String login) async {
    try {
      final response = await _makeRequest(
        'GET',
        '/v2/users/$login',
      );
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Object> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final defaultHeaders = {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };

    final mergedHeaders = {
      if (headers != null) ...headers,
      ...defaultHeaders,
    };

    http.Response response;

    // Execute HTTP request
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: mergedHeaders);
        break;
      default:
        throw Exception('Unsupported HTTP method');
    }

    // Handle response
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      await _refreshToken();
      // Retry the request after refreshing token
      return await _makeRequest(method, endpoint, headers: headers, body: body);
    } else {
      throw Exception(
          'Failed request: ${response.statusCode} - ${response.body}');
    }
  }

  /// Refresh the access token
  Future<void> _refreshToken() async {
    final uri = Uri.parse('$baseUrl/oauth/token');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'grant_type': 'client_credentials',
        'client_id':
            "u-s4t2ud-e3ffe29b23bca6d91f32a4f6846dbc6388ec2c2656dc486e03688c6d75b8765a",
        'client_secret':
            "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",
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }
}
