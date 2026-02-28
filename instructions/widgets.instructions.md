---
applyTo: '**'
---

# Widget Sistemi — Sosyal Risk (Flutter)

Bu dosya, **Sosyal Risk** oyununun Flutter widget mimarisini, tasarım sistemini ve yeniden kullanılabilir bileşen standartlarını tanımlar.

---

## Tasarım Sistemi

### Renk Paleti

```dart
// lib/core/constants/app_colors.dart
class AppColors {
  // Arka plan
  static const background       = Color(0xFF0D0D1A); // Derin lacivert-siyah
  static const surface          = Color(0xFF1A1A2E); // Kart/panel yüzeyi
  static const surfaceElevated  = Color(0xFF16213E); // Yükseltilmiş yüzey

  // Vurgu
  static const primary          = Color(0xFFE94560); // Tutkulu kırmızı
  static const secondary        = Color(0xFF0F3460); // Derin mavi
  static const accent           = Color(0xFFFFD700); // Puan altını

  // Oyun durumu renkleri
  static const fire             = Color(0xFFFF4500); // Alev efekti
  static const ice              = Color(0xFF00BFFF); // Buz efekti
  static const glow             = Color(0xFF9D4EDD); // Parıltı efekti

  // Oylama renkleri
  static const votePositive     = Color(0xFF4CAF50); // Beğendim
  static const voteNeutral      = Color(0xFFFF9800); // Nötr
  static const voteNegative     = Color(0xFFF44336); // Beğenmedim

  // Ceza / Pas
  static const penalty          = Color(0xFFE53935); // Eksi puan
  static const passWarning      = Color(0xFFFFC107); // Pas uyarısı
}
```

### Tipografi

```dart
// lib/core/constants/app_text_styles.dart
// Google Fonts: Nunito (başlık), Inter (gövde)
class AppTextStyles {
  static final displayLarge  = GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w800);
  static final displayMedium = GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w700);
  static final headlineMedium= GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700);
  static final titleLarge    = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600);
  static final bodyMedium    = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400);
  static final labelSmall    = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.2);
}
```

---

## Klasör Yapısı

```
lib/shared/widgets/
├── avatar/
│   ├── player_avatar.dart           # Yuvarlak fotoğraf + efekt overlay
│   ├── avatar_effect_overlay.dart   # Alev / buz / parıltı efektleri
│   └── avatar_upload_button.dart    # Fotoğraf yükleme butonu
├── buttons/
│   ├── primary_button.dart          # Ana aksiyon butonu
│   ├── danger_button.dart           # Kırmızı tehlike butonu (Pas/Red)
│   └── icon_action_button.dart      # İkon + metin buton
├── cards/
│   ├── game_card.dart               # Soru/görev kartı
│   ├── player_score_card.dart       # Oyuncu puan kartı
│   └── category_card.dart           # Kategori seçim kartı
├── voting/
│   ├── voting_panel.dart            # Oylama paneli (3 buton)
│   └── vote_result_bar.dart         # Oylama sonuç çubuğu
├── wheel/
│   └── fortune_wheel.dart           # Çark animasyonu (Klasik Mod)
├── dialogs/
│   ├── confirm_dialog.dart          # Onay diyaloğu
│   └── game_over_dialog.dart        # Oyun sonu ekranı
├── score/
│   ├── score_counter.dart           # Animasyonlu puan sayacı
│   └── leaderboard_tile.dart        # Sıralama listesi öğesi
└── common/
    ├── gradient_container.dart      # Gradient arka plan konteyneri
    ├── shimmer_loading.dart         # Yükleme skeleton
    └── countdown_timer.dart         # Geri sayım widget'ı
```

---

## Temel Widget'lar

### PlayerAvatar

Oyuncu fotoğrafını yuvarlak çerçevede gösterir. Puan durumuna göre animasyonlu efekt overlay'i ekler.

```dart
PlayerAvatar(
  imageUrl: player.avatarUrl,
  displayName: player.displayName,
  effect: AvatarEffect.fire,   // none | fire | ice | glow
  size: AvatarSize.medium,     // small | medium | large
  isCurrentPlayer: true,
)
```

**Kurallar:**
- `CachedNetworkImage` ile fotoğraf önbelleğe alınır.
- Efekt overlay'leri `Stack` + `AnimatedOpacity` ile uygulanır.
- `effect: AvatarEffect.none` durumunda ek render maliyeti yoktur.

---

### VotingPanel

Görev tamamlandığında tüm diğer oyuncuların ekranında gerçek zamanlı belirir.

```dart
VotingPanel(
  onVote: (VoteValue vote) => ref.read(voteProvider.notifier).submitVote(vote),
  isEnabled: !hasVoted,
  timeLimit: Duration(seconds: 15),
)
```

**Kurallar:**
- Her oyuncu yalnızca bir kez oy kullanabilir; buton `onVote` çağrısının ardından devre dışı kalır.
- Geri sayım süresi dolduğunda panel otomatik kapanır.
- Kendi görevini yapan oyuncu `VotingPanel` görmez.

---

### FortuneWheel (Klasik Mod)

```dart
FortuneWheel(
  segments: categories,          // List<WheelSegment>
  onSpinComplete: (segment) => ...,
  isSpinning: state.isSpinning,
)
```

**Kurallar:**
- Çark animasyonu `flutter_fortune_wheel` paketi veya özel `CustomPainter` ile yapılır.
- Spin sonucu Firebase Cloud Function tarafından doğrulanır (client-side seed güvenilmez).
- Animasyon süresi 3-5 saniye; ses efekti için `just_audio` kullanılır.

---

### CategoryCard (Ekonomi Modu)

```dart
CategoryCard(
  category: category,
  isLocked: category.isLockedThisRound,
  currentMultiplier: category.multiplier,
  onSelect: () => ...,
  visibility: GameVisibility.open,  // open | closed
)
```

**Kurallar:**
- `GameVisibility.closed` modunda soru içeriği gösterilmez, yalnızca kategori adı ve çarpan görünür.
- `isLocked: true` durumunda kart gri ve dokunulamaz görünür.
- Seçim onaylanınca bir daha geri dönülemez; `ConfirmDialog` ile onay alınır.

---

### ScoreCounter

Puanların animasyonlu sayı geçişiyle güncellenmesini sağlar.

```dart
ScoreCounter(
  score: player.score,
  delta: scoreDelta,   // pozitif veya negatif
  duration: Duration(milliseconds: 800),
)
```

---

## Widget Geliştirme Kuralları

### Genel

- Her widget dosyası **tek bir sorumluluğa** sahip olmalıdır.
- Widget'lar `StatelessWidget` önceliklidir; sadece gerektiğinde `StatefulWidget` kullanılır.
- Riverpod ile entegre widget'lar `ConsumerWidget` / `ConsumerStatefulWidget` olarak tanımlanır.
- `BuildContext` asenkron boşlukta (`async gap`) kullanılmaz; widget'ın mounted durumu kontrol edilir.

### Performans

- Uzun listeler (oyuncu listesi, sıralama) için `ListView.builder` kullanılır.
- Pahalı hesaplamalar `select()` ile granüler state aboneliğiyle optimize edilir.
- Animasyonlar için `AnimationController`'lar `TickerProviderStateMixin` ile yönetilir ve dispose edilir.
- `const` constructor kullanımı maksimize edilir.

### Responsive ve Ekran Boyutu

- Minimum desteklenen ekran: 360×640 px.
- `MediaQuery` veya `LayoutBuilder` ile tablet/büyük ekran uyumluluğu sağlanır.
- `SafeArea` ile notch ve system UI çakışmaları önlenir.

### Erişilebilirlik

- Her interaktif elemana `Semantics` widget'ı veya `semanticLabel` eklenir.
- Renk kontrastı WCAG AA standardını karşılamalıdır.
- Dokunma hedefi minimum **48×48 dp** olmalıdır.

---

## Animasyon Standartları

| Animasyon                  | Süre      | Eğri                   |
|---------------------------|-----------|------------------------|
| Puan güncelleme           | 800ms     | `Curves.easeInOut`     |
| Oylama paneli belirme     | 300ms     | `Curves.easeOut`       |
| Avatar efekt transition   | 500ms     | `Curves.easeInOut`     |
| Çark dönüşü               | 3000ms    | `Curves.decelerate`    |
| Ekran geçişi (GoRouter)   | 250ms     | `Curves.easeInOut`     |
| Puan ceza sarsıntısı      | 400ms     | `ShakeCurve` (custom)  |

---

## Tema Kurulumu

```dart
// lib/core/theme/app_theme.dart
ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
  ),
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
);
```

- Uygulama **yalnızca dark theme** destekler (oyun atmosferi gereği).
- Light mode desteği eklenmez.

---

## Yasak Pattern'ler

- Widget içinde `FirebaseFirestore.instance` / `SupabaseClient.instance` doğrudan kullanımı.
- `setState` ile sunucudan gelen state yönetimi (Riverpod kullanılır).
- `print()` ifadelerinin production build'de kalması.
- Magic number kullanımı; sabitler `AppConstants` / `AppColors` içinde tanımlanır.
- `Container` yerine `SizedBox` (boyut), `ColoredBox` (renk), `DecoratedBox` (dekorasyon) tercih edilir.
