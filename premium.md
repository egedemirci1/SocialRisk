# Premium IAP Notları

Bu dosya, projede uygulanan premium mimarisinin güncel özetidir.

## Hedef

Kullanıcılar yalnızca Google Play / App Store üzerinden tek seferlik premium satın alır.  
Premium yetkisi backend doğrulaması sonrası verilir.

Premium olmayan kullanıcı:
- özel içerik ekleyemez
- premium senaryo paketlerini satın alamaz / kullanamaz

## Uygulanan Teknik Yapı

### 1) Kullanıcı modeli
- `lib/features/auth/domain/user_entity.dart`
- `lib/features/auth/data/user_model.dart`

Eklenen alanlar:
- `isPremium`
- `premiumType`
- `premiumSource`
- `premiumActivatedAt`
- `premiumProductId`

Bu alanlar `fromJson / toJson / watchUserProfile` akışına dahil edildi.

### 2) Mobil IAP katmanı
- `pubspec.yaml` -> `in_app_purchase` eklendi
- `lib/features/premium/domain/premium_constants.dart`
- `lib/features/premium/data/premium_purchase_service.dart`
- `lib/features/premium/providers/premium_provider.dart`

Akış:
- ürün sorgulama (`premium_lifetime`)
- satın alma başlatma
- restore purchases
- satın alma sonucunu backend `activatePremium` callable'ına gönderme

### 3) Backend entitlement
- `functions/src/index.ts`

Eklenen callable:
- `activatePremium`

Yaptığı işler:
- auth kontrolü
- `productId` ve `source` doğrulaması
- replay/fraud için `premiumPurchases` koleksiyonunda kayıt kontrolü
- başarılıysa `users/{uid}` içinde premium alanlarını güncelleme

Not:
- Gerçek mağaza receipt doğrulaması için Google Play Developer API / App Store Server API entegrasyonu ayrıca tamamlanmalı.

### 4) Erişim kilitleri

#### Custom içerik
- `lib/features/profile/presentation/custom_deck_editor_screen.dart`
- `lib/features/custom_decks/data/firebase_user_task_source.dart`

Premium değilse içerik editörü yerine premium kilit/CTA gösterilir.  
Data source tarafında da premium kontrolü var.

#### Mağaza senaryoları
- `lib/features/store/presentation/store_screen.dart`
- `lib/features/economy/data/firebase_economy_source.dart`
- `functions/src/index.ts` (`buyCosmetic`)

Senaryo (`type == category`) satın alımı premium üyelik şartına bağlandı.

### 5) Firestore güvenliği
- `firestore.rules`

Değişiklikler:
- `users/{uid}/custom_tasks/{taskId}` yazma: owner + premium şartı
- kullanıcı dokümanında client update whitelist daraltıldı
- premium alanlarının client tarafından doğrudan yazılması engellendi

## Doğrulama Durumu

Tamamlanan kontroller:
- Flutter bağımlılık güncellemesi (`flutter pub get`) başarılı
- Functions TypeScript build (`npm run build`) başarılı
- Lint kontrolleri temiz

## Senin Yapman Gerekenler

### A) Store panel tarafı (zorunlu)
1. Google Play Console'da non-consumable ürün aç: `premium_lifetime`
2. App Store Connect'te non-consumable ürün aç: `premium_lifetime`
3. Fiyatı store panelinde 50 TL karşılığı tier'a ayarla

### B) Backend doğrulama (zorunlu, production öncesi)
1. `activatePremium` içinde gerçek receipt/token doğrulamasını ekle:
   - Android: Google Play Developer API
   - iOS: App Store Server API
2. Doğrulama başarısızsa premium vermeyecek şekilde finalize et

### C) Deploy adımları
1. Firestore rules deploy et
2. Functions deploy et
3. Uygulamayı internal test (Android) + TestFlight (iOS) dağıt

### D) Uçtan uca test
1. Premium satın al -> `users/{uid}.isPremium == true` doğrula
2. Premium olmayan kullanıcı custom içerik ekleyemiyor mu kontrol et
3. Premium olmayan kullanıcı senaryo satın alamıyor mu kontrol et
4. Restore purchases sonrası premium geri geliyor mu test et
5. Replay testi: aynı purchase başka kullanıcıya uygulanamamalı

## İlgili Ek Doküman

Detaylı release checklist:
- `docs/premium-iap-release-checklist.md`