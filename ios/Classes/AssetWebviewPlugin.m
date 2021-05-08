#import "AssetWebviewPlugin.h"
#if __has_include(<asset_webview/asset_webview-Swift.h>)
#import <asset_webview/asset_webview-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "asset_webview-Swift.h"
#endif

@implementation AssetWebviewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAssetWebviewPlugin registerWithRegistrar:registrar];
}
@end
