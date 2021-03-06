//
//  AssetWebview.swift
//  asset_webview
//
//  Created by David Green on 2021-05-08.
//
import Flutter
import UIKit
import WebKit

class AssetWebviewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private let assetHandler: AssetHandler

    init(messenger: FlutterBinaryMessenger, assetHandler: AssetHandler) {
        self.messenger = messenger
        self.assetHandler = assetHandler
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return AssetWebview(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            assetHandler: assetHandler)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class AssetWebview: NSObject, FlutterPlatformView, WKNavigationDelegate {
    private let _view: WKWebView
    private var _loaded: Bool = false
    private let _channel: FlutterMethodChannel
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger,
        assetHandler: AssetHandler
    ) {
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(assetHandler, forURLScheme: "asset")
        _view = WKWebView(frame: frame, configuration: configuration)
        _view.allowsBackForwardNavigationGestures = false
        _view.allowsLinkPreview = false
        _channel = FlutterMethodChannel(name: "com.greensopinion.flutter/asset_webview_\(viewId)", binaryMessenger: messenger)        
        super.init()
        _channel.setMethodCallHandler({ call, result in
            self.callMethod(call, result)
        })
        _view.navigationDelegate = self
        WebViewAppearance.initial(_view)
        let arguments = args as! Dictionary<String, Any>
        _view.load(URLRequest(url: URL(string: arguments["initialUrl"] as! String)!))
    }

    func view() -> UIView {
        return _view
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (!_loaded) {
            _loaded = true
            WebViewAppearance.loaded(_view)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.navigationType == .linkActivated) {
            if let url = navigationAction.request.url {
                if url.scheme == "http" || url.scheme == "https" {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
                if url.scheme != "asset" {
                    let args = [
                        "url": url.absoluteString
                    ]
                    _channel.invokeMethod("shouldOverrideUrlLoading", arguments: args, result: { response in
                        let shouldOverride = response as! Bool
                        decisionHandler(shouldOverride ? .cancel : .allow)
                    })
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
    func callMethod(_ call: FlutterMethodCall, _ result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
}
