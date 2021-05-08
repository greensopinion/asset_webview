import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _ASSET_URL_PREFIX = "asset://local/";
const _VIEW_TYPE = "asset_webview";

class AssetWebview extends StatelessWidget {
  final String initialUrl;
  AssetWebview({required this.initialUrl}) {
    if (!initialUrl.startsWith(_ASSET_URL_PREFIX)) {
      throw Exception("Expecting initialUrl to start with $_ASSET_URL_PREFIX");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      "initialUrl": initialUrl
    };

    if (Platform.isAndroid) {
      return PlatformViewLink(
          surfaceFactory: (context, controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <
                  Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (params) {
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
      );
    }
    throw Exception("Not implemented: ${Platform.operatingSystem}");
  }
}
