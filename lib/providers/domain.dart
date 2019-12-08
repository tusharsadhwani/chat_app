import 'package:flutter/material.dart';

class Domain with ChangeNotifier {
  var _domain;

  Domain(String domain) {
    _domain = domain.trim();
    if (domain.endsWith('/')) domain = domain.substring(0, domain.length - 1);
    _domain = domain;
  }

  String get domain {
    return _domain;
  }
}
