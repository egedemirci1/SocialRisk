import 'dart:js_interop';

@JS()
extension type Window._(JSObject _) implements JSObject {
  external void removeSplashWhenReady();
}

@JS('window')
external Window get _window;

/// Removes the HTML native splash overlay (web only). Call when app is ready to show login/home.
void removeNativeSplash() {
  try {
    _window.removeSplashWhenReady();
  } catch (_) {}
}
