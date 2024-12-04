import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class AuthService {
  final String clientId =
      "u-s4t2ud-e3ffe29b23bca6d91f32a4f6846dbc6388ec2c2656dc486e03688c6d75b8765a";
  final String clientSecret =
      "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";
  final String redirectUri = 'swiftyapp://details';
  final String authUrl = "https://api.intra.42.fr/oauth/authorize";
  final String tokenUrl = "https://api.intra.42.fr/oauth/token";

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
