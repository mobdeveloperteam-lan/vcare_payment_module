// ignore_for_file: unused_local_variable

import 'package:flutter/services.dart';

class CreditCardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Get plain digits
    String oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    String newDigits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Track cursor index before formatting
    int cursorPosition = newValue.selection.baseOffset;

    // Format digits into 4-digit groups
    final buffer = StringBuffer();
    int spaceCount = 0;

    for (int i = 0; i < newDigits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
        if (i < cursorPosition + spaceCount) spaceCount++;
      }
      buffer.write(newDigits[i]);
    }

    String formatted = buffer.toString();

    // Adjust cursor by comparing pre- and post-format positions
    int nonFormattedCursorPosition = 0;
    for (int i = 0; i < cursorPosition && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        nonFormattedCursorPosition++;
      }
    }

    int finalCursorPosition = nonFormattedCursorPosition;
    if (finalCursorPosition > 0) {
      finalCursorPosition += (finalCursorPosition - 1) ~/ 4; // add one space every 4 digits
    }

    finalCursorPosition = finalCursorPosition.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: finalCursorPosition),
    );
  }
}

