import 'dart:html' as html;

/// Removes the HTML native splash overlay (web only). Call when app is ready to show login/home.
void removeNativeSplash() {
  try {
    html.window.callMethod('removeSplashWhenReady');
  } catch (_) {}
}
