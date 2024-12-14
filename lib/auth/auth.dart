import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class AuthService {
  final String clientId = dotenv.env['CLIENT_ID']!;

  final String clientSecret = dotenv.env['CLIENT_SECRET']!;
  final String redirectUri = dotenv.env['REDIRECT_URI']!;
  final String authUrl = dotenv.env['AUTHORIZATION_URL']!;
  final String tokenUrl = dotenv.env['TOKEN_URL']!;

  Future<String> login() async {
    final result = await FlutterWebAuth.authenticate(
      url:
          "$authUrl?client_id=$clientId&redirect_uri=$redirectUri&response_type=code",
      callbackUrlScheme: "swiftyapp",
    );

    if (result.isEmpty) {
      throw Exception("Failed to authenticate");
    }

    final code = Uri.parse(result).queryParameters['code'];
    if (code != null) {
      final http.Response response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': code,
          'redirect_uri': redirectUri,
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['access_token'];
      } else {
        throw Exception("Failed to retrieve access code");
      }
    } else {
      throw Exception("Failed to retrieve access code");
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
        print(response.body);
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
