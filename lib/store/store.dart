import 'package:flutter/material.dart';

class StoreProvider with ChangeNotifier {
  // Map<String, dynamic> user = or null
  static Map<String, dynamic>? _user;
  static String? _token;
  static int page_number = 0;
  static String? search_name = null;
  static int retry = 0;

  void setUser(Map<String, dynamic> newUser) {
    _user = newUser;
    notifyListeners();
  }

  void setRetry(int newRetry) {
    retry = newRetry;
    notifyListeners();
  }

  void setPageNumber(int newPageNumber) {
    page_number = newPageNumber;
    notifyListeners();
  }

  void setToken(String newToken) {
    _token = newToken;
    notifyListeners();
  }

  void setSearchName(String? newSearchName) {
    search_name = newSearchName;
    notifyListeners();
  }

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  int get pageNumber => page_number;
  String? get searchName => search_name;
  int get getRetry => retry;

  void clearUser() {
    _user = null;
    _token = null;
    page_number = 0;
    retry = 0;
    search_name = null;
    notifyListeners();
  }

  void logout() {
    clearUser();
  }
}
