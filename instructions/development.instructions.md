---
applyTo: '**'
---

# Copilot / AI Asistan Kuralları — Sosyal Risk (Flutter)

Sosyal Risk projesinde yapay zeka yardımcısı (Copilot / Antigravity) için üretim kalitesi standartları.

---

## 0) Genel Yaklaşım

- Değişiklikleri minimal tut; yalnızca isteneni değiştir.
- Her değişiklik production-grade ve projenin mevcut yapısıyla tutarlı olmalıdır.
- Mod değiştirme önerisi yapma; bağlamı oku ve göreve başla.

---

## 1) Dart Kod Standartları

- `const` constructor'ları maksimize et; `const` keyword'ü mümkün olan her yerde kullan.
- `var` yerine açık tip tanımı tercih et (Dart type inference açıksa kısaca `final` yeterlidir).
- `late` keyword'ünü yalnızca kaçınılmaz durumlarda kullan; nullable türleri tercih et.
- `dynamic` kullanma; her zaman type-safe yaz.
- `async/await` ile birlikte `try/catch` bloklarını uygun katmanlara yerleştir (Repository hariç).
- Dosya adlandırma: `snake_case.dart`. Sınıf adlandırma: `PascalCase`.
- Her dosya **500 satırı geçmemeli**; geçerse ayrı widget/class dosyalarına böl.

---

## 2) Import Sıralaması

1. Dart SDK importları (`dart:async`, `dart:ui` vb.)
2. Flutter importları (`package:flutter/…`)
3. Üçüncü taraf paketler (`package:riverpod/…`, `package:firebase_core/…` vb.)
4. Proje içi mutlak importlar (`package:social_risk/…`)
5. Göreli importlar (`../`, `./`)

Her grup arasında boş satır bırakılır.

---

## 3) Riverpod Kullanım Kuralları

- Provider tanımları dosyanın en üstünde, class/widget dışında yer alır.
- `ref.watch` yalnızca `build` metodunda; `ref.read` aksiyon/callback içinde kullanılır.
- `ref.listen` state değişikliklerine tepki için (snackbar, navigation) kullanılır.
- `autoDispose` modifier'ı geçici (oda-spesifik) state için kullanılır.
- `family` modifier'ı parametrik provider'lar (ör. `playerProvider(playerId)`) için kullanılır.
- Büyük provider tree'ye sahip ekranlarda `select()` ile granüler abonelik yapılır.

```dart
// Doğru kullanım
final playerScoreProvider = StreamProvider.autoDispose.family<int, String>((ref, playerId) {
  return ref.watch(gameRepositoryProvider).watchPlayerScore(playerId);
});
```

---

## 4) State Management Kuralları

- `StatefulWidget` kullanımını minimize et; Riverpod ile state yönet.
- Saf UI state'i (animasyon flag, focus) için `StatefulWidget` kabul edilebilir.
- Global state asla `InheritedWidget` veya `Provider` (flutter_provider) ile yönetilmez; **yalnızca Riverpod**.
- `BuildContext` hiçbir zaman `async gap` sonrasında doğrudan kullanılmaz:

```dart
// YANLIŞ
Future<void> doSomething(BuildContext context) async {
  await someAsyncCall();
  Navigator.of(context).pop(); // context geçersiz olabilir!
}

// DOĞRU
Future<void> doSomething(BuildContext context) async {
  await someAsyncCall();
  if (!context.mounted) return;
  Navigator.of(context).pop();
}
```

---

## 5) Routing (GoRouter)

- Tüm route tanımları `lib/core/router/app_router.dart` içinde merkezi olarak yönetilir.
- `Navigator.push` / `Navigator.pop` doğrudan kullanılmaz; GoRouter `context.go()`, `context.push()` kullanılır.
- Route parametreleri tip-güvenli `GoRouterState.pathParameters` ile okunur.
- Auth-guard: `GoRouter.redirect` ile oturum kontrolü yapılır.

---

## 6) Firebase / Supabase Erişim Kuralları

- Firestore / Supabase SDK çağrıları **yalnızca data source katmanında** (`lib/features/*/data/`) yapılır.
- Widget veya provider içinde `FirebaseFirestore.instance` çağrısı yasaktır.
- Cloud Firestore stream'leri `StreamProvider` ile sarmalanır.
- Supabase Realtime channel'ları `StreamController` ile sarmalanarak `Stream` olarak sunulur.
- Transaction'lar kesinlikle **sunucu taraflı** (Cloud Functions / RPC) gerçekleştirilir.

---

## 7) Hata Yönetimi

- Data source katmanı exception fırlatır (`throw GameException(...)`).
- Repository katmanı exception'ı yakalayana kadar propogation'a izin verir.
- Provider katmanı `AsyncValue.error()` ile surface eder.
- Widget katmanı `.when(error: (e, st) => ErrorWidget(e))` ile işler.
- Tüm production hataları `FirebaseCrashlytics.instance.recordError(e, st)` ile loglanır.

```dart
// Provider katmanı örneği
class GameNotifier extends AsyncNotifier<GameState> {
  @override
  Future<GameState> build() async {
    try {
      return await ref.read(gameRepositoryProvider).getGameState();
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'GameNotifier.build');
      rethrow;
    }
  }
}
```

---

## 8) Puan ve Oyun Mantığı

- Puan hesaplamaları **sunucu taraflı** gerçekleştirilir (Cloud Function / Edge Function).
- İstemci taraflı puan hesabı yalnızca optimistik UI güncellemesi için kullanılır; sunucu doğrulaması beklenir.
- Katlanır ceza formülü: `penalty = basePenalty * (3 ^ passStreak)` — hesaplama sunucuda yapılır.
- Oylama sonucu: `finalScore = votingResult * questionMultiplier` — sunucu doğrular.

---

## 9) Performans Kuralları

- `build` metodunda ağır hesaplama yapma; `compute()` fonksiyonu veya `Isolate` kullan.
- `ListView.builder` / `GridView.builder` ile lazy rendering uygula.
- Resim önbellekleme için `cached_network_image` paketi kullanılır.
- `AnimationController` her zaman `dispose()` metodunda temizlenir.
- Widget ağacında gereksiz `rebuild` önlemek için `Consumer` widget'ını en alt seviyede kullan.

---

## 10) İçerik Güvenlik Politikası

- Soru/görev içerikleri cinsellik, şiddet ve nefret söylemi içeremez.
- İçerik moderasyonu Cloud Function seviyesinde gerçekleştirilir.
- Kullanıcı tarafından oluşturulan içerik (kullanıcı adı vb.) sunucu tarafında filtrelenir.

---

## 11) Test Yazım Kuralları

- Her repository implementasyonu için unit test yazılır.
- Provider logic'i `ProviderContainer` ile izole ortamda test edilir.
- Widget testleri kritik oyun ekranları (oylama, puan ekranı) için uygulanır.
- Flutter integration testleri `patrol` veya `flutter_test` ile yazılır.
- Daha fazla bilgi için: [`testing.instructions.md`](testing.instructions.md)

---

## 12) Yasaklı Kalıplar

Asla şunlara izin verilmez:

- Widget içinde `FirebaseFirestore.instance` / `Supabase.instance` doğrudan kullanımı
- `print()` production build'de
- `dynamic` tip kullanımı
- `StatefulWidget` içinde ağ isteği
- Provider dışında mutable global state
- `context` kullanımı `async gap` sonrasında `mounted` kontrolü olmadan
- Magic numbers (sabit sayılar doğrudan kodda)
