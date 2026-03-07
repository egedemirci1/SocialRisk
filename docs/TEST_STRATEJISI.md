# Test stratejisi: Mock vs Firebase Emulator

## 1. Provider ve ekranlar: Mock (Taklit)

**Paketler:** `mocktail`, `firebase_auth_mocks` (dev_dependencies)

**Yöntem:** Riverpod provider'ları test ortamında **override** edilir; gerçek Firebase yerine sahte (fake) repository/controller kullanılır.

### Kullanılan fake'ler (test/helpers/)

| Dosya | Amaç |
|-------|------|
| `fake_user_repository.dart` | UserRepository — watchUserProfile / getUserProfile sahte profil döndürür |
| `fake_economy_controller.dart` | EconomyController — buyCosmetic, addPointsToWallet no-op |
| `fake_room_repository.dart` | RoomRepository — createRoom sahte oda kodu döndürür, diğerleri no-op |

| `fake_economy_repository.dart` | EconomyRepository — fetchCosmetics sahte liste, buyCosmetic/addPoints/setActive no-op (isteğe bağlı `buyThrows: true` ile hata) |

### Örnek: StoreScreen

- `currentUserProvider.overrideWithValue(MockUser(...))` — firebase_auth_mocks ile sahte kullanıcı
- `userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: ...))` — cüzdan puanı vb.
- `fetchCosmeticsProvider.overrideWith((ref) => Future.value([...]))` — mağaza listesi
- `economyControllerProvider.overrideWith(() => FakeEconomyController())` — alışveriş tetiklenince çökme yok

### Örnek: RoomController (unit test)

- `roomRepositoryProvider.overrideWithValue(FakeRoomRepository(createdRoomCode: 'ABC123'))`
- `userRepositoryProvider.overrideWithValue(FakeUserRepository())`
- `container.read(roomControllerProvider.notifier).createRoom(...)` → dönen kod `ABC123`

**Sonuç:** Ekran ve provider testleri Firebase bağlantısı olmadan çalışır; coverage artar.

### Örnek: EconomyController (unit test)

- `economyRepositoryProvider.overrideWithValue(FakeEconomyRepository(cosmetics: [...], buyThrows: false))`
- `addPointsToWallet`, `buyCosmetic`, `setActiveFrame`, `setActiveTitle` hata vermeden tamamlanır
- `buyThrows: true` ile `buyCosmetic` exception fırlatır (yetersiz bakiye senaryosu)
- `fetchCosmeticsProvider.future` fake listedeki ürünleri döndürür

---

## 2. Veri kaynağı (Firestore): Firebase Emulator

**Dosyalar:** `firebase_room_source.dart`, `firebase_economy_source.dart`, `firebase_user_source.dart` vb.

**Neden mock değil?** Bu sınıflar doğrudan Firestore'a yazıp okur. Mock’larsan kendi yazdığın mock’u test etmiş olursun; gerçek okuma/yazma davranışı test edilmez.

**Yöntem:** **Integration test** + **Firebase Local Emulator Suite**

1. Bilgisayara [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite) kurulur.
2. Test başında uygulama gerçek Firebase yerine `localhost:8080` (veya emülatör portları) adresine yönlendirilir.
3. Test içinde gerçekten veri yazılır, okunur, silinir.
4. Test sonunda emülatör verisi sıfırlanır; production veritabanı etkilenmez.

### Örnek akış (ileride eklenebilir)

```bash
# Emülatörü başlat
firebase emulators:start --only firestore

# Integration testi çalıştır (test ortamında FIRESTORE_EMULATOR_HOST=localhost:8080 ile)
flutter test integration_test/firestore_room_test.dart
```

Kod tarafında `FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080)` (ve diğer emülatör ayarları) test başında bir kez çağrılır.

**Özet:** Arayüz ve iş mantığı (provider/screen) → **mock + override**. Doğrudan Firestore kullanan source/repository → **Firebase Emulator ile integration test**.
