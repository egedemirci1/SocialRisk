# Sosyal Risk — Geliştirme Yol Haritası (Güncel: 1 Mart 2026)

## Proje Durumu

| Metrik | Değer |
|--------|-------|
| **Dosya sayısı** | 48 Dart dosyası |
| **Flutter analyze** | ✅ 0 hata, 0 uyarı |
| **Çalışan özellikler** | Login (anonim), Oda oluştur/katıl, Lobi (hazır/bağlan) |
| **Test edilmemiş** | Oyun akışı (lobi → görev → oylama → sonuç → oyun sonu) |

---

## 🤝 Buluşma & Entegrasyon Noktaları
*Hangi fazda kim kimi bekler?*

| Faz | Kim Kimi Bekler? | El Sıkışma Noktası (Merge) |
|-----|------------------|---------------------------|
| **Faz 5** | Ata, Ege'yi bekler. | Ege `acceptTask` ve `nextTurn` mantığını bitirip pushlar. |
| **Faz 6** | Ata, Ege'yi bekler. | Ata çark sonucunu parametre olarak gönderir. Ege o kategoriye göre soru çeker. |
| **Faz 7** | Ege önce başlar. | Ege Firestore modeline `visibility` alanını ekler. |
| **Faz 8** | Birlikte. | Ege Storage kurallarını yazar, Ata dosya yükler. URL formatında el sıkışılır. |
| **Faz 9** | Ata, Ege'yi bekler. | Cloud Functions puan hesaplaması yapılır, Ata sadece sonucu gösterir. |

---

## ✅ Tamamlanan Fazlar (1-4)
- [x] Faz 1: Theme, widget altyapısı
- [x] Faz 2: Auth + Lobi ekranları (Login/Home/CreateRoom/JoinRoom/Lobby)
- [x] Faz 3: Oyun ekranları (Task/Voting/Waiting/RoundResult/GameOver)
- [x] Faz 4: Firebase provider birleştirme + auth redirect
- [x] BUG: Provider dispose hatası (create_room + join_room)

---

## Faz 5 — Oyun Akışı Debug + Düzeltme 🔧
> **Öncelik: KRİTİK** — Lobi sonrası oyun akışı test edilmeli ve çalışır hale getirilmeli.

### Ata (Frontend)
- [ ] A20: Lobi → Oyun Başlat akışını test et (2 tarayıcı ile)
- [ ] A21: Task ekranı hata yönetimi (null game, null task)
- [ ] A22: Voting ekranı akışı debug (oy ver → tüm oylar geldi → sonuç)
- [ ] A23: Round result → sonraki tur geçişi düzelt
- [ ] A24: Game over koşulu test (tur/skor limiti)

### Ege (Backend)
- [ ] E10: `acceptTask` implementasyonunu tamamla (şu an boş method)
- [ ] E11: `passTask` penalty hesaplaması test et (`basePenalty` README'de 50 ama code'da 100)
- [ ] E12: `endGame` koşulu — skor bazlı bitiş eksik (sadece tur bazlı var)
- [ ] E13: Vote clear sonrası yeni tur geçiş sıralaması

---

## Faz 6 — Çark Animasyonu + Görev Seçimi 🎡
> README: *"Sırası gelen oyuncu dijital çarkı çevirir. Gelen kategori tamamen şansa bağlıdır."*

### Ata (Frontend)
- [ ] A25: Çark widget'ı (`spin_wheel.dart`) — 6 kategorili dönen çark
- [ ] A26: Task ekranına çark entegrasyonu — çark → kategori → görev
- [ ] A27: Çark sonucu popup animasyonu (kategori + çarpan)

### Ege (Backend)
- [ ] E14: `assignTaskByCategory(gameId, category)` — kategori filtreli görev
- [ ] E15: Kullanılmış görev takibi (`usedTaskIds`) — tekrar önleme
- [ ] E16: `GameEntity`'ye `usedTaskIds` alanı ekle

---

## Faz 7 — Görünürlük Modları 👁️
> README: *"Açık Mod (içeriği önceden gör) / Kapalı Mod (sadece kategori görünür)"*

### Ata (Frontend)
- [ ] A28: CreateRoom'a Görünürlük modu seçici ekle
- [ ] A29: TaskScreen Kapalı Mod — içerik gizli, sadece kategori + çarpan
- [ ] A30: "Görevi Aç" butonu — Kapalı Mod'da tıklayınca içerik göster

### Ege (Backend)
- [ ] E17: Room modeline `visibility: open | closed` alanı ekle
- [ ] E18: Firestore Security Rules — visibility'ye göre content erişim kontrolü

---

## Faz 8 — Avatar Sistemi + Profil 🖼️
> README: *"Her oyuncu kendi fotoğrafını yükler. Puan durumuna göre efektler."*

### Ata (Frontend)
- [ ] A31: Profil ekranı (avatar yükleme, isim değiştirme)
- [ ] A32: Avatar widget (`cached_network_image` + shimmer)
- [ ] A33: Puan bazlı efektler (🔥 alev / ❄️ buz / ✨ parıltı)
- [ ] A34: Lobi + oyun ekranlarında avatar göster

### Ege (Backend)
- [ ] E19: Firebase Storage avatar upload (`users/{uid}/avatar`)
- [ ] E20: User koleksiyonu (`walletPoints`, `avatarUrl`, `rank`)
- [ ] E21: Avatar URL → PlayerEntity bağlama

---

## Faz 9 — Meta-Game Puan Ekonomisi 💰
> README: *"Oyun sonunda toplanan puanlar kalıcı cüzdana eklenir."*

### Ata (Frontend)
- [ ] A35: Cüzdan ekranı (toplam puan, harcama alanları)
- [ ] A36: Kozmetik mağazası UI (çerçeveler, taçlar)
- [ ] A37: GameOver → cüzdan puan aktarım animasyonu

### Ege (Backend)
- [ ] E22: Economy module (economy_repository, economy_provider)
- [ ] E23: Cloud Function — oyun sonu puan doğrulama + cüzdana ekleme
- [ ] E24: Kozmetik envanter CRUD (ownedFrames, ownedPacks)

---

## Faz 10 — Ekonomi Modu (Strateji) 🏦
> README: *"Önceki turun puan lideri kategori seçme hakkını ilk elde eder. Pazar Daralması."*

### Ata (Frontend)
- [ ] A38: Ekonomi modu kategori seçim ekranı
- [ ] A39: Pazar daralması UI (kilitlenen/değer kaybeden kategoriler)

### Ege (Backend)
- [ ] E25: Ekonomi modu oyun mantığı (sıralama bazlı seçim hakları)
- [ ] E26: Kategori pazar değeri hesaplaması

---

## Faz 11 — Polish + Production 🚀
> README: i18n, testing, performance, CI/CD

### Ata (Frontend)
- [ ] A40: i18n (Türkçe öncelikli, İngilizce fallback)
- [ ] A41: Hardcoded string → AppLocalizations
- [ ] A42: Widget testleri (primary_button, game_card, voting_panel)
- [ ] A43: Responsive layout (tablet/telefon)
- [ ] A44: Google Sign-In + Apple Sign-In entegrasyonu

### Ege (Backend)
- [ ] E27: Firestore Security Rules tam implementasyon
- [ ] E28: Cloud Functions — sunucu taraflı puan doğrulama
- [ ] E29: Firebase Crashlytics entegrasyonu
- [ ] E30: Offline persistence
- [ ] E31: GitHub Actions CI/CD pipeline
