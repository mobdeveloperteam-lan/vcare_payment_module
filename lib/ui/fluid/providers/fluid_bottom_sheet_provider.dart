// ignore_for_file: sort_child_properties_last

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vcare_payment_module/ui/fluid/widget/fluid_bottom_sheet_content.dart';

class FluidBottomSheetProvider extends ChangeNotifier {
  bool _isShown = false;

  bool get isShown => _isShown;

  void showSheet(BuildContext context) {
    if (!_isShown) {
      _isShown = true;
      notifyListeners();

      showModalBottomSheet(
        context: context,
        isScrollControlled:
            true, // This is key to enabling content-based height
        backgroundColor: Colors.white,
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        builder: (context) {
          // A Padding widget is used to manage bottom insets, especially for the keyboard.
          return PopScope(
            canPop: false,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child:
                      FluidBottomSheetContent(), // The content's height will determine the sheet's height
                ),
                Positioned(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: CircleAvatar(
                      radius: 15, // Degrade the radius to a smaller value
                      backgroundColor: Colors.grey.withValues(alpha: .3),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 15,
                      ),
                    ),
                  ),
                  top: 20,
                  right: 20,
                ),
              ],
            ),
          );
        },
      ).whenComplete(() {
        _isShown = false;
        notifyListeners();
        if (kDebugMode) print("Bottom sheet closed ✅");
      });
    }
  }
}
