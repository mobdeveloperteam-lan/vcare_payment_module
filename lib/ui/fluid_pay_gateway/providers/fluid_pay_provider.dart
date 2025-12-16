import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Enum to manage the button's visual state
enum ButtonStates { idle, loading, success }

class FluidPayProvider extends ChangeNotifier {
  double _containerHeight = 300;
  String _token = "";
  bool _loading = true;

  // State for the animated button
  ButtonStates _buttonState = ButtonStates.idle;

  double get containerHeight => _containerHeight;
  String get token => _token;
  bool get loading => _loading;
  
  // Getter for the new button state
  ButtonStates get buttonState => _buttonState;

  void setHeight(double height) {
    _containerHeight = height;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
  
  // Setter for the new button state
  void setButtonState(ButtonStates state) {
    _buttonState = state;
    notifyListeners();
  }

  void reset() {
    _containerHeight = 300;
    _token = "";
    _loading = true;
    _buttonState = ButtonStates.idle; // Reset the button state as well
    notifyListeners();
  }
}