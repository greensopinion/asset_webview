//
//  AssetHandler.swift
//  asset_webview
//
//  Created by David Green on 2021-05-08.
//

import Foundation
import WebKit

class AssetHandler : NSObject, WKURLSchemeHandler {
    
    let pathProvider: (_: String) -> String?
    init(pathProvider: @escaping (_: String) -> String?) {
        self.pathProvider = pathProvider
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let url = urlSchemeTask.request.url!
        var path = url.path
        if (path.starts(with: "/")) {
            path.removeFirst()
        }
        let assetPath = pathProvider(path)
        if let filePath = Bundle.main.path(forResource: assetPath, ofType: nil) {
            let resourceUrl = URL(fileURLWithPath: filePath)
            serve(data: resourceUrl,asResponseTo: url, for: urlSchemeTask)
        } else {
            respondNotFound(urlSchemeTask, url)
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // nothing to do
    }
    
    private func serve(data resourceUrl: URL,asResponseTo request: URL, for task: WKURLSchemeTask) {
        do {
            let data = try Data(contentsOf: resourceUrl)
            let headers = ["Content-Type": contentType(request)]
            task.didReceive(HTTPURLResponse(url: request, statusCode: 200, httpVersion: "1.1", headerFields: headers)!)
            task.didReceive(data)
            task.didFinish()
        } catch {
            print("load error: \(error)")
            task.didReceive(errorResponse(request, 500))
            task.didReceive("<html><body><h2>500 Error</h2><p>\(error)</p></body></html>".data(using: .utf8)!)
            task.didFinish()
        }
    }
    
    private func respondNotFound(_ task: WKURLSchemeTask,_ url: URL) {
        print("resource not found: \(url.path)")
        task.didReceive(errorResponse(url, 404))
        task.didReceive("<html><body><h2>404 Not Found</h2><p>Resource not found: \(url.path)</p></body></html>".data(using: .utf8)!)
        task.didFinish()
    }
    
    private func errorResponse(_ url: URL,_ statusCode: Int) -> URLResponse {
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "1.1", headerFields: ["Content-Type":"text/html"])!
    }
    private func contentType(_ url: URL) -> String {
        let parts = url.path.split(separator: ".").map({ String($0) })
        let resourceExtension = parts.last!.lowercased()
        switch resourceExtension {
            case "html": return "text/html"
            case "css": return "text/css"
            case "js": return "text/javascript"
            case "svg": return "image/svg+xml"
            case "jpg": return "image/jpeg"
            case "png", "gif", "jpeg": return "image/\(resourceExtension)"
            default: return "application/octet-stream"
        }
    }
}
