# 🔍 Kapsamlı Flutter Proje Denetim Raporu

> **Tarih:** 2026-03-07 | **Denetçi:** Senior Flutter & UI/UX QA | **Dosya Sayısı:** 92 Dart, 18 Test

---

## 🚨 Kritik Hatalar (Hemen Çözülmeli)

### 1. Duplike `acceptTask()` Çağrısı

[task_screen.dart:77-78](file:///c:/SocialRisk/lib/features/game/presentation/task_screen.dart#L74-L83)

```dart
// ❌ BUG: acceptTask iki kez arka arkaya çağrılıyor!
await ref.read(gameControllerProvider.notifier).acceptTask(widget.gameId);
await ref.read(gameControllerProvider.notifier).acceptTask(widget.gameId); // ← SİL
```

**Etki:** Firebase'de görevi çift kez kabul etmeye çalışır → race condition, Firestore status hatası, ya da beklenmeyen durum geçişi.

**Düzeltme:** 78. satırdaki ikinci `acceptTask` çağrısını sil.

---

### 2. `ref.listen` — `build()` İçinde Tekrarlanarak Kayıt Oluyor

Bu sorun **3 ekranda** var ve her `build()` çağrısında yeni bir listener ekliyor:

| Dosya | Satır | Listener |
|---|---|---|
| [task_screen.dart](file:///c:/SocialRisk/lib/features/game/presentation/task_screen.dart#L132-L141) | 132–141 | Card animasyonu tetikleme |
| [task_screen.dart](file:///c:/SocialRisk/lib/features/game/presentation/task_screen.dart#L268-L304) | 268–304 | `_handleStatusChanges` (`build` içinden çağrılıyor) |
| [voting_screen.dart](file:///c:/SocialRisk/lib/features/voting/presentation/voting_screen.dart#L108-L121) | 108–121 | Game status dinleyici |
| [round_result_screen.dart](file:///c:/SocialRisk/lib/features/game/presentation/round_result_screen.dart#L96-L113) | 96–113 | Game status dinleyici |

**Neden sorun:** Riverpod `ref.listen` fonksiyonu `build()` içinde çağrılmalıdır (Riverpod otomatik yönetir), ancak `_handleStatusChanges` gibi ayrı bir fonksiyon olarak çağrıldığında, her rebuild'de aynı listener tekrar kaydolur.

**Düzeltme:** `ref.listen` çağrılarını doğrudan `build()` fonksiyonunun en üstüne taşı. `_handleStatusChanges` fonksiyonunu kaldırıp, içeriğini `build()` içindeki `ref.listen` callback'ine entegre et.

---

### 3. `_passTask` — `setState` mounted Check Hatası

[task_screen.dart:85-101](file:///c:/SocialRisk/lib/features/game/presentation/task_screen.dart#L85-L101)

```dart
Future<void> _passTask() async {
    setState(() => _isPassing = true);
    try {
      ...
      setState(() => _contentRevealed = false); // ❌ mounted kontrolü yok
      _cardController.reset();
    } finally {
      if (mounted) setState(() => _isPassing = false);
    }
}
```

**Etki:** Async await sonrası `mounted` kontrolü yapılmadan `setState` çağrılıyor → widget dispose edildiyse crash.

---

### 4. Force Unwrap Riski: `currentUserProvider`

[round_result_screen.dart:508](file:///c:/SocialRisk/lib/features/game/presentation/round_result_screen.dart#L508)

```dart
userId: ref.read(currentUserProvider)!.uid,  // ❌ Null ise crash
```

**Düzeltme:** Null kontrolü ekle ya da guard clause kullan.

---

## ⚠️ Uyarılar ve Test İyileştirmeleri

### Test Kalitesi Sorunları

#### A. Widget Testlerinde Eksik Etkileşim Senaryoları

| Test | Eksik |
|---|---|
| `game_card_test.dart` | Uzun content'te overflow kontrolü yok, scroll testi yok |
| `voting_panel_test.dart` | Oy verdikten sonra buton durumu (disabled) test edilmemiş |
| `primary_button_test.dart` | Loading durumunda tıklama engelleme testi yok |

#### B. Yalancı-Pozitif (False Positive) Test Riski

[app_helpers_edge_test.dart:11](file:///c:/SocialRisk/test/unit/app_helpers_edge_test.dart#L11) — 100 kod üretip 95 benzersiz beklentisi istatistiksel, deterministik değil. Nadiren de olsa fail edebilir.

#### C. Eksik Widget Test Senaryoları

- ❌ **Scroll testi yok:** Hiçbir widget testinde scroll davranışı test edilmemiyor.
- ❌ **Tap event sonrası durum testi:** VotingPanel'de oy verdikten sonra butonun disabled olması kontrol edilmiyor — sadece `voteCount` kontrol ediliyor.
- ❌ **Error state widget testi yok:** Hata durumunda gösterilen UI hiç test edilmemiyor.
- ❌ **Loading state widget testi yok:** Loading overlay'ler hiç test edilmiyor.

#### D. Test Kapsamı Boşlukları

| Bileşen | Mevcut Test | Eksik Olan |
|---|---|---|
| `StoreScreen` | 0 widget test | Satın alma akışı, bakiye kontrolü |
| `LobbyScreen` | 0 widget test | Hazır butonu, oyun başlatma |
| `CreateRoomScreen` | 0 test | Form validation, slider değerleri |
| `ProfileScreen` | 0 widget test | Tab geçişleri, avatar yükleme |
| `LoginScreen` | 0 widget test | Anonim giriş, Google sign-in |

---

## 🎨 UI/UX ve Responsive Önerileri

### 1. Renk Tutarsızlığı — `Colors.*` vs `AppColors`

**Sorun:** Proje genelinde ~60+ yerde raw `Colors.red`, `Colors.green`, `Colors.orange`, `Colors.amber` kullanılmış. `AppColors` sabitleri tanımlı olmasına rağmen bypass edilmiş.

| Raw Renk | Kullanım Sayısı | `AppColors` Karşılığı |
|---|---|---|
| `Colors.red/redAccent` | ~10 | `AppColors.fire` veya `AppColors.voteNegative` |
| `Colors.green/greenAccent` | ~27 | `AppColors.votePositive` veya `AppColors.secondary` |
| `Colors.orange/orangeAccent` | ~8 | `AppColors.passWarning` veya `AppColors.voteNeutral` |
| `Colors.amber` | ~7 | `AppColors.glow` veya `AppColors.primary` |

**Etki:** Tema değiştirmek istediğinde 60+ yeri tek tek düzeltmen gerekir. Single Source of Truth (SSoT) prensibi ihlal ediliyor.

**Öneri:** `AppColors` sınıfına `success`, `warning`, `danger` gibi semantik renkler ekle ve tüm raw kullanımları bunlarla değiştir.

---

### 2. Kontrast ve Erişilebilirlik (Accessibility)

| Konum | Sorun | Oran |
|---|---|---|
| `Colors.white12` overlay border | Koyu bg üzerinde neredeyse görünmez | ~1.3:1 |
| `Colors.white30` bekleme metni | Okunabilirlik WCAG AA standartını karşılamıyor | ~2.1:1 |
| `Colors.white38` hover/disabled metinler | Minimum okunabilirliğin altında | ~2.5:1 |

**WCAG AA standardı** en az **4.5:1** kontrast oranı gerektirir (küçük metin için).

---

### 3. Hardcoded Pixel Boyutları

| Dosya | Satır | Değer | Risk |
|---|---|---|---|
| `custom_deck_editor_screen.dart` | 325-326 | `width: 300, height: 300` | Küçük mobillerde taşabilir |
| `waiting_screen.dart` | 189-190 | `width: 100, height: 100` | Düşük risk ama responsive değil |
| `profile_screen.dart` | 502 | `width: 100` | Cosmetic chip genişliği sabit |
| `login_screen.dart` | 210 | `height: 180` | Logo büyüklüğü sabit |

**Öneri:** `MediaQuery.of(context).size` veya `FractionallySizedBox` kullan.

---

## 💡 Geliştiriciye Tavsiyeler

### 1. Boş `setState(() {})` Anti-Pattern

[join_room_screen.dart:47, 241, 299](file:///c:/SocialRisk/lib/features/room/presentation/join_room_screen.dart#L47)

```dart
setState(() {}); // ❌ Neyi yeniden çiziyor? Gereksiz tam rebuild tetikler
```

**3 yerde** boş `setState` var. Bu, tüm widget ağacını yeniden çizer. Focus listener zaten `setState` çağırıyor, fazladan çağrılar performans kaybı yaratır.

### 2. `VisualCountdownTimer` — `TickerProviderStateMixin` Aşırı Kullanımı

[voting_screen.dart:409-410](file:///c:/SocialRisk/lib/features/voting/presentation/voting_screen.dart#L409-L410)

`TickerProviderStateMixin` kullanılmış ama sadece 2 controller var. `SingleTickerProviderStateMixin` yetersiz olduğu için doğru kullanım ama dikkat: Bu widget her vote ekranında tam sayfa rebuild'e sebep olabilir.

### 3. `_FloatingPsychologicalTexts` — `Random()` her seferde yeni instance

[voting_screen.dart:515-521](file:///c:/SocialRisk/lib/features/voting/presentation/voting_screen.dart#L515)

```dart
// ❌ Her Timer callback'inde 3 yeni Random() instance oluşturuluyor
_currentText = _texts[Random().nextInt(_texts.length)];
```

**Düzeltme:** `final _rng = Random();` field olarak tanımla ve tekrar kullan.

### 4. `debugPrint` Temizliği (Prodüksiyon)

6 adet `debugPrint` çağrısı prodüksiyon kodunda bırakılmış. Bunlar `kDebugMode` kontrolüne alınmalı:

```dart
if (kDebugMode) debugPrint('...');
```

### 5. Eksik `const` Constructor'lar

Birçok stateless widget'ta `const` constructor eklenebilir (`_ScoreRow`, `_FeedbackButton` vb. zaten `const` ama `_FloatingPsychologicalTexts` eksik).

### 6. `error` State'leri — Salt Metin Gösterimi

Birçok ekranda hata durumu düz `Text('Hata: $e')` olarak gösterilmiş:
- [task_screen.dart:263](file:///c:/SocialRisk/lib/features/game/presentation/task_screen.dart#L263)
- [voting_screen.dart:330](file:///c:/SocialRisk/lib/features/voting/presentation/voting_screen.dart#L330)
- [round_result_screen.dart:141](file:///c:/SocialRisk/lib/features/game/presentation/round_result_screen.dart#L141)
- [profile_screen.dart:474, 593](file:///c:/SocialRisk/lib/features/auth/presentation/profile_screen.dart#L474)

**Öneri:** Tutarlı bir `ErrorWidget` bileşeni oluştur (ikon + mesaj + "Tekrar Dene" butonu).

---

## 📊 Özet Tablo

| Kategori | Bulgu Sayısı | Öncelik |
|---|---|---|
| 🚨 Kritik Bug | 4 | Hemen |
| ⚠️ Test İyileştirmesi | 5 ekran + 3 widget | Yüksek |
| 🎨 Renk Tutarsızlığı | ~60 satır | Orta |
| 🎨 Accessibility | 3 kontrast sorunu | Orta |
| 📐 Hardcoded Boyut | 4 dosya | Düşük-Orta |
| 💡 Performans | 3 boş setState + 1 Random | Orta |
| 💡 Kod Temizliği | 6 debugPrint + error widget | Düşük |
