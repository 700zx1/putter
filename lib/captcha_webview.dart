import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CaptchaWebView extends StatefulWidget {
  final WebUri url;
  final void Function(List<Cookie> cookies) onCaptchaSolved;

  const CaptchaWebView({required this.url, required this.onCaptchaSolved, Key? key}) : super(key: key);

  @override
  State<CaptchaWebView> createState() => _CaptchaWebViewState();
}

class _CaptchaWebViewState extends State<CaptchaWebView> {
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Solve CAPTCHA')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: widget.url),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onLoadStop: (controller, url) async {
          // Check if CAPTCHA is solved (customize this logic as needed)
          if (url.toString().contains('nsw2u.com') &&
              !url.toString().contains('captcha')) {
            // Get cookies for nsw2u.com
            final cookieManager = CookieManager.instance();
            final cookies = await cookieManager.getCookies(
                url: WebUri('https://nsw2u.com'));
            widget.onCaptchaSolved(cookies);
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
