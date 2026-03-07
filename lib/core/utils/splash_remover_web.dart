import 'dart:js' as js;

/// Removes the HTML native splash overlay (web only). Call when app is ready to show login/home.
void removeNativeSplash() {
  try {
    js.context.callMethod('removeSplashWhenReady');
  } catch (_) {}
}
