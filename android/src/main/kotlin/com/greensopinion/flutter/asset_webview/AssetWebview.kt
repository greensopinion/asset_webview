package com.greensopinion.flutter.asset_webview

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.core.content.ContextCompat.startActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.net.URI
import java.net.URLConnection


class AssetWebviewFactory(private val flutterAssets: FlutterPlugin.FlutterAssets) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any): PlatformView {
        return AssetWebview(flutterAssets, context, viewId, args as Map<String?, Any?>)
    }
}

private class AssetWebview(
        private val flutterAssets: FlutterPlugin.FlutterAssets,
        val context: Context,
        id: Int,
        creationParams: Map<String?, Any?>
) : PlatformView {
    private val view = android.webkit.WebView(context)

    init {
        view.settings.javaScriptEnabled = true
        view.settings.allowFileAccess = false
        view.settings.allowContentAccess = false
        view.setWebViewClient(FlutterWebviewClient(context))
        val initialUrl = creationParams["initialUrl"] as String ?: throw Exception("Must specify initialUrl")
        require(initialUrl.startsWith("asset://local/")) { "Expected initialUrl starting with asset://local/" }
        val path = URI.create(initialUrl).path.trimLeadingSlash()
        val assetPath = flutterAssets.getAssetFilePathByName(path).trimLeadingSlash()
        view.loadUrl("asset://local/$assetPath")
    }

    override fun getView(): View {
        return view;
    }

    override fun dispose() {
        view.destroy()
    }
}

private class FlutterWebviewClient(val context: Context) : WebViewClient() {
    override fun shouldInterceptRequest(view: android.webkit.WebView, request: WebResourceRequest): WebResourceResponse? {
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
        return when (request.url.scheme) {
            "https", "http" -> {
                context.startActivity(Intent(Intent.ACTION_VIEW, request.url))
                true
            }
            else -> false
        }
    }
}

private fun String.trimLeadingSlash() : String {
    if (this.startsWith("/")) {
        return this.substring(1)
    }
    return this
}