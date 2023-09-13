import 'package:flutter/material.dart';
import 'package:orphansafe_management_app/api/notification_service_api.dart';
import 'package:orphansafe_management_app/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  static const route = '/web-view-page';

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            Utils.setWebViewController(controller);
          },
          onUrlChange: (UrlChange urlChange) async {
            if (urlChange.url! == Utils.getBaseURL()) {
              final token = await Utils.getFCMToken();
              final userId = await Utils.controller.runJavaScriptReturningResult('''
                JSON.parse(localStorage.getItem('userInfo')).userId;
            ''');
              await NotificationServiceApi.patchTokenWithServer(userId.toString().replaceAll("\\", "").replaceAll('"', ""), token);
            }
          },
          onPageFinished: (String url) async {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      // ..loadRequest(Uri.parse('https://flutter.dev'));
      ..loadRequest(Uri.parse(Utils.getBaseURL()));
  }

  @override
  Widget build(BuildContext context) {
    // final message = ModalRoute.of(context)!.settings.arguments;
    return SafeArea(
      child: Scaffold(
        body: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
