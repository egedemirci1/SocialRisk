# Eksik Unit Test Raporu — Social Risk

Bu rapor, projedeki mevcut unit testler ile test edilmesi gereken birimler karşılaştırılarak hazırlanmıştır.

**Güncel:** `test/unit/` altında 59 unit test yazıldı; `flutter test test/unit/` ile çalıştırılabilir.

---

## Mevcut unit testler

| Dosya | Test edilen | Tür |
|-------|-------------|-----|
| `test/unit/app_helpers_test.dart` | AppHelpers (generateRoomCode, calculatePenalty, formatTimestamp) | Unit |
| `test/unit/game_entity_test.dart` | GameEntity, TaskEntity | Unit |
| `test/unit/room_entity_test.dart` | RoomEntity, PlayerEntity | Unit |
| `test/unit/user_entity_test.dart` | Nullable, UserEntity, copyWith | Unit |
| `test/unit/report_entity_test.dart` | ReportEntity.fromJson | Unit |
| `test/unit/room_model_test.dart` | RoomModel, PlayerModel | Unit |
| `test/unit/user_model_test.dart` | UserModel | Unit |
| `test/unit/vote_model_test.dart` | VoteModel | Unit |
| `test/unit/cosmetic_item_model_test.dart` | CosmeticItemModel | Unit |
| `test/unit/entities_extra_test.dart` | UserTaskEntity, CosmeticItemEntity, TaskItemEntity | Unit |
| `test/unit/fake_user_repository_test.dart` | FakeUserRepository (test içi) | Unit |

---

## Eksik unit testler (öncelik sırasıyla)

### 1. Core — Yardımcı sınıflar (yüksek öncelik)

**Dosya:** `lib/core/utils/helpers.dart` — `AppHelpers`

- **`generateRoomCode()`**  
  - 6 karakter döndüğü  
  - Sadece `ABCDEFGHJKLMNPQRSTUVWXYZ23456789` karakterlerini kullandığı  
  - (İsteğe bağlı) Her çağrıda farklı kod ürettiği  

- **`calculatePenalty(basePenalty, passStreak)`**  
  - `passStreak <= 0` iken 0 döndüğü  
  - `passStreak > 0` iken `basePenalty * passStreak` döndüğü  

- **`formatTimestamp(DateTime)`**  
  - `HH:mm` formatında string döndüğü  
  - Saat/dakika tek haneliyken başına 0 eklendiği  

**Öneri:** `test/unit/app_helpers_test.dart` oluşturulmalı.

---

### 2. Domain entities (yüksek öncelik)

| Entity | Dosya | Test edilmesi gerekenler |
|--------|--------|---------------------------|
| **RoomEntity** | `lib/features/room/domain/room_entity.dart` | Varsayılan değerler (`mode`, `status`, `endConditionType`, `players`, `categories`), tüm parametrelerle oluşturma |
| **PlayerEntity** | Aynı dosya | Varsayılan değerler, `name` getter'ının `displayName` döndürmesi |
| **UserEntity** | `lib/features/auth/domain/user_entity.dart` | Varsayılan değerler, **`copyWith`** (özellikle `Nullable` ile null atama senaryoları) |
| **TaskEntity** | `lib/features/game/domain/game_entity.dart` | Varsayılan `multiplier: 1`, tüm alanlar |
| **UserTaskEntity** | `lib/features/custom_decks/domain/user_task_entity.dart` | Varsayılan değerler (`type`, `tags`, `isActive`) |
| **CosmeticItemEntity** | `lib/features/economy/domain/cosmetic_item_entity.dart` | Tüm alanların atanması |
| **TaskItemEntity** | `lib/features/admin/domain/task_item_entity.dart` | Varsayılan değerler (`type`, `tags`, `likes`, `dislikes`, `isActive`) |
| **ReportEntity** | `lib/features/admin/domain/report_entity.dart` | **`fromJson`** (normal + eksik alanlarda varsayılan değerler) |

**Öneri:**  
- `test/unit/room_entity_test.dart`  
- `test/unit/user_entity_test.dart` (copyWith vurgusu)  
- `test/unit/report_entity_test.dart` (fromJson)  
- İsterseniz diğer entity’ler için tek dosyada gruplu testler: `test/unit/entities_test.dart`.

---

### 3. Data modelleri — fromJson / toJson / toEntity (orta öncelik)

| Model | Dosya | Test edilmesi gerekenler |
|-------|--------|---------------------------|
| **RoomModel** | `lib/features/room/data/room_model.dart` | `fromJson`, `toJson`, **`toEntity(players)`** (enum eşlemesi) |
| **PlayerModel** | Aynı dosya | `fromJson`, `toJson`, `toEntity` |
| **UserModel** | `lib/features/auth/data/user_model.dart` | `fromJson`, `toJson`, `toEntity` |
| **VoteModel** | `lib/features/voting/data/vote_model.dart` | `fromJson` (value enum), `toJson` |
| **GameModel** | `lib/features/game/data/game_model.dart` | `fromJson` (Firestore `Timestamp` mock’lanarak), `toEntity` |
| **CosmeticItemModel** | `lib/features/economy/data/cosmetic_item_model.dart` | Varsa `fromJson` / `toJson` / `toEntity` |

**Not:** `GameModel` ve Firestore kullanan modeller için birim testinde `Timestamp` / `FieldValue` mock’lanmalı veya sadece JSON map ile test edilmeli.

**Öneri:**  
- `test/unit/room_model_test.dart`  
- `test/unit/player_model_test.dart`  
- `test/unit/user_model_test.dart`  
- `test/unit/vote_model_test.dart`  

---

### 4. Placeholder / dummy testler (düşük öncelik)

| Dosya | Durum | Öneri |
|-------|--------|--------|
| `test/widget_test.dart` | Sadece `expect(true, isTrue)` placeholder | Gerçek widget testleri eklenmeli veya dosya kaldırılmalı. |
| `test/store_screen_test.dart` | Sadece `expect(1, 1)` dummy | Store ekranı için provider mock’lu widget testi veya kaldırma. |

---

### 5. Diğer notlar

- **`test/unit/fake_user_repository_test.dart`**  
  Lib’deki `UserRepository` veya gerçek implementasyonu test etmiyor; sadece test dosyasındaki bir Fake’i test ediyor. Gerçek repository davranışı için ya bu test lib’deki interface’i kullanan bir Fake ile güncellenmeli ya da ayrı bir repository (mock) testi yazılmalı.

- **`test/seed_cosmetics_test.dart`**  
  Unit test değil; Firebase’e seed verisi yazan bir script. İsimlendirme `seed_cosmetics_script.dart` veya `tool/` altına taşınması karışıklığı azaltır.

- **Repository implementasyonları**  
  `AuthRepository`, `GameRepository`, `RoomRepository` vb. Firebase kullandığı için klasik unit test yerine mock/fake ile provider veya entegrasyon testlerinde test edilmesi daha uygun.

---

## Özet tablo

| Kategori | Eksik test sayısı (tahmini) | Öncelik |
|----------|-----------------------------|---------|
| AppHelpers | 1 dosya (~6–8 test) | Yüksek |
| Domain entities | 6–8 dosya / gruplu test | Yüksek |
| Data modelleri | 4–5 dosya | Orta |
| Placeholder/dummy | 2 dosya düzeltme | Düşük |

---

## Hızlı başlangıç

Önce şu iki dosya eklenirse kapsam hızla artar:

1. **`test/unit/app_helpers_test.dart`** — Bağımlılık yok, saf fonksiyonlar.  
2. **`test/unit/room_entity_test.dart`** veya **`test/unit/user_entity_test.dart`** — Domain mantığı ve `copyWith` / varsayılan değerler.

Bu rapor, `flutter test test/unit/` çalıştırılarak ve yeni testler eklenerek güncellenebilir.
