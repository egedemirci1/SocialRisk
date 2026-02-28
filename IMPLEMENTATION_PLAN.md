# 🚀 Sosyal Risk — 4 Saatlik MVP Sprint Planı (v3 — Instructions Uyumlu)

## Konsept

Herkes **aynı fiziksel ortamda**, kendi telefonundan bağlanıyor. Bir kişi oda açıyor, diğerleri **oda koduyla** katılıyor. Sıra tabanlı parti oyunu.

> [!IMPORTANT]
> Bu plan, `instructions/` klasöründeki 5 dosyanın kurallarına **tam uyumludur**:
> - `architecture.instructions.md` → Feature-first katman mimarisi, Firestore şeması
> - `development.instructions.md` → Dart standartları, Riverpod kuralları
> - `widgets.instructions.md` → Dark theme, renk paleti, widget kataloğu
> - `performance.instructions.md` → Render & state rebuild optimizasyonu
> - `testing.instructions.md` → Test yapısı (MVP sonrası uygulanacak)

---

## ⚡ MVP Kapsam

| ✅ MVP'de VAR | ❌ Sonraya Kaldı |
|---|---|
| Anonim giriş (isim yaz, gir) | Google Sign-In, profil fotoğrafı |
| Oda oluştur / oda koduyla katıl | Ekonomi Modu |
| 2-8 oyuncu lobi | Çark animasyonu (basit random) |
| Yalnızca Klasik mod | Kozmetik mağaza / Meta-game |
| Görev göster → Kabul/Pas | Avatar efektleri (alev, buz) |
| Oylama (Beğen/Nötr/Beğenme) | Ses efektleri |
| Pas ceza sistemi (katlanan) | Açık/Kapalı mod (MVP'de hep açık) |
| Puan hedefi VEYA tur sayısı ile bitiş | i18n (MVP'de sadece Türkçe hardcode) |
| Oyun sonu kazanan ekranı | CI/CD, test coverage |

---

## 🤝 İlk Kez Birlikte Proje: Git Workflow

```
1. Ege → Flutter projesini oluşturur, GitHub'a pusher
2. Ata → Repoyu klonlar
3. Her ikiniz kendi branch'inizde çalışırsınız:
   - Ege:  git checkout -b ege/backend
   - Ata:  git checkout -b ata/frontend
4. push + Pull Request → main'e merge
```

> [!CAUTION]
> **AYNI DOSYAYI AYNI ANDA DÜZENLEMEYİN.** Aşağıdaki dosya sahipliği haritasına uyun. Birleştirme Faz 4'te yapılacak.

### Antigravity ile Çalışma
- **Ege**: "Backend task'larımı yapıyorum, instructions kurallarına uy" diye context verin
- **Ata**: "Frontend/presentation task'larımı yapıyorum, instructions kurallarına uy" diye context verin

---

## 🗓️ 4 Saatlik Zaman Çizelgesi

```
[0:00 - 0:30]  Faz 1: Proje Kurulumu (Ege lider)
[0:30 - 1:30]  Faz 2: Auth + Oda + Lobi (Paralel)
[1:30 - 3:00]  Faz 3: Oyun Döngüsü (Paralel)
[3:00 - 4:00]  Faz 4: Birleştirme + Test + Bugfix (Birlikte)
```

---

## 📁 Klasör Yapısı (architecture.instructions.md Uyumlu)

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart              → ATA
│   │   ├── app_text_styles.dart         → ATA
│   │   └── game_constants.dart          → EGE
│   ├── theme/
│   │   └── app_theme.dart               → ATA
│   ├── router/
│   │   └── app_router.dart              → EGE
│   └── utils/
│       └── helpers.dart                 → EGE
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   └── login_screen.dart        → ATA
│   │   ├── providers/
│   │   │   └── auth_provider.dart       → EGE
│   │   ├── domain/
│   │   │   └── auth_repository.dart     → EGE (abstract)
│   │   └── data/
│   │       └── firebase_auth_source.dart → EGE
│   ├── room/
│   │   ├── presentation/
│   │   │   ├── create_room_screen.dart  → ATA
│   │   │   ├── join_room_screen.dart    → ATA
│   │   │   └── lobby_screen.dart        → ATA
│   │   ├── providers/
│   │   │   └── room_provider.dart       → EGE
│   │   ├── domain/
│   │   │   ├── room_entity.dart         → EGE
│   │   │   └── room_repository.dart     → EGE (abstract)
│   │   └── data/
│   │       ├── room_model.dart          → EGE
│   │       └── firebase_room_source.dart → EGE
│   ├── game/
│   │   ├── presentation/
│   │   │   ├── game_screen.dart         → ATA
│   │   │   ├── task_screen.dart         → ATA
│   │   │   ├── waiting_screen.dart      → ATA
│   │   │   ├── round_result_screen.dart → ATA
│   │   │   └── game_over_screen.dart    → ATA
│   │   ├── providers/
│   │   │   └── game_provider.dart       → EGE
│   │   ├── domain/
│   │   │   ├── game_entity.dart         → EGE
│   │   │   ├── task_entity.dart         → EGE
│   │   │   └── game_repository.dart     → EGE (abstract)
│   │   └── data/
│   │       ├── game_model.dart          → EGE
│   │       ├── task_model.dart          → EGE
│   │       ├── tasks_seed_data.dart     → EGE
│   │       └── firebase_game_source.dart → EGE
│   └── voting/
│       ├── presentation/
│       │   └── voting_screen.dart       → ATA
│       ├── providers/
│       │   └── vote_provider.dart       → EGE
│       ├── domain/
│       │   └── vote_repository.dart     → EGE (abstract)
│       └── data/
│           ├── vote_model.dart          → EGE
│           └── firebase_vote_source.dart → EGE
└── shared/
    ├── widgets/
    │   ├── buttons/
    │   │   ├── primary_button.dart       → ATA
    │   │   └── danger_button.dart        → ATA
    │   ├── cards/
    │   │   ├── game_card.dart            → ATA
    │   │   └── player_score_card.dart    → ATA
    │   ├── voting/
    │   │   └── voting_panel.dart         → ATA
    │   ├── score/
    │   │   ├── score_counter.dart        → ATA
    │   │   └── leaderboard_tile.dart     → ATA
    │   └── common/
    │       └── gradient_container.dart   → ATA
    └── models/
        └── enums.dart                    → EGE
```

---

## 🔥 Firestore Yapısı (architecture.instructions.md Uyumlu)

```
rooms/{roomCode}
  ├── hostId: string
  ├── mode: 'classic'
  ├── visibility: 'open'
  ├── endCondition: { type: 'score' | 'rounds', value: number }
  ├── status: 'waiting' | 'playing' | 'finished'
  └── players/{playerId}
        ├── displayName: string
        ├── score: number
        ├── passStreak: number
        └── isReady: boolean

games/{gameId}
  ├── roomId: string
  ├── currentRound: number
  ├── currentPlayerId: string
  ├── currentQuestion: { id, category, multiplier, content }
  ├── turnOrder: [playerId1, playerId2, ...]
  └── votes/{playerId}: { value: 'like' | 'neutral' | 'dislike' }
```

---

## 📋 EGE'NİN TASK LİSTESİ (Backend: data + domain + providers + core)

### Faz 1 — Proje Kurulumu [0:00 - 0:30]

| # | Task | Süre |
|---|------|------|
| E1 | `flutter create social_risk`, GitHub repo, Ata'yı collaborator ekle | 5dk |
| E2 | Firebase Console: Auth (Anonymous) + Firestore aktif et | 10dk |
| E3 | `flutterfire configure`, paketleri ekle: `firebase_core`, `firebase_auth`, `cloud_firestore`, `flutter_riverpod`, `go_router`, `json_annotation`, `json_serializable`, `build_runner`, `google_fonts` | 10dk |
| E4 | `lib/core/` altyapısını kur: `game_constants.dart`, `app_router.dart`, `helpers.dart` | 5dk |

> **Faz 1 bitti → Ege push → Ata klonlar → herkes kendi branch'ine**

### Faz 2 — Auth + Oda [0:30 - 1:30]

| # | Task | Dosya Yolu |Süre |
|---|------|-----------|------|
| E5 | `shared/models/enums.dart` (GameMode, GameStatus, VoteValue, EndConditionType) | `shared/models/` | 5dk |
| E6 | Auth: `domain/auth_repository.dart` (abstract) + `data/firebase_auth_source.dart` + `providers/auth_provider.dart` | `features/auth/` | 15dk |
| E7 | Room entity + model: `domain/room_entity.dart`, `data/room_model.dart` (fromJson/toJson) | `features/room/` | 10dk |
| E8 | Room repository: `domain/room_repository.dart` (abstract) + `data/firebase_room_source.dart` (oda oluştur, katıl, stream dinle) | `features/room/` | 20dk |
| E9 | Room provider: `providers/room_provider.dart` (AsyncNotifier) | `features/room/` | 10dk |

### Faz 3 — Oyun Mantığı [1:30 - 3:00]

| # | Task | Dosya Yolu | Süre |
|---|------|-----------|------|
| E10 | Game + Task entity/model: `game_entity.dart`, `game_model.dart`, `task_entity.dart`, `task_model.dart` | `features/game/` | 10dk |
| E11 | Görev seed datası (min 30 görev, kategorili) | `features/game/data/tasks_seed_data.dart` | 15dk |
| E12 | Game repository: `domain/game_repository.dart` (abstract) + `data/firebase_game_source.dart` (tur başlat, sıra yönet, görev seç, puan güncelle) | `features/game/` | 25dk |
| E13 | Pas ceza sistemi: `penalty = basePenalty * (3 ^ passStreak)` — game_repository içinde | `features/game/` | 5dk |
| E14 | Vote entity/model + repository + data source | `features/voting/` | 15dk |
| E15 | Vote provider: oyları topla, puan hesapla (`finalScore = votingResult × multiplier`) | `features/voting/` | 10dk |
| E16 | Game provider: `AsyncNotifier` — tur döngüsü, bitiş kontrolü (puan hedefi / tur sayısı) | `features/game/` | 10dk |

### Faz 4 — Birleştirme [3:00 - 3:30]

| # | Task | Süre |
|---|------|------|
| E17 | Ata'nın branch'ini merge et | 10dk |
| E18 | `app_router.dart`'a tüm ekran route'larını bağla | 10dk |
| E19 | Entegrasyon kontrolü, kırık import'ları düzelt | 10dk |

---

## 📋 ATA'NIN TASK LİSTESİ (Frontend: presentation + shared/widgets + core/theme)

### Faz 1 — Kurulum [0:00 - 0:30]

| # | Task | Dosya Yolu | Süre |
|---|------|-----------|------|
| A1 | Ege push ettikten sonra klonla, `git checkout -b ata/frontend` | — | 5dk |
| A2 | `core/constants/app_colors.dart` (widgets.instructions.md'deki palette) | `core/constants/` | 5dk |
| A3 | `core/constants/app_text_styles.dart` (Nunito + Inter, Google Fonts) | `core/constants/` | 5dk |
| A4 | `core/theme/app_theme.dart` (dark theme only) | `core/theme/` | 5dk |
| A5 | `shared/widgets/buttons/primary_button.dart` + `danger_button.dart` | `shared/widgets/` | 10dk |

### Faz 2 — Auth + Lobi Ekranları [0:30 - 1:30]

| # | Task | Dosya Yolu | Süre |
|---|------|-----------|------|
| A6 | Login ekranı (isim TextField + "Gir" PrimaryButton) | `features/auth/presentation/` | 15dk |
| A7 | Ana menü (oda oluştur / odaya katıl butonları) — `game_screen.dart` veya home widget | `features/game/presentation/` | 10dk |
| A8 | Oda oluşturma ekranı (oyuncu sayısı slider, bitiş koşulu seçimi) | `features/room/presentation/` | 15dk |
| A9 | Oda katılma ekranı (6 haneli kod giriş) | `features/room/presentation/` | 10dk |
| A10 | Lobi ekranı (oyuncu listesi + "Başla" butonu host'a özel) | `features/room/presentation/` | 15dk |

### Faz 3 — Oyun Ekranları [1:30 - 3:00]

| # | Task | Dosya Yolu | Süre |
|---|------|-----------|------|
| A11 | `shared/widgets/common/gradient_container.dart` (arka plan gradient) | `shared/widgets/` | 5dk |
| A12 | `shared/widgets/cards/game_card.dart` (görev kartı) | `shared/widgets/` | 10dk |
| A13 | Task ekranı (kategori + görev metni + Kabul/Pas butonları) | `features/game/presentation/` | 15dk |
| A14 | `shared/widgets/voting/voting_panel.dart` (Beğen/Nötr/Beğenme, 3 buton) | `shared/widgets/` | 10dk |
| A15 | Voting ekranı (VotingPanel + geri sayım) | `features/voting/presentation/` | 10dk |
| A16 | Waiting ekranı (diğer oyuncuların tamamlamasını bekle) | `features/game/presentation/` | 5dk |
| A17 | `shared/widgets/score/score_counter.dart` + `leaderboard_tile.dart` | `shared/widgets/` | 10dk |
| A18 | Round result ekranı (oylama sonucu + kazanılan puan) | `features/game/presentation/` | 10dk |
| A19 | Game over ekranı (🏆 kazanan + sıralama) | `features/game/presentation/` | 15dk |

### Faz 4 — Birleştirme [3:00 - 4:00]

| # | Task | Süre |
|---|------|------|
| A20 | Branch'i push et | 5dk |
| A21 | Ekranları provider'lara bağla (ref.watch, ref.read ekle) — Ege ile birlikte | 25dk |
| A22 | 2 cihazda test, bugfix | 30dk |

---

## ⚙️ Teknik Kurallar Özeti (Instructions'tan)

| Kural | Kaynak |
|-------|--------|
| Widget içinde `FirebaseFirestore.instance` **YASAK** — sadece `data/` katmanında | architecture, development |
| `ref.watch` sadece `build()`'da, `ref.read` callback'lerde | development §3 |
| `const` constructor'ları maksimize et | development §1, performance §1 |
| `Container` yerine `SizedBox`/`ColoredBox`/`DecoratedBox` | widgets, performance |
| `print()` yasak — `debugPrint()` sadece dev'de | development §12 |
| Her dosya **500 satır** max | architecture §1, development §1 |
| `dynamic` tip kullanma | development §1 |
| Modeller `fromJson`/`toJson` ile (`json_serializable`) | architecture §4 |
| Dark theme only | widgets §tema |
| Hata: data→exception fırlat, provider→`AsyncValue.error`, widget→`.when(error:...)` | development §7 |

---

## 🔗 Birleştirme Anı (Faz 4) — Nasıl Olacak?

1. **Ata** branch'ini pushlar → **Ege** merge eder (UI dosyaları, çakışma olmaz)
2. **Ege** kendi branch'ini merge eder (backend dosyaları)
3. **Birlikte**: Ata'nın ekranlarına `ref.watch(roomProvider)`, `ref.read(gameProvider.notifier)` gibi bağlantılar eklenir
4. `app_router.dart`'a tüm ekran route'ları yazılır
5. 2 cihazda test → bugfix → tamamdır 🎉

> [!TIP]
> **Ata Faz 1-3'te ne yapacak?** Ekranlarında **mock/hardcoded data** kullan. Örneğin lobi ekranında `['Oyuncu 1', 'Oyuncu 2']` listesi göster. Faz 4'te bunlar gerçek provider'lara bağlanacak.

---

## ⏱️ Kontrol Noktaları

| Saat | Checkpoint |
|------|-----------|
| 0:30 | ✅ Proje kurulu, her iki kişi branch'inde, tema/renkler hazır |
| 1:30 | ✅ Auth çalışıyor, oda CRUD Firestore'da, lobi ekranı UI hazır |
| 3:00 | ✅ Oyun döngüsü backend hazır, tüm ekranlar UI olarak hazır |
| 3:30 | ✅ Branch'ler merge, ekranlar provider'lara bağlı |
| 4:00 | ✅ 2 cihazda çalışan MVP tamamlandı |
