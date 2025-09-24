import 'package:flutter/material.dart';

enum CardType { Visa, Mastercard, Amex, Discover, Diners, JCB, Unknown }

enum ButtonState { idle, loading, success }

CardType getCardTypeFromNumber(String input) {
  if (input.isEmpty) return CardType.Unknown;
  input = input.replaceAll(' ', '');

  if (RegExp(r'^4[0-9]{0,}$').hasMatch(input)) return CardType.Visa;
  if (RegExp(r'^(5[1-5]|2[2-7])[0-9]{0,}$').hasMatch(input)) {
    return CardType.Mastercard;
  }
  if (RegExp(r'^3[47][0-9]{0,}$').hasMatch(input)) return CardType.Amex;
  if (RegExp(r'^(6011|65|64[4-9]|622)[0-9]{0,}$').hasMatch(input)) {
    return CardType.Discover;
  }
  if (RegExp(r'^(36|30[0-5]|38)[0-9]{0,}$').hasMatch(input)) {
    return CardType.Diners;
  }
  if (RegExp(r'^(35)[2-8][0-9]{0,}$').hasMatch(input)) return CardType.JCB;

  return CardType.Unknown;
}

bool isValidCardNumber(String input) {
  input = input.replaceAll(' ', '');
  if (input.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(input)) return false;

  int sum = 0;
  bool alternate = false;

  for (int i = input.length - 1; i >= 0; i--) {
    int n = int.parse(input[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

class FluidCardFormProvider extends ChangeNotifier {
  String _cardNumber = '';
  String _expiry = '';
  String _cvv = '';
  String _cardHolderName = '';
  CardType _cardType = CardType.Unknown;

  String get cardNumber => _cardNumber;
  String get expiry => _expiry;
  String get cvv => _cvv;
  String get cardHolderName => _cardHolderName;

  CardType get cardType => _cardType;

  // Add button state
  ButtonState _buttonState = ButtonState.idle;
  ButtonState get buttonState => _buttonState;

  void setButtonState(ButtonState state) {
    _buttonState = state;
    notifyListeners();
  }

  void setCardNumber(TextEditingController controller, String input) {
    final selectionStart = controller.selection.start;

    // Remove all non-digit characters
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    int cursorOffset = 0;

    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) {
        buffer.write(' ');
        if (i < selectionStart) cursorOffset++;
      }
      buffer.write(digits[i]);
    }

    _cardNumber = buffer.toString();

    // Detect card type
    _cardType = getCardTypeFromNumber(_cardNumber);

    // Restore cursor position
    final newPosition = (selectionStart + cursorOffset).clamp(
      0,
      _cardNumber.length,
    );
    controller.value = TextEditingValue(
      text: _cardNumber,
      selection: TextSelection.collapsed(offset: newPosition),
    );

    notifyListeners();
  }

  void setExpiry(String input, TextEditingController controller) {
    final selectionStart = controller.selection.start;

    // Remove non-digits
    String digits = input.replaceAll(RegExp(r'\D'), '');

    // Handle month normalization
    if (digits.isNotEmpty) {
      int month = int.tryParse(digits.substring(0, 1)) ?? 0;
      if (digits.length == 1 && month > 1) {
        digits = '0$digits'; // prepend 0 if first digit > 1
      }
    }

    String formatted = '';
    int cursorOffset = 0;

    if (digits.length >= 2) {
      // Month
      String month = digits.substring(0, 2);
      if (int.tryParse(month)! > 12) month = '12'; // max month = 12

      // Year (max 2 digits)
      String year = '';
      if (digits.length > 2) {
        year = digits.substring(2, digits.length > 4 ? 4 : digits.length);
      }

      formatted = '$month';
      if (year.isNotEmpty) {
        formatted += '/$year';
        if (selectionStart > 2) cursorOffset = 1; // for '/'
      }
    } else {
      formatted = digits;
    }

    _expiry = formatted;

    // Update controller text and cursor
    final newPosition = (selectionStart + cursorOffset).clamp(
      0,
      formatted.length,
    );
    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newPosition),
    );

    notifyListeners();
  }

  void setCardHolderName(String input, TextEditingController controller) {
    final selectionStart = controller.selection.start;

    // Keep only letters and spaces
    String filtered = input.replaceAll(RegExp(r'[^a-zA-Z ]'), '');

    // Prevent multiple consecutive spaces
    filtered = filtered.replaceAll(RegExp(r' {2,}'), ' ');

    // Convert to uppercase
    filtered = filtered.toUpperCase();

    // Limit length (commonly 26 for cardholder names)
    if (filtered.length > 26) {
      filtered = filtered.substring(0, 26);
    }

    _cardHolderName = filtered;

    // Update controller text and preserve cursor
    final newPosition = selectionStart.clamp(0, filtered.length);
    controller.value = TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: newPosition),
    );

    notifyListeners();
  }

  void setCVV(String input, TextEditingController controller) {
    final selectionStart = controller.selection.start;

    // Keep only digits
    String digits = input.replaceAll(RegExp(r'\D'), '');

    // Limit length to 4 digits
    if (digits.length > 4) digits = digits.substring(0, 4);

    _cvv = digits;

    // Update controller text and preserve cursor
    final newPosition = selectionStart.clamp(0, digits.length);
    controller.value = TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: newPosition),
    );

    notifyListeners();
  }

  // Validation
  bool get isCardValid => isValidCardNumber(_cardNumber);
  bool get isExpiryValid =>
      RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(_expiry);
  bool get isCVVValid => _cvv.length >= 3;

  bool get isFormValid => isCardValid && isExpiryValid && isCVVValid;
}
