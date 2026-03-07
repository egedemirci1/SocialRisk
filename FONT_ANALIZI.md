# Proje Font Kullanım Analizi (SocialRisk)

Proje genelinde `GoogleFonts` paketi kullanılarak **7 farklı font ailesi** toplam 114 kez çağrılmıştır. Tek bir "Ana Font" konsepti yerine, farklı ekranlarda farklı fontlar kullanılarak tasarım bütünlüğü (tutarlılık) bir miktar bozulmuş görünmektedir.

İşte projede kullanılan tüm fontlar ve kullanım sıklıkları:

| Font Ailesi | Kullanım Sayısı | Genellikle Kullanıldığı Yerler |
| :--- | :---: | :--- |
| **Nunito** | 56 | Butonlar, alt başlıklar, Toast mesajları, Mağaza açıklamaları, form inputları. Projede açık ara en çok kullanılan font. |
| **Poppins** | 20 | Ana başlıklar, ekran başlıkları (AppBar), önemli mesajlar ve odalardaki büyük yazılar. |
| **PlayfairDisplay** | 17 | Profil ekranı, sıralama (leaderboard) veya oyuncu adları gibi estetik ve klasik duruş gerektiren yerler. |
| **Inter** | 10 | Eski ekranlar (örneğin SpinWheel gibi), puan göstergeleri ve genel metin teması (`app_theme.dart`). |
| **LibreBaskerville** | 8 | Bazı özel paneller, stat rozetleri ve eski kart tasarımları. |
| **Cinzel** | 3 | Sadece Orta Çağ butonları (MedievalButton) ve Skor ekranındaki fantastik başlıklar. |
| **Montserrat** | 1 | Sadece projenin ana logosu (`social_risk_logo.dart`). |

---

### Sorunlar ve Çözüm Önerisi

Şu an proje genelinde bir **Standart Font Teması** bulunmasına rağmen (örneğin `app_theme.dart` dosyasında `GoogleFonts.interTextTheme` atanmış), widget'ların içinde doğrudan `GoogleFonts.xyz(...)` şeklinde **sabit kodlanmış (hard-coded)** fontlar kullanılmış. 

Bu durum:
1. İleride font değiştirmeyi inanılmaz zorlaştırır.
2. Ekranda çok fazla web-font yüklemesi performans kaybı yaratır.
3. Tasarım dilinin kendi içinde çatışmasına yol açar (Örn: Bir butonda `Nunito` varken hemen altındaki bilgi notunda `LibreBaskerville` olması).

**Önerilen Standartlaştırma Adımı:**
Projeyi **2 veya maksimum 3 temel fonta** indirgemek en sağlıklı yoldur:
- **Ana Başlıklar (Display/Headings):** `Poppins` veya `PlayfairDisplay`
- **Body / Buton / Genel Metinler:** `Nunito` veya `Inter`
- *İsteğe Bağlı:* Sadece özel yerler (Örn: Logo) için ayrı bir font.

Font standartlaştırma işlemine (hardcoded yazıları app_theme.dart'a veya ortak bir `AppTextStyles` dosyasına taşıma) başlamamı ister misiniz? Yoksa doğrudan hangi fontu standart yapacağımızı mı seçmek istersiniz?
