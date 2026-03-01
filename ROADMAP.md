# 🚀 Sosyal Risk — 4 Saatlik Ultra-Hızlı Geliştirme Planı (Granular Roadmap)

Bu plan, 4 saat içerisinde (her blok 1 saat) eksiklerin tamamlanması için **adım adım** görevleri içerir. Çakışmaları önlemek için Reze ve Ege ayrı dosya gruplarında çalışacaktır.

---

## ⏱️ BLOK 1: İçerik Motoru & Admin Kontrolü (0-60 dk)

### 👨‍💻 Geliştirici A (Logic/Backend/Ege)
1. **Model Güncelleme (`task_model.dart`):** `Task` sınıfına `difficulty` (enum), `type` (enum), `tags` (List<String>) ve `isActive` alanlarını ekle.
2. **Firestore Repository (`task_repository.dart`):** `addTask`, `updateTask` ve `deleteTask` fonksiyonlarını yaz.
3. **Filtering Logic (`game_provider.dart`):** Oda ayarlarındaki `preset`'e göre Firestore'dan sadece ilgili tag'leri (örn: `+18`) içeren soruları çeken query'i yaz.
4. **Seed Database:** Uygulama açılışında değil, admin panelinde bir butona basınca 50+ soruyu (tag ve zorluklarıyla) Firestore'a basan scripti bitir.

### 👨‍💻 Geliştirici B (UI/Frontend/Reze)
1. **Admin Dashboard (`admin_dashboard_screen.dart`):** Soru listesi arayüzünü yap (Silme ve düzenleme butonlarıyla).
2. **Task Editor (`task_editor_screen.dart`):** Soru ekleme formu; kategori, metin, zorluk (Dropdown) ve etiket (Chips) seçimini ekle.
3. **Main Menu Polish (`main_menu_screen.dart`):** Arka plana hafif bir partikül animasyonu ve butonlara "Glassmorphism" efekti ver.
4. **Lobby Tooltips:** Lobi ekranının altına 10 saniyede bir değişen "Unutma: Pas geçmek puanını 3 kat azaltır!" gibi ipucu dönen bir `AnimatedSwitcher` ekle.

---

## ⏱️ BLOK 2: Meta-Game, Shop & Custom Decks (60-120 dk)

### 👨‍💻 Geliştirici A (Logic/Backend/Ege)
1. **Custom Deck Logic (`user_task_provider.dart`):** `users/{uid}/custom_tasks` koleksiyonu için CRUD mantığını kur.
2. **Store Logic (`store_provider.dart`):** `buyItem(itemId)` fonksiyonu: Kullanıcı puanını kontrol et -> Firestore `transaction` ile puanı düş -> `users/{uid}/inventory` listesine ekle.
3. **Identity Logic (`user_model.dart`):** Kullanıcının `activeTitle` ve `activeFrame` ID'lerini tutacak alanları modele ekle.

### 👨‍💻 Geliştirici B (UI/Frontend/Reze)
1. **Player Deck Editor:** Kullanıcının kendi sorularını ekleyip silebileceği basit bir liste ekranı yap.
2. **Shop Grid (`store_screen.dart`):** Satın alınabilir eşyaları (Çerçeve, Unvan) kategorize edilmiş kartlar şeklinde listele (Fiyat etiketiyle).
3. **Avatar Upgrade (`player_avatar.dart`):** Gelen `frameId`'ye göre görsel bir `Image.asset` çerçeveyi avatarın üzerine bindiren (Stack) yapıyı kur.
4. **Title Display:** Oyuncu isminin hemen altına, şık bir kutu içinde (örn: altın sarısı yazı) `Title` metnini yerleştir.

---

## ⏱️ BLOK 3: Premium Polish & Oyun Matematiği (120-180 dk)

### 👨‍💻 Geliştirici A (Logic/Backend/Ege)
1. **Math Verification (`game_controller.dart`):** Pas geçme cezasının (`50 * 3^n`) doğru hesaplandığını ve veritabanına eksi olarak işlendiğini doğrula. Puan algoritmasının da mantıklı olduğunu, zorluğa göre puanın zorluğunu vs. kontrol et.
2. **Result Calculation:** Oylama bittiğinde `( 👍 - 👎 ) * multiplier` formülünün Firestore `Cloud Function` veya `Provider` içinde hatasız çalıştığını test et.
3. **Inventory Bridge:** Mağazadan alınan bir eşyanın (örn: Çerçeve) anında `PlayerAvatar`'da görünmesi için `Stream` bağlantısını kur.

### 👨‍💻 Geliştirici B (UI/Frontend/Reze)
1. **Transitions (`app_router.dart`):** Sayfa geçişlerine `CustomTransitionPage` ile "fade" veya "slide" animasyonları ekle.
2. **Micro-Interactions:** Butonlara basıldığında hafif titreşim (HapticFeedback) ve boyut küçülme (Scale down) efekti ver.
3. **Lottie Effects:** Puan kazanıldığında ekranda konfeti patlatacak `Lottie.asset` entegrasyonunu oylama ekranına ekle.
4. **Theme Final Touch:** Tüm `TextField` ve `Card` yapılarını `AppTheme`'deki en güncel `standard` hale getir.

---

## ⏱️ BLOK 4: Full Test & Merge (180-240 dk)

1. **Conflict Check:** Ege ve Reze kodlarını birleştirip `flutter analyze` ve `flutter build web` kontrolü yapacak.
2. **E2E Playtest:** 4 telefon (veya sekme) ile 5 tur oyun oynanacak; oylama, puanlama ve oyun sonu ekranları tek tek kontrol edilecek.
3. **Last Fixes:** UI'da taşan yazıları (`OverflowBox`) ve mobil cihazlardaki klavye sorunlarını (`SingleChildScrollView`) son bir kez gözden geçir.
4. **Ready for Push:** Her şey tamamsa master/main branch'e çekilecek.

---

### ⚠️ Krallık Kuralları
- **ASLA** aynı dosyayı düzenleme (A backend dosyasına, B frontend dosyasına odaklı kalmalı).
- **HIZ > MÜKEMMELİYET:** Bir widget çok vaktini alıyorsa basit tut, sonra süsle.
- **MOCK DATA:** Backend bitene kadar Frontend tarafı verileri "statik liste" olarak kullansın ki durmasın.
