import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FluidPayPaymentPage extends StatefulWidget {
  const FluidPayPaymentPage({super.key});

  @override
  State<FluidPayPaymentPage> createState() => _FluidPayPaymentPageState();
}

class _FluidPayPaymentPageState extends State<FluidPayPaymentPage> {
  late final WebViewController _controller;

  String token = "";
  double containerHeight = 150; // initial height

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (message) {
          if (message.message.startsWith("HEIGHT:")) {
            double newHeight =
                double.tryParse(message.message.replaceFirst("HEIGHT:", "")) ??
                150;
            setState(() => containerHeight = newHeight + 20); // extra padding
          } else {
            setState(() => token = message.message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Token received: ${message.message}")),
            );
          }
        },
      )
      ..loadHtmlString(
        _htmlContent(
          "https://sandbox.fluidpay.com/tokenizer/tokenizer.js",
          "pub_31uSkmo5HcVIZrvXUVUvVzUBrjS",
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        SizedBox(
          width: double.infinity,
          height: containerHeight,
          child: WebViewWidget(controller: _controller),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () {
            _controller.runJavaScript("tokenizer.submit();");
          },
          child: const Text("Submit Payment"),
        ),
        const SizedBox(height: 20),
        Text(
          "Token: $token",
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
        Flutter.postMessage(data.data.token);
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
