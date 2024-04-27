import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:web_view/src/navigation_controls.dart';
import 'package:web_view/src/web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WebViewAppState createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;
  late StreamSubscription _connectivitySubscription;

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result != ConnectivityResult.mobile &&
        result != ConnectivityResult.wifi) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('No internet connection available!'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'))
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://google.com'),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SnackBar',
        onMessageReceived: (message) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message.message)));
        },
      );

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          } else {
            // ignore: use_build_context_synchronously
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: const Text('Warning'),
                      content: const Text('Do you want to exit?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('No')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Yes')),
                      ],
                    ));
            return true;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF1a72e8),
            title: const Text('Flutter WebView'),
            actions: [
              NavigationControls(controller: controller),
              // Menu(
              //   controller: controller,
              // )
            ],
          ),
          body: SafeArea(
            child: WebViewStack(
              controller: controller,
            ),
          ),
        ));
  }
}
