import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/fluid_pay_provider.dart';

class FluidPayWebView extends StatefulWidget {
  final String apiKey;
  final String tokenizerUrl;

  const FluidPayWebView({
    super.key,
    required this.apiKey,
    required this.tokenizerUrl,
  });

  @override
  FluidPayWebViewState createState() => FluidPayWebViewState(); // public
}

class FluidPayWebViewState extends State<FluidPayWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (message) {
          final provider = Provider.of<FluidPayProvider>(
            context,
            listen: false,
          );

          if (message.message.startsWith("HEIGHT:")) {
            double newHeight =
                double.tryParse(message.message.replaceFirst("HEIGHT:", "")) ??
                150;
            provider.setHeight(newHeight + 20); // add padding
          } else {
            provider.setToken(message.message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Token received: ${message.message}")),
            );
          }
        },
      )
      ..loadHtmlString(_htmlContent(widget.tokenizerUrl, widget.apiKey));
  }

  String _htmlContent(String url, String key) {
    return """
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="$url"></script>
<style>
html, body { margin:0; padding:0; overflow:hidden; width:100%; height:100%; background-color:#f9f9f9; }
#card_container { width:100%; height:auto; border:1px solid #ccc; padding:25px; box-sizing:border-box; border-radius:8px; background-color:#FFFFFF00; }
#card_container input { background-color:#f0f8ff; border-radius:4px; padding:8px; font-size:16px; }
</style>
</head>
<body>
<div id="card_container"></div>
<script>
const tokenizer = new Tokenizer({ apikey: "$key", container: "#card_container" });

window.addEventListener("message", function(event) {
  if (!event.data) return;
  try {
    let data = typeof event.data === "string" ? JSON.parse(event.data) : event.data;
    if (data && data.data && data.data.token) {
      Flutter.postMessage(data.data.token);
    }
    const height = document.getElementById('card_container').offsetHeight;
    Flutter.postMessage("HEIGHT:" + height);
  } catch(e) { console.error(e); }
});

window.onload = () => {
  const height = document.getElementById('card_container').offsetHeight;
  Flutter.postMessage("HEIGHT:" + height);
}
</script>
</body>
</html>
""";
  }

  // Global submit
  void submit() {
    _controller.runJavaScript("tokenizer.submit();");
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
