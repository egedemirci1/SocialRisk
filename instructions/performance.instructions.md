---
applyTo: '**'
---

# Flutter Performans Kuralları — Sosyal Risk

Sosyal Risk Flutter projesinde kod yazarken veya refactor yaparken uygulanacak performans ve kalite kuralları. Öncelik sırasına göre uygulanır.

**Öncelik Sırası (Yüksekten Düşüğe):**

`Render Performansı > State Rebuild > Async/Await > Widget Ağacı > Animasyon > Bellek > Mikro-optimizasyon`

---

## 1) Render Performansı (Kritik)

### Widget Rebuild'ini Minimize Et

- `consumer` widget'ını mümkün olan en alt seviyede kullan; büyük widget ağaçlarını gereksiz yere `ConsumerWidget`'a dönüştürme.
- `select()` ile granüler Riverpod aboneliği yap:

```dart
// YANLIŞ: Tüm oyuncu objesi dinleniyor, herhangi bir alan değişince rebuild
final player = ref.watch(playerProvider(playerId));

// DOĞRU: Yalnızca score alanı dinleniyor
final score = ref.watch(playerProvider(playerId).select((p) => p.score));
```

- `const` constructor'ları her mümkün yerde kullan — Flutter const widget'ları rebuild'den muaf tutar.
- Statik JSX eşdeğeri: State içermeyen büyük alt ağaçları ayrı `const` widget'lara çıkar.

### Pahalı Widget'ları Ayır

- Oyuncu listesi, kategori kartları vb. büyük koleksiyonlar için `ListView.builder` / `GridView.builder` kullan.
- Ekran dışı widget'lar için `AutomaticKeepAliveClientMixin` ile gerektiğinde state sakla.
- Uzun çark animasyonu veya sıralama listesi gibi pahalı bölümler için `RepaintBoundary` kullan.

```dart
RepaintBoundary(
  child: FortuneWheel(segments: segments),
)
```

---

## 2) State Rebuild Optimizasyonu (Kritik)

### Riverpod Provider Granülaritesi

- Her provider **tek bir veri parçasını** temsil etmeli.
- Birden fazla ilgisiz değeri tek `StateNotifier`'a doldurma.
- Oda state'i ve oyun state'ini **ayrı provider'larda** yönet.

```dart
// DOĞRU: Granüler providerlar
final roomStatusProvider = StreamProvider.autoDispose<RoomStatus>(...)
final currentPlayerProvider = StreamProvider.autoDispose<Player>(...)
final scoreboard Provider = StreamProvider.autoDispose<List<PlayerScore>>(...)

// YANLIŞ: Her şey tek provider'da
final everythingProvider = StreamProvider<GameFullState>(...)
```

### AnimationController Lifecycle

- `AnimationController` her zaman `TickerProviderStateMixin` ile oluşturulur.
- `dispose()` metodunda `controller.dispose()` çağrılır — bellek sızıntısı önlenir.

```dart
@override
void dispose() {
  _scoreAnimController.dispose();
  _effectAnimController.dispose();
  super.dispose();
}
```

---

## 3) Async/Await Kuralları (Yüksek)

### Stream Abonelikleri

- Firestore / Supabase stream'leri `StreamProvider.autoDispose` ile yönetilir — widget kaldırılınca otomatik iptal edilir.
- `StreamSubscription`'ları manuel yönetiyorsan `cancel()` her zaman `dispose()`'da çağırılır.

```dart
StreamSubscription? _sub;

@override
void dispose() {
  _sub?.cancel();
  super.dispose();
}
```

### Bağımsız Async İşlemleri Paralel Çalıştır

Bağımsız veri yüklemelerini sıralı `await` yerine paralel başlat:

```dart
// YANLIŞ: Sıralı (yavaş)
final room = await fetchRoom(roomId);
final questions = await fetchQuestions();

// DOĞRU: Paralel
final results = await Future.wait([
  fetchRoom(roomId),
  fetchQuestions(),
]);
```

### Build Contextini Async Gap'te Kullanma

```dart
// YANLIŞ
Future<void> joinRoom(BuildContext context) async {
  await roomService.join();
  Navigator.of(context).push(...); // context geçersiz olabilir!
}

// DOĞRU
Future<void> joinRoom(BuildContext context) async {
  await roomService.join();
  if (!context.mounted) return;
  context.go('/game');
}
```

---

## 4) Widget Ağacı Optimizasyonu (Orta-Yüksek)

### Widget Seçimi

- Boyut için `Container` yerine `SizedBox` kullan.
- Sadece renk için `Container` yerine `ColoredBox` kullan.
- Dekorasyon için `Container` yerine `DecoratedBox` kullan.
- `Padding` widget'ı `Container(padding: ...)` yerine tercih et.

### Koşullu Render

```dart
// YANLIŞ: Uzun && zinciri
Widget build(BuildContext context) {
  return state.isLoaded && state.hasPlayer && state.player.isReady && SomeExpensiveWidget();
}

// DOĞRU: Açık koşul
if (!state.isLoaded || !state.hasPlayer || !state.player.isReady) {
  return const LoadingIndicator();
}
return const SomeExpensiveWidget();
```

### Büyük Statik Widget'ları Hoist Et

```dart
// YANLIŞ: Her build'de yeni oluşturuluyor
@override
Widget build(BuildContext context) {
  return Column(children: [
    const SizedBox(height: 32),
    const GameLogo(),  // ✓ const
    _buildDynamicContent(),
  ]);
}

// DOĞRU: Static widget sınıf seviyesinde sabit
static const _logo = GameLogo();
```

---

## 5) Animasyon Performansı (Orta)

### Animasyon Backend

- Basit animasyonlar için `AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher` kullan.
- Karmaşık animasyonlar için `AnimationController` + `Tween` + `AnimatedBuilder`.
- Shader tabanlı efektler (avatar alev/buz) için `CustomPainter` veya `Lottie` paketi.
- Aynı anda 5'ten fazla eş zamanlı animasyon çalıştırma; performans kaybına neden olur.

### Çark Animasyonu

- `FortuneWheel` animasyonu `RepaintBoundary` içinde tutulur.
- Animasyon süresince gereksiz parent rebuild'i önlemek için `IgnorePointer` sar.

---

## 6) Bellek Yönetimi (Orta)

### Görüntü Yönetimi

- Tüm ağ görselleri `cached_network_image` paketi ile önbelleğe alınır.
- Avatar görselleri uygun çözünürlükte istenir (300×300 px yeterli, 4K istemek yasak).
- Büyük listede görüntü widget'larının boyutu `cacheWidth` / `cacheHeight` ile sınırlandırılır.

```dart
CachedNetworkImage(
  imageUrl: player.avatarUrl,
  memCacheWidth: 150,  // 2x DPR için
  memCacheHeight: 150,
)
```

### Provider Temizliği

- Geçici state (oda oturumu) için `autoDispose` kullan.
- Kalıcı state (kullanıcı profili, cüzdan) için `keepAlive` / normal provider kullan.

---

## 7) Ağ ve Realtime Optimizasyonu (Orta)

### Firestore

- Belge başına dinleme yerine koleksiyon bazında dinleme yap (tur sayısı azalır).
- `withConverter` kullanarak tip-güvenli Firestore maping yap.
- Firestore'da sık değişen alanları (ör. `score`) ayrı alt koleksiyon veya belgeye taşı — gereksiz snapshot tetiklemesini azaltır.

### Supabase Realtime

- Tek bir kanal ile birden fazla tablo değişikliğini dinle.
- Oyun bitmişse `channel.unsubscribe()` çağır.

---

## 8) Dart Mikro-Optimizasyonları (Düşük)

- Üyelik kontrolü için `List.contains` yerine `Set.contains` kullan (O(1) vs O(n)).
- Büyük koleksiyonlarda tekrarlı `where().first` yerine `Map` index oluştur.
- `StringBuffer` ile büyük string birleştirme (döngüde `+` operatörü yasak).
- Döngü içinde RegExp derlememe; sınıf seviyesinde `static final _regex = RegExp(...)` tut.
- `List.generate` ile sabit boyutlu liste oluştur; `addAll` döngüsü yerine.

```dart
// YANLIŞ: Döngüde RegExp derleme
for (final item in items) {
  if (RegExp(r'\d+').hasMatch(item)) { ... }  // Her iterasyonda derleniyor
}

// DOĞRU: Önceden derle
static final _numberRegex = RegExp(r'\d+');
for (final item in items) {
  if (_numberRegex.hasMatch(item)) { ... }
}
```

---

## 9) Offline & Bağlantı Yönetimi (Önemli)

- **Firestore:** `FirebaseFirestore.instance.settings` ile offline persistence etkinleştir.
- Ağ bağlantısı kesilince kullanıcıya `SnackBar` ile bilgi ver.
- Kritik oyun aksiyonları (oy verme, puan gönderme) retry mekanizması ile çalışır.
- `connectivity_plus` paketi ile ağ durumunu izle; bağlantı kopunca oyun duraklat.

---

## 10) Platform Özel Optimizasyonlar

### Android

- `android/app/build.gradle`'da `minSdkVersion 21` minimum.
- `proguard-rules.pro` ile Firebase / Riverpod class'larını shrinkten koru.

### iOS

- `NSPhotoLibraryUsageDescription` ve `NSCameraUsageDescription` info.plist'e eklenir (avatar yükleme için).
- `flutter build ipa --release` ile archive build yapılır.

### Web (Opsiyonel)

- `flutter build web --release --web-renderer canvaskit` ile production build.
- Multiplayer realtime için web'de `dart:html` yerine platform-agnostic Firebase SDK kullanılır.

---

## Upstream Referans İndeksi (Flutter Performans)

| Konu                         | Referans                                          |
|------------------------------|---------------------------------------------------|
| Widget rebuild optimizasyonu | Flutter docs: `const` widgets, RepaintBoundary    |
| Riverpod best practices      | riverpod.dev / docs                               |
| Firestore performansı        | Firebase docs: Structuring Data                   |
| Flutter profiling            | `flutter run --profile` + DevTools                |
| Animasyon API'ları           | Flutter docs: Animation & motion                  |
| Memory profiling             | Flutter DevTools: Memory tab                      |
