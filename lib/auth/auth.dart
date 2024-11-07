import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2_client/access_token_response.dart';
import 'dart:convert';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class AuthService {
  final String _baseUrl = "https://api.intra.42.fr/v2/";
  late final OAuth2Helper _oauth2Helper;

  final OAuth2Client client = OAuth2Client(
    authorizeUrl: 'https://api.intra.42.fr/oauth/authorize',
    tokenUrl: 'https://api.intra.42.fr/oauth/token',
    redirectUri: 'swiftyapp://details',
    customUriScheme: 'swiftyapp',
  );

  AuthService() {
    _oauth2Helper = OAuth2Helper(client,
        clientSecret:
            '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',
        clientId: 'u-s4t2ud-e3ffe29b23bca6d91f32a4f6846dbc6388ec2c2656dc486e03688c6d75b8765a',
        scopes: ['public']);
  }
  Future<String> login() async {
    try {
      final AccessTokenResponse? result = await _oauth2Helper.getToken();
      if (result != null && result.accessToken != null) {
        // Return the access token if it's available
        return result.accessToken!;
      } else {
        // If the result is null or the access token is null, throw an error
        throw Exception("Failed to retrieve access token: result is null");
      }
    } catch (e) {
      // Rethrow the error for the caller to handle
      throw Exception("Error during login: $e");
    }
  }

  Future<bool> checktoken(String token) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception("Error during checkToken: $e");
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String token) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to retrieve user info: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error during getUserInfo: $e");
    }
  }

  Future<Map<String, dynamic>> getProjects(String token) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/projects'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to retrieve projects: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error during getProjects: $e");
    }
  }

  /// coalitions endpoint
  Future<Map<String, dynamic>> getCoalitions(String token) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/coalitions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to retrieve coalitions: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error during getCoalitions: $e");
    }
  }
}
