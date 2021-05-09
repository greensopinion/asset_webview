import Flutter
import UIKit

public class SwiftAssetWebviewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = AssetWebviewFactory(
        messenger: registrar.messenger(),
        assetHandler: AssetHandler(pathProvider: { registrar.lookupKey(forAsset: $0) })
    )
    registrar.register(factory, withId: "com.greensopinion.flutter/asset_webview")
  }
}
