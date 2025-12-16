import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/fluid_pay_provider.dart';

// Button states

class FluidPayWebView extends StatefulWidget {
  final String apiKey;
  final String tokenizerUrl;
  final VoidCallback? onLoadFailed;

  const FluidPayWebView({
    super.key,
    required this.apiKey,
    required this.tokenizerUrl,
    this.onLoadFailed,
  });

  @override
  FluidPayWebViewState createState() => FluidPayWebViewState();
}

class FluidPayWebViewState extends State<FluidPayWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            // Request initial height
            _controller.runJavaScript("""
              const c = document.getElementById('card_container');
              if(c) Flutter.postMessage("HEIGHT:" + c.offsetHeight);
            """);
          },
          onWebResourceError: (_) {
            if (widget.onLoadFailed != null) widget.onLoadFailed!();
          },
        ),
      )
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (message) {
          final provider = Provider.of<FluidPayProvider>(
            context,
            listen: false,
          );
          print("sandeep -" + message.message);
          if (message.message.startsWith("HEIGHT:")) {
            final height =
                double.tryParse(message.message.replaceFirst("HEIGHT:", "")) ??
                150;
            provider.setHeight(height + 20);
            provider.setLoading(false);
            provider.setButtonState(ButtonStates.idle);
          } else {
            if (message.message.contains("Token Found:")) {
              final token = message.message
                  .replaceFirst("Token Found:", "")
                  .trim();
              provider.setToken(token);
              provider.setButtonState(ButtonStates.success);

              // Show a SnackBar
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Token received: $token")),
                );
              }

              // Reset button state after a short delay
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) provider.setButtonState(ButtonStates.idle);
              });
            }
          }
        },
      )
      ..loadHtmlString(_htmlContent(widget.tokenizerUrl, widget.apiKey));
  }

  void submitFn() {
    _controller.runJavaScript("tokenizer.submit();");
  }

  /// Call this to submit payment from Flutter
  void submit() {
    final provider = Provider.of<FluidPayProvider>(context, listen: false);
    provider.setButtonState(ButtonStates.loading);
    submitFn();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FluidPayProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30),
        SizedBox(
          height: provider.containerHeight > 0 ? provider.containerHeight : 300,
          width: double.infinity,
          child: WebViewWidget(controller: _controller),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.buttonState == ButtonStates.loading
                  ? null
                  : submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.amber,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: provider.buttonState == ButtonStates.idle
                    ? const Text(
                        "Pay Now",
                        key: ValueKey('pay_now_text'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      )
                    : provider.buttonState == ButtonStates.loading
                    ? const SizedBox(
                        key: ValueKey('loading_spinner'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black87,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.check,
                        key: ValueKey('success_icon'),
                        color: Colors.black87,
                        size: 24,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Token: ${provider.token}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _htmlContent(String url, String key) {
    return """
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="$url"></script>
<style>
  html, body {
    margin: 0;
    padding: 0;
    overflow: hidden; /* prevent scrolling */
    width: 100%;
    height: 100%;
    background-color: #f9f9f9;
  }
  #card_container {
    width: 100%;
    height: auto;
    border: 1px solid #ccc;
    padding: 25px;
    box-sizing: border-box;
    border-radius: 8px;
    background-color: #FFFFFF00;
  }
  #card_container input {
    background-color: #f0f8ff;
    border-radius: 4px;
    padding: 8px;
    font-size: 16px;
  }
</style>
</head>
<body>
<div id="card_container"></div>
<script>
  const tokenizer = new Tokenizer({
    apikey: "$key",
    container: "#card_container"
  });
 
  window.addEventListener("message", function(event) {
    if (!event.data) return;
    try {
      let data = typeof event.data === "string" ? JSON.parse(event.data) : event.data;
 
      if (data && data.data && data.data.token) {
        Flutter.postMessage("Token Found: " + data.data.token);
      }
 
      // Dynamic height update
      const height = document.getElementById('card_container').offsetHeight;
      Flutter.postMessage("HEIGHT:" + height);
 
    } catch(e) {
      console.error(e);
    }
  });
 
  // Initial height update after page load
  window.onload = () => {
    const height = document.getElementById('card_container').offsetHeight;
    Flutter.postMessage("HEIGHT:" + height);
  }
</script>
</body>
</html>
""";
  }
}
