import 'dart:async';

import 'package:flutter/services.dart';

class AssetWebview {
  static const MethodChannel _channel = const MethodChannel('asset_webview');

  static Future<String> get platformVersion async {
    return await _channel.invokeMethod('getPlatformVersion') ?? "<unknown>";
  }
}
