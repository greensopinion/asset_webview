import Flutter
import UIKit

public class SwiftAssetWebviewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "asset_webview", binaryMessenger: registrar.messenger())
    let instance = SwiftAssetWebviewPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let factory = AssetWebviewFactory(
        messenger: registrar.messenger(),
        assetHandler: AssetHandler(pathProvider: { registrar.lookupKey(forAsset: $0) })
    )
    registrar.register(factory, withId: "asset_webview")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
