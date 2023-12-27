import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

const _ASSET_URL_PREFIX = "asset://local/";
const _VIEW_TYPE = "com.greensopinion.flutter/asset_webview";

class AssetWebviewController {
  bool shouldOverrideUrlLoading(String url) {
    return false;
  }
}

class AssetWebview extends StatefulWidget {
  final String initialUrl;
  final AssetWebviewController controller;
  final bool builtInZoomControls;
  AssetWebview({Key? key, required this.initialUrl, AssetWebviewController? controller, this.builtInZoomControls = false})
      : this.controller = controller ?? AssetWebviewController(),
        super(key: key) {
    if (!initialUrl.startsWith(_ASSET_URL_PREFIX)) {
      throw Exception("Expecting initialUrl to start with $_ASSET_URL_PREFIX");
    }
  }
  @override
  State<StatefulWidget> createState() {
    return _AssetWebviewState(initialUrl: initialUrl, controller: controller, builtInZoomControls: builtInZoomControls);
  }
}

class _AssetWebviewState extends State<AssetWebview> {
  final String initialUrl;
  final AssetWebviewController controller;
  final bool builtInZoomControls;
  MethodChannel? channel;
  _AssetWebviewState({required this.initialUrl, required this.controller, required this.builtInZoomControls});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{"initialUrl": initialUrl, "builtInZoomControls": builtInZoomControls};

    if (Platform.isAndroid) {
      return PlatformViewLink(
          surfaceFactory: (context, controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (params) {
            channel = MethodChannel("com.greensopinion.flutter/asset_webview_${params.id}");
            channel!.setMethodCallHandler(_onMethodCall);
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: _VIEW_TYPE,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: StandardMessageCodec(),
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
          viewType: _VIEW_TYPE);
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: _VIEW_TYPE,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          channel = MethodChannel("com.greensopinion.flutter/asset_webview_$id");
          channel!.setMethodCallHandler(_onMethodCall);
        },
      );
    }
    throw Exception("Not implemented: ${Platform.operatingSystem}");
  }

  void dispose() {
    super.dispose();
    channel?.setMethodCallHandler(null);
  }

  Future<dynamic> _onMethodCall(MethodCall call) {
    if (call.method == "shouldOverrideUrlLoading") {
      final url = call.arguments["url"] as String;
      return Future.value(controller.shouldOverrideUrlLoading(url));
    }
    throw PlatformException(code: "notImplemented", message: "Method ${call.method} is not implemented");
  }
}
