# asset_webview

A Flutter plug-in providing a native web view that loads Flutter assets.
Useful for embdding HTML content in your application, for example to display
help content.

## Usage

Usage involves the following steps:

1. Add HTML assets to your application including CSS and images as needed.

   A `pubspec.yaml` entry might look as follows:

   ```yaml
   flutter:
     assets:
       - help/
   ```

   example: [example/pubspec.yaml](example/pubspec.yaml)

2. Add web content to your application assets.

   example: [example/help](example/help)

3. Add the `AssetWebview` widget to your application.

   Create a page as follows:

   ```dart
   return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example Usage of asset_webview'),
        ),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: AssetWebview(initialUrl: 'asset://local/help/index.html'))
        ])),
      ),
    );
   ```

   example: [example/lib/main.dart](example/lib/main.dart)

See [the sample application](example) for a complete application.

### In-App Navigation Links

To link from web content to a named route in the app, do the following:

1. Create a function that can provide a `BuildContext`

    ```dart
    BuildContext _currentContext() => _navigatorKey.currentContext!;
    final _navigatorKey = GlobalKey<NavigatorState>();
    ```

2. Pass a `NavigationAssetWebviewController` to the `AssetWebview`

    ```dart
    AssetWebview(
      initialUrl: 'asset://local/help/index.html',
      controller: NavigationAssetWebviewController(_currentContext)
    )
    ```

3. Provide named routes in the application

    ```dart
    MaterialApp(
      navigatorKey: _navigatorKey,
      ...
      routes: {"about": (context) => AboutPage()},
    );
    ```

4. Place navigation links in the html content:

    ```dart
    <a href="navigation://about">About</a>
    ```


See [the sample application](example) for a complete application.

### Troubleshooting

**My assets aren't showing up (not found)**

Check the `pubspec.yaml` indentation. `assets` must be indented one level under `flutter`.

## Maintaining

### Editing Android Plugin Files

Per [Flutter docs](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#step-2b-add-android-platform-code-ktjava) when opening in IntelliJ
open `example/android/build.gradle`

### Commands

publishing: `flutter pub publish`

## License

Copyright 2021 David Green

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.