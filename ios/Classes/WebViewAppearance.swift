//
//  WebViewAppearance.swift
//  asset_webview
//
//  Created by David Green on 2021-05-08.
//

import Foundation
import WebKit

public class WebViewAppearance {
    static func initial(_ webView: WKWebView) {
        webView.alpha = 0
    }
    
    static func loaded(_ webView: WKWebView) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.30)
        webView.alpha = 1
        UIView.commitAnimations()
    }
}
