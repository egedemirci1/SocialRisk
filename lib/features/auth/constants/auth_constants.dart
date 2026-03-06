/// Google Sign-In için Android/iOS'ta Firebase Auth kullanırken gerekli Web Client ID.
/// Değeri almak için: Google Cloud Console → APIs & Services → Credentials →
/// OAuth 2.0 Client IDs → "Web application" tipindeki client'ın Client ID'si.
/// Boş bırakırsan serverClientId kullanılmaz (eski davranış; birçok cihazda hata verir).
const String? kGoogleSignInWebClientId = '327029132308-mlupqmpmbh18lj9bbnpe578otrp9u9vp.apps.googleusercontent.com';
