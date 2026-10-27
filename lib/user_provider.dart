import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  int? _userId;
  String? _userName;
  String? _email;

  int? get userId => _userId;
  String? get userName => _userName;
  String? get email => _email;

  bool get isLoggedIn => _userId != null;

  void setUser({
    required int userId,
    required String userName,
    required String email,
  }) {
    _userId = userId;
    _userName = userName;
    _email = email;

    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _userName = null;
    _email = null;

    notifyListeners();
  }
}