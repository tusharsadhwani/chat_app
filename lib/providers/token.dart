import 'package:flutter/foundation.dart';

class Token with ChangeNotifier {
  String _token;

  Token() {
    _token = null;
  }

  String get token {
    return _token;
  }

  void setToken(String newValue) {
    _token = newValue;
    notifyListeners();
  }
}
