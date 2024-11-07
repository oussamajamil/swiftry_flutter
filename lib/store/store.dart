import 'package:flutter/material.dart';

class StoreProvider with ChangeNotifier {
  // Map<String, dynamic> user = or null
  static Map<String, dynamic>? user = null;
  static String? token = null;

  void setUser(Map<String, dynamic> newUser) {
    user = newUser;
    notifyListeners();
  }

  void setToken(String newToken) {
    token = newToken;
    notifyListeners();
  }

  void clearUser() {
    user = null;
    notifyListeners();
  }

  void logout() {
    clearUser();
    notifyListeners();
  }
}
