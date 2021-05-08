
import 'dart:async';

import 'package:flutter/services.dart';

class AssetWebview {
  static const MethodChannel _channel =
      const MethodChannel('asset_webview');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
