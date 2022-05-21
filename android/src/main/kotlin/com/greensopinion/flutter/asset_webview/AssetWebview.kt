package com.greensopinion.flutter.asset_webview

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.view.View
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.net.URI
import java.net.URLConnection

class AssetWebviewFactory(
        private val binaryMessenger: BinaryMessenger,
        private val flutterAssets: FlutterPlugin.FlutterAssets
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return AssetWebview(binaryMessenger, flutterAssets, context!!, viewId, args as Map<String?, Any?>)
    }
}

@SuppressLint("SetJavaScriptEnabled")
private class AssetWebview(
        binaryMessenger: BinaryMessenger,
        flutterAssets: FlutterPlugin.FlutterAssets,
        context: Context,
        id: Int,
        creationParams: Map<String?, Any?>
) : PlatformView {
    private val view = WebView(context)
    private val methodChannel = MethodChannel(binaryMessenger, "com.greensopinion.flutter/asset_webview_$id")

    init {
        view.settings.javaScriptEnabled = true
        view.settings.allowFileAccess = false
        view.settings.allowContentAccess = false
        view.setWebViewClient(AssetWebviewClient(methodChannel, context, view))
        val initialUrl = creationParams["initialUrl"] as String?
                ?: throw Exception("Must specify initialUrl")
        require(initialUrl.startsWith("asset://local/")) { "Expected initialUrl starting with asset://local/" }
        val path = URI.create(initialUrl).path.trimLeadingSlash()
        val assetPath = flutterAssets.getAssetFilePathByName(path).trimLeadingSlash()
        view.loadUrl("asset://local/$assetPath")
    }

    override fun getView(): View {
        return view;
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        view.destroy()
    }
}

private class AssetWebviewClient(
        val methodChannel: MethodChannel,
        val context: Context,
        val view: WebView
) : WebViewClient(), MethodChannel.MethodCallHandler {
    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): WebResourceResponse? {
        if (request.url.scheme == "asset" && request.url.host == "local") {
            val path = request.url.path
            if (path != null) {
                val contentType = URLConnection.guessContentTypeFromName(path)
                val stream = context.assets.open(path.trimLeadingSlash())
                return WebResourceResponse(contentType, null, stream)
            }
        }
        return null
    }

    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
        val url = request.url
        return when (url.scheme) {
            "https", "http" -> {
                context.startActivity(Intent(Intent.ACTION_VIEW, url))
                true
            }
            "asset" -> false
            else -> {
                methodChannel.invokeMethod(
                    "shouldOverrideUrlLoading",
                    mapOf(Pair("url", url.toString())),
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            val shouldOverride = result as Boolean
                            if (!shouldOverride) {
                                view.loadUrl(url.toString())
                            }
                        }

                        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                            throw Exception("$errorCode: $errorMessage")
                        }

                        override fun notImplemented() {
                            throw Exception()
                        }
                    }
                )
                // can't block here, so we ovreride all requests and then later apply the response
                // from the controller to the web view
                true
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        result.notImplemented()
    }
}

private fun String.trimLeadingSlash(): String {
    if (this.startsWith("/")) {
        return this.substring(1)
    }
    return this
}