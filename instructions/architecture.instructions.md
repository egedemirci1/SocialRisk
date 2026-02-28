---
applyTo: '**'
---

# Mimari & Katmanlama Kuralları — Sosyal Risk (Flutter Stack)

Bu kurallar, **Sosyal Risk** multiplayer parti oyununun Flutter katman sınırlarını tanımlar. Doğruluk, gözlemlenebilirlik ve uzun vadeli sürdürülebilirlik için optimize edilmiştir.

## Tech Stack

- **Framework:** Flutter (Dart)
- **Backend-as-a-Service:** Firebase (Firestore, Auth, Cloud Functions, Storage) veya Supabase (Postgres, Auth, Realtime, Storage)
- **Realtime:** Firebase Realtime Database / Firestore `.snapshots()` stream — ya da Supabase Realtime channels
- **State Management:** Riverpod (Provider ağacı, `AsyncNotifier`, `StreamNotifier`)
- **Routing:** GoRouter
- **Dependency Injection:** Riverpod providers

---

## Katman Haritası

```
Presentation (Widgets / Pages)
      │
      ▼
Providers / Controllers (Riverpod)
      │
      ▼
Use Cases / Repositories (Abstract Interfaces)
      │
      ▼
Data Sources (Firebase/Supabase SDK)
```

### Kesin Bağımlılık Yönü
- Sunum katmanı yalnızca provider'lara bağımlıdır.
- Provider'lar yalnızca Use Case veya Repository interface'lerine bağımlıdır.
- Concrete data source implementasyonları hiçbir zaman doğrudan sunum katmanına import edilmez.

---

## 1) Presentation Katmanı (Widgets / Pages)

- `lib/features/<feature>/presentation/` klasörüne yerleştirilir.
- Widget'lar **yalnızca `ref.watch` / `ref.read`** ile provider'lardan state okur.
- Hiçbir widget doğrudan Firestore / Supabase SDK'sına dokunmaz.
- İş mantığı widget içinde **kesinlikle bulunmaz**; tümü controller/use-case katmanındadır.
- Her ekranın kendi `*_screen.dart` dosyası, karmaşık bölümlerin kendi `*_widget.dart` dosyası vardır.
- Dosyalar **500 satırı geçmemeli**; geçerse parça widget'lara bölünür.

---

## 2) Provider / Controller Katmanı (Riverpod)

- `lib/features/<feature>/providers/` klasörüne yerleştirilir.
- Tek bir provider **tek bir sorumluluk** taşır.
- `AsyncNotifier` / `StreamNotifier` tercih edilir; Flutter hook tabanlı yaklaşımdan kaçınılır.
- Tüm iş kuralları (puan hesaplama, tur mantığı, oyuncu sıralaması vb.) provider'lar ya da use-case'ler içinde yaşar.
- Provider'lar repository'leri `ref.read(repositoryProvider)` ile tüketir; doğrudan SDK çağrısı yapmaz.
- Hata yönetimi: `AsyncValue.error(...)` ile surface edilir; widget katmanı `when(error: ...)` ile işler.

---

## 3) Repository / Use Case Katmanı (Domain)

- `lib/features/<feature>/domain/` klasörüne yerleştirilir.
- Abstract interface (`abstract class GameRepository`) domain katmanında tanımlanır.
- Concrete implementasyon (`lib/features/<feature>/data/`) data katmanındadır.
- Use case'ler tek bir iş amacı taşır: `JoinRoomUseCase`, `SubmitVoteUseCase`, vb.
- Repository'ler **iş mantığı içermez**; yalnızca CRUD/stream operasyonları gerçekleştirir.
- Repository'lerde `try/catch` **yoktur**; hatalar yukarı kabarcık olarak iletilir.

---

## 4) Data Source Katmanı (Firebase / Supabase)

- `lib/features/<feature>/data/` klasörüne yerleştirilir.
- Firebase Firestore / Supabase direkt SDK çağrıları burada yapılır.
- Data model sınıfları (`*_model.dart`) JSON serializasyonu için `fromJson` / `toJson` içerir.
- Realtime dinleme: Firestore `.snapshots()` stream veya Supabase `.stream()` kullanılır.
- Cloud Functions / Supabase Edge Functions yalnızca şunlar için kullanılır:
  - Sunucu taraflı puan doğrulama
  - Hile önleme kritik noktaları
  - Bildirim gönderimi

---

## Klasör Yapısı (Feature-First)

```
lib/
├── core/
│   ├── constants/           # AppColors, AppTextStyles, GameConstants
│   ├── theme/               # ThemeData tanımları
│   ├── router/              # GoRouter konfigürasyonu
│   ├── di/                  # Global Riverpod override'ları
│   └── utils/               # Shared yardımcı fonksiyonlar
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   ├── providers/
│   │   ├── domain/
│   │   └── data/
│   ├── room/                # Oda oluşturma & yönetimi
│   ├── game/                # Ana oyun döngüsü
│   ├── voting/              # Gerçek zamanlı oylama
│   ├── economy/             # Puan ekonomisi & meta-game
│   └── profile/             # Avatar, çerçeve, cüzdan
└── shared/
    ├── widgets/             # Uygulama geneli paylaşılan widget'lar
    └── models/              # Ortak veri modelleri
```

---

## Veri Modeli Tasarımı (Firestore / Supabase)

### Firestore Koleksiyon Yapısı

```
rooms/{roomId}
  ├── hostId: string
  ├── mode: 'classic' | 'economy'
  ├── visibility: 'open' | 'closed'
  ├── endCondition: { type: 'score' | 'rounds', value: number }
  ├── status: 'waiting' | 'playing' | 'finished'
  └── players/{playerId}
        ├── displayName: string
        ├── avatarUrl: string
        ├── score: number
        ├── passStreak: number
        └── isReady: boolean

games/{gameId}
  ├── roomId: string
  ├── currentRound: number
  ├── currentPlayerId: string
  ├── currentQuestion: { id, category, multiplier, content? }
  └── votes/{playerId}: { value: 'like'|'neutral'|'dislike' }

users/{userId}
  ├── walletPoints: number
  ├── ownedFrames: string[]
  ├── ownedPacks: string[]
  └── rank: string
```

### Supabase Alternatifi (Tablo Yapısı)

```sql
rooms (id, host_id, mode, visibility, end_condition, status, created_at)
room_players (room_id, user_id, score, pass_streak, is_ready)
games (id, room_id, current_round, current_player_id, current_question_json)
votes (game_id, voter_id, value)
users (id, wallet_points, rank)
user_cosmetics (user_id, cosmetic_id, type)
```

---

## Realtime Kuralları

- Oyun durumu stream'leri `StreamNotifier` veya `StreamProvider` ile yönetilir.
- Her UI bileşeni en granüler stream'i dinler (fazladan rebuild'den kaçınmak için).
- Bağlantı kopması / reconnect senaryoları her feature için ele alınmalıdır.
- Çevrimdışı kalıcılık: Firestore offline persistence etkinleştirilir; Supabase için optimistik UI kullanılır.

---

## Güvenlik ve Hile Önleme

- Kritik puan hesaplamaları **sunucu taraflı** (Cloud Functions / Edge Functions) doğrulanır.
- Firestore Security Rules / Row Level Security (Supabase): kullanıcı yalnızca kendi oylama verisini yazabilir.
- Puan değişiklikleri: yalnızca sunucu fonksiyonları Firestore'daki `score` alanını günceller.
- Rate limiting: oy gönderiminde Cloud Function seviyesinde hız sınırı uygulanır.

---

## Tip ve Model Tanımları (Tek Kaynak)

- Tüm paylaşılan enum ve model tanımları `lib/shared/models/` içinde yaşar.
- Feature özgü modeller `lib/features/<feature>/domain/entities/` içindedir.
- JSON serializasyonu için `json_serializable` paketi kullanılır.
- Hiçbir widget dosyası `fromJson/toJson` mantığı içermez.

---

## Loglama Kuralları

- `debugPrint()` yalnızca development ortamında kullanılır.
- Production loglaması için `firebase_crashlytics` entegre edilir.
- Her hata `Crashlytics.recordError(error, stackTrace, reason: '...')` ile raporlanır.
- Repository'ler hata loglamaz; log, provider / use-case katmanında takılır.

---

## i18n (Çoklu Dil Desteği)

- Tüm kullanıcıya dönük metin `l10n/` klasöründen `AppLocalizations.of(context)!.key` ile çekilir.
- Türkçe öncelikli; İngilizce fallback.
- Widget'larda hardcoded Türkçe/İngilizce string bırakılmaz.
