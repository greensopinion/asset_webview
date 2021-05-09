import 'package:flutter/material.dart';
import 'package:asset_webview/asset_webview.dart';
import 'package:asset_webview/asset_webview_controller.dart';

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
      navigatorKey: _navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example Usage of asset_webview'),
        ),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: AssetWebview(
                  initialUrl: 'asset://local/help/index.html',
                  controller:
                      NavigationAssetWebviewController(_currentContext)))
        ])),
      ),
      routes: {"about": (context) => AboutPage()},
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About asset_webview'),
      ),
      body: SafeArea(child: Center(child: Text("Sample about page."))),
    );
  }
}

BuildContext _currentContext() => _navigatorKey.currentContext!;
final _navigatorKey = GlobalKey<NavigatorState>();
