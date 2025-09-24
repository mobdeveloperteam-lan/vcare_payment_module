import 'package:flutter/services.dart';

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;
    var newSelection = newValue.selection;

    // Check if a single digit from 2-9 is typed
    if (newText.length == 1 && int.tryParse(newText) != null) {
      final digit = int.parse(newText);
      if (digit > 1 && digit <= 9) {
        newText = '0$newText';
        newSelection = TextSelection.collapsed(offset: newText.length);
        return newValue.copyWith(text: newText, selection: newSelection);
      }
    }

    // Check if the two-digit month is valid
    if (newText.length == 2 && int.tryParse(newText) != null) {
      final month = int.parse(newText);
      if (month > 12) {
        return oldValue;
      }
    }

    return newValue;
  }
}
