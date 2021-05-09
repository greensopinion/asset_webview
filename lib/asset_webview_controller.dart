import 'package:asset_webview/asset_webview.dart';
import 'package:flutter/widgets.dart';

typedef BuildContextProvider = BuildContext Function();

class NavigationAssetWebviewController extends AssetWebviewController {
  final BuildContextProvider contextProvider;
  NavigationAssetWebviewController(this.contextProvider);

  @override
  bool shouldOverrideUrlLoading(String url) {
    if (url.startsWith(_NAVIGATION_URL_PREFIX)) {
      final route = url.substring(_NAVIGATION_URL_PREFIX.length);
      Navigator.pushNamed(contextProvider(), route);
      return true;
    }
    return false;
  }
}

const _NAVIGATION_URL_PREFIX = "navigation://";
