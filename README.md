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


## 🎮 Oyun Modları

### 1. Klasik Çark Modu (Şans ve Kaos)
- Sırası gelen oyuncu dijital çarkı çevirir.
- Gelen kategori tamamen şansa bağlıdır.
- Nadir kategoriler yüksek puan çarpanı verir.

### 2. Ekonomi Modu (Strateji ve Rekabet)

- **Pazar Daralması:** Bir kategori seçildikçe o kategorinin puan değeri düşer, bir kategori de sıcak fırsat olarak +2 puan alır.

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


## 🛡️ İçerik ve Güvenlik Politikası

- Tüm görevler **genel kitleye** hitap eder; , şiddet ve nefret söylemi **kesinlikle yoktur**.
- Oyun içinde **hiçbir reklam** gösterilmez.
- İçerik moderasyonu sunucu taraflı (Cloud Functions) gerçekleştirilir.

## 💰 Meta-Game ve Puan Ekonomisi

Oyun sonunda toplanan puanlar kalıcı cüzdana eklenir:

| Harcama Alanı | Açıklama |
|---------------|----------|
| **Kozmetik** | Avatar çerçeveleri, taçlar, rütbe simgeleri |
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