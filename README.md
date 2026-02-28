# 🎮 Sosyal Risk — Multiplayer Parti Oyunu

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime-orange?logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

**Sosyal Risk**, 2-8 oyuncuya kadar destekleyen, gerçek zamanlı multiplayer bir parti oyunudur. Oyuncular görevleri tamamlar, sosyal yargılama oylamasıyla puan kazanır ve puan ekonomisini stratejik kullanarak rakiplerini geride bırakmaya çalışır.

---

## 📋 İçindekiler

- [Oyun Hakkında](#oyun-hakkında)
- [Oyun Modları](#oyun-modları)
- [Temel Mekanikler](#temel-mekanikler)
- [Tech Stack](#tech-stack)
- [Kurulum](#kurulum)
- [Proje Yapısı](#proje-yapısı)
- [Instruction Dosyaları](#instruction-dosyaları)
- [Katkıda Bulunma](#katkıda-bulunma)

---

## 🎲 Oyun Hakkında

### Oyun Kurulumu

Oda kurucusu (Host) oyun başlamadan önce şu parametreleri belirler:

| Parametre | Seçenekler |
|-----------|------------|
| **Oyuncu Kapasitesi** | 2 – 8 oyuncu |
| **Bitiş Koşulu** | Puan Hedefi (ör. 5000) veya Tur Sayısı (ör. 10 tur) |
| **Görünürlük Modu** | Açık Mod (içeriği önceden gör) / Kapalı Mod (sadece kategori görünür) |

### Görünürlük Modları

- **Açık Mod (Stratejik):** Oyuncular görevi seçmeden önce içeriği okuyabilir. Seçimi onayladıktan sonra geri dönüş yoktur.
- **Kapalı Mod (Full Risk):** Oyuncular yalnızca kategori adını ve puan çarpanını bilerek seçer. Sürpriz ve kaos garantili!

---

## 🎮 Oyun Modları

### 1. Klasik Çark Modu (Şans ve Kaos)
- Sırası gelen oyuncu dijital çarkı çevirir.
- Gelen kategori tamamen şansa bağlıdır.
- Nadir kategoriler yüksek puan çarpanı verir.

### 2. Ekonomi Modu (Strateji ve Rekabet)
- **Seçim Önceliği:** Önceki turun puan lideri, yeni turda kategori seçme hakkını ilk elde eder.
- **Pazar Daralması:** Bir kategori seçildikçe o kategorinin puan değeri düşer veya tur için kilitlenir.
- **Stratejik İkilem:** "Düşük puanlı güvenli görev mi, yoksa yüksek puanlı riskli görev mi?"

---

## ⚙️ Temel Mekanikler

### 1. Avatar Sistemi
- Her oyuncu kendi fotoğrafını yükler.
- Puan durumuna göre **alev 🔥, buz ❄️ veya parıltı ✨** efektleri avatara bindirilir.

### 2. Sosyal Yargılama (Gerçek Zamanlı Oylama)
Görev tamamlandığında tüm diğer oyuncuların ekranında anlık oylama paneli belirir:

| Oy | İkon | Puan Etkisi |
|----|------|-------------|
| Beğendim | 👍 | Pozitif katkı |
| Nötr | 😐 | Nötr |
| Beğenmedim | 👎 | Negatif katkı |

**Nihai Puan:** `Oylama Sonucu × Görev Zorluk Katsayısı`

### 3. Ceza Sistemi (Anti-Korkaklık)
- Görevi reddeden (Pas diyen) oyuncu **eksi puan** alır.
- **Katlanan Ceza:** Üst üste Pas geçmek, ceza çarpanını artırır:

```
1. Pas → -50 puan
2. Pas → -150 puan  (×3)
3. Pas → -450 puan  (×3)
```

---

## 🛡️ İçerik ve Güvenlik Politikası

- Tüm görevler **genel kitleye** hitap eder; cinsellik, şiddet ve nefret söylemi **kesinlikle yoktur**.
- Oyun içinde **hiçbir reklam** gösterilmez.
- İçerik moderasyonu sunucu taraflı (Cloud Functions) gerçekleştirilir.

---

## 💰 Meta-Game ve Puan Ekonomisi

Oyun sonunda toplanan puanlar kalıcı cüzdana eklenir:

| Harcama Alanı | Açıklama |
|---------------|----------|
| **Kozmetik** | Avatar çerçeveleri, taçlar, rütbe simgeleri |
| **Öncelik Hakları** | Nadir "ilk seçim" hakları (Ekonomi Modu dışında da kullanılabilir) |
| **Premium Paketler** | Yeni ve absürt temalı (ama güvenli) soru paketleri |

---

## 🛠️ Tech Stack

| Katman | Teknoloji |
|--------|-----------|
| **Frontend** | Flutter 3.x (Dart 3.x) |
| **State Management** | Riverpod |
| **Routing** | GoRouter |
| **Backend / Auth** | Firebase (Firestore, Auth, Storage, Functions) veya Supabase |
| **Realtime** | Firestore `.snapshots()` / Supabase Realtime |
| **Animations** | Flutter Animation API, Lottie |
| **Image Caching** | cached_network_image |
| **Testing** | flutter_test, mockito / mocktail, patrol |
| **CI/CD** | GitHub Actions |

---

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Firebase CLI veya Supabase CLI
- Android Studio / VS Code

### Adımlar

```bash
# 1. Repoyu klonla
git clone https://github.com/kullanici/sosyal-risk.git
cd sosyal-risk

# 2. Bağımlılıkları yükle
flutter pub get

# 3. Kod üretme (json_serializable, Riverpod codegen vb.)
dart run build_runner build --delete-conflicting-outputs

# 4. Firebase yapılandırması
# google-services.json (Android) ve GoogleService-Info.plist (iOS) dosyalarını yerleştir
firebase login
flutterfire configure

# 5. Uygulamayı çalıştır
flutter run
```

### Ortam Değişkenleri

`lib/core/config/app_config.dart` (ya da `.env` + `flutter_dotenv`) üzerinden yönetilir:

```dart
class AppConfig {
  static const firestoreEmulatorHost = String.fromEnvironment('FIRESTORE_EMULATOR_HOST');
  static const useEmulator = bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
}
```

---

## 📁 Proje Yapısı

```
lib/
├── core/
│   ├── constants/        # AppColors, AppTextStyles, GameConstants
│   ├── theme/            # Dark theme tanımı
│   ├── router/           # GoRouter konfigürasyonu
│   └── utils/            # Yardımcı fonksiyonlar
├── features/
│   ├── auth/             # Kimlik doğrulama
│   ├── room/             # Oda oluşturma & yönetimi
│   ├── game/             # Ana oyun döngüsü
│   ├── voting/           # Gerçek zamanlı oylama
│   ├── economy/          # Puan ekonomisi & meta-game
│   └── profile/          # Avatar, çerçeve, cüzdan
└── shared/
    ├── widgets/          # Paylaşılan widget'lar
    └── models/           # Ortak modeller
```

Her feature `presentation/`, `providers/`, `domain/`, `data/` alt klasörlerini içerir.

---

## 📖 Instruction Dosyaları

Geliştirici kuralları ve standartlar `instructions/` klasöründe tanımlanmıştır:

| Dosya | İçerik |
|-------|--------|
| [`architecture.instructions.md`](instructions/architecture.instructions.md) | Katman mimarisi, Firestore/Supabase veri modeli, güvenlik |
| [`widgets.instructions.md`](instructions/widgets.instructions.md) | Widget sistemi, tasarım sistemi, animasyon standartları |
| [`development.instructions.md`](instructions/development.instructions.md) | Dart kod standartları, Riverpod kuralları, hata yönetimi |
| [`testing.instructions.md`](instructions/testing.instructions.md) | Test guardrails (unit, widget, E2E) |
| [`performance.instructions.md`](instructions/performance.instructions.md) | Flutter performans kuralları |

---

## 🤝 Katkıda Bulunma

1. `git checkout -b feature/ozellik-adi`
2. Kodunu yaz ve instruction kurallarına uy
3. Testlerini yaz: `flutter test`
4. `git commit -m 'feat: ozellik aciklamasi'`
5. `git push origin feature/ozellik-adi`
6. Pull Request aç

---

## 📄 Lisans

MIT License — bkz. [LICENSE](LICENSE)
