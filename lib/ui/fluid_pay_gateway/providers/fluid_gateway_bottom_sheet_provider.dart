import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fluid_pay_provider.dart';
import '../widgets/fluid_pay_webview.dart';

class FluidGateWayBottomSheetProvider extends ChangeNotifier {
  bool _isShown = false;

  bool get isShown => _isShown;

  void showSheet(
    BuildContext context, {
    required String apiKey,
    required String tokenizerUrl,
    required void Function(String message) onClose,
  }) {
    if (_isShown) return;

    _isShown = true;
    notifyListeners();

    showModalBottomSheet(
      context: context,
      // 1. KEEP isScrollControlled: true to allow the sheet to be tall
      isScrollControlled: true,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => FluidPayProvider(),
          child: Consumer<FluidPayProvider>(
            builder: (context, provider, _) {
              return PopScope(
                canPop: false,
                child: SafeArea(
                  // 2. Use FractionallySizedBox to define a large, reliable height
                  // WebViews require explicit constraints to function properly.
                  child: FractionallySizedBox(
                    heightFactor:
                        0.85, // Use 85% of the available screen height
                    child: Stack(
                      children: [
                        const SizedBox(height: 100),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: FluidPayWebView(
                            apiKey: apiKey,
                            tokenizerUrl: tokenizerUrl,
                          ),
                        ),
                        if (provider.loading)
                          const Center(child: CircularProgressIndicator()),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              onClose("closed_by_user");
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black.withOpacity(0.05),
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
