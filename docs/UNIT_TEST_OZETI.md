# Unit test kapsamı (güncel)

## Var olan unit testler

| Dosya | Kapsanan |
|-------|----------|
| `room_entity_test.dart` | RoomEntity, PlayerEntity |
| `room_model_test.dart` | RoomModel, PlayerModel (fromJson, toJson, toEntity) |
| `game_entity_test.dart` | GameEntity temel |
| `game_entity_edge_test.dart` | GameEntity edge, TaskEntity |
| `game_constants_test.dart` | GameConstants |
| `user_model_test.dart` | UserModel |
| `user_entity_test.dart` | UserEntity, Nullable |
| `vote_model_test.dart` | VoteModel |
| `vote_calculation_test.dart` | Oy hesaplama mantığı |
| `player_model_test.dart` | PlayerModel (game tarafı) |
| `cosmetic_item_model_test.dart` | CosmeticItemModel |
| `cosmetic_item_model_edge_test.dart` | CosmeticItemModel edge |
| `report_entity_test.dart` | ReportEntity |
| `app_helpers_test.dart` | AppHelpers (generateRoomCode, calculatePenalty, formatTimestamp) |
| `app_helpers_edge_test.dart` | AppHelpers edge senaryoları |
| `enums_test.dart` | GameMode, GameStatus, VoteValue, EndConditionType, RoomVisibility, TaskType |
| `entities_extra_test.dart` | Çeşitli entity yardımcıları |
| `fake_user_repository_test.dart` | FakeUserRepository |

## Widget testleri (ekran)

| Dosya | Ekran | Senaryolar |
|-------|--------|------------|
| `login_screen_test.dart` | LoginScreen | Logo, form, Partiye Katıl, Google, Veya; **validasyon:** boş/kısa/geçersiz karakter → toast; **Türkçe karakter** kabul; **loading** overlay |
| `lobby_screen_test.dart` | LobbyScreen | Başlık, oda kodu, oyuncu listesi; **PARTİYE HAZIRIM** (non-host); **kopyala** → toast |
| `create_room_screen_test.dart` | CreateRoomScreen | Yeni Parti Kur, Partiyi Başlat, Oyun Sonu/Modu/Kategoriler; **Puan/Tur** chip; **Çark/Ekonomi** chip; **Slider**; tap Partiyi Başlat (null user) |
| `store_screen_test.dart` | StoreScreen | Kullanıcı null iken loading (giriş yapmış senaryo için mock User gerekir) |
| `profile_screen_test.dart` | ProfileScreen | Kullanıcı null iken loading (giriş yapmış senaryo için mock User gerekir) |

**Not:** StoreScreen ve ProfileScreen’in “giriş yapmış” (tab’lar, bakiye, profil içeriği) testleri için `firebase_auth.User` mock’u gerekiyor; uygulama şu an doğrudan `User` kullandığı için bu senaryolar atlandı. İleride bir `UserInfo`/abstraction katmanı eklenirse ek testler yazılabilir.

## Eksik / isteğe bağlı unit testler

- **game_model.dart** (data katmanı): `GameModel` fromJson/toJson — isteğe bağlı (game_entity zaten kapsamlı).
- **user_task_entity.dart** (custom_decks): Özel görev entity — isteğe bağlı.
- **Repository implementasyonları** (Firebase*Source): Genelde integration test ile test edilir; unit test zorunlu değil.

**Sonuç:** Kritik domain/entity/model’ler unit test ile kapsanmış durumda. Eksik sayılabilecek sadece isteğe bağlı birkaç model/entity testi. Ekranlar için widget testleri ekran ekran eklenmiştir (LoginScreen, LobbyScreen, CreateRoomScreen, StoreScreen, ProfileScreen).

---

## Coverage (yüzde) nasıl görülür?

- **Tek komut (önerilen):** Proje kökünde `.\tool\coverage.ps1` — `flutter test --coverage` çalıştırır, sonra toplam ve dosya bazlı satır kapsamı yüzdesini yazdırır. genhtml gerekmez (Windows'ta yüklü olmasa da çalışır).
- **Manuel:** `flutter test --coverage` sonra `dart run tool/coverage_summary.dart`.
- **HTML rapor (isteğe bağlı):** genhtml yüklüyse `genhtml coverage/lcov.info -o coverage/html` → `coverage/html/index.html` tarayıcıda açılır.

**Not:** `flutter test` sadece `test/` altındaki *_test.dart dosyalarını çalıştırır. Integration testi `integration_test/app_flow_test.dart` taşındı (Firebase gerekir; `flutter test integration_test` ile ayrı çalıştırılır). Cosmetics seed: `tool/seed_cosmetics.dart` (test değil; `flutter run -t tool/seed_cosmetics.dart` ile çalıştırılır).
