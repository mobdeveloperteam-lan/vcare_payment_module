import 'package:flutter/material.dart';

class FluidPayProvider extends ChangeNotifier {
  String _token = "";
  double _containerHeight = 150;

  String get token => _token;
  double get containerHeight => _containerHeight;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setHeight(double height) {
    _containerHeight = height;
    notifyListeners();
  }

  void reset() {
    _token = "";
    _containerHeight = 150;
    notifyListeners();
  }
}
