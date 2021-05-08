import 'package:flutter/material.dart';
import 'package:asset_webview/asset_webview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example Usage of asset_webview'),
        ),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: AssetWebview(initialUrl: 'asset://local/help/index.html'))
        ])),
      ),
    );
  }
}
