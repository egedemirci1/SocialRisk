# Sosyal Risk — Geliştirme Yol Haritası (Güncel: 1 Mart 2026)

## Proje Durumu

| Metrik | Değer |
|--------|-------|
| **Dosya sayısı** | 49 Dart dosyası |
| **Flutter analyze** | ✅ 0 hata, 0 uyarı |
| **Çalışan özellikler** | Login, Oda oluştur/katıl, Lobi, Çark animasyonu |
| **Test edilmemiş** | Oyun akışı uçtan uca (Ege E10-E16 bekliyor) |

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
- [x] A20: Lobi → Oyun Başlat akışı — dispose hatası fix, non-host auto-navigate
- [x] A21: Task ekranı hata yönetimi (null game, null task)
- [x] A22: Voting ekranı — duplike puan hesaplaması fix, dinamik bitiş koşulu
- [x] A23: Round result → sonraki tur / oyun sonu geçişi düzeltildi
- [x] A24: Game over koşulu — tüm ekranlar game status kontrol ediyor

### Ege (Backend)
- [x] E10: `acceptTask` implementasyonunu tamamla (şu an boş method)
- [x] E11: `passTask` penalty hesaplaması test et (`basePenalty` README'de 50 ama code'da 100)
- [x] E12: `endGame` koşulu — skor bazlı bitiş eksik (sadece tur bazlı var)
- [x] E13: Vote clear sonrası yeni tur geçiş sıralaması

---

## Faz 6 — Çark Animasyonu + Görev Seçimi 🎡
> README: *"Sırası gelen oyuncu dijital çarkı çevirir. Gelen kategori tamamen şansa bağlıdır."*

### Ata (Frontend)
- [x] A25: Çark widget'ı (`spin_wheel.dart`) — 6 kategorili dönen çark ✅
- [x] A26: Task ekranına çark entegrasyonu — çark → kategori → görev ✅
- [x] A27: Çark sonucu kategori badge animasyonu ✅

### Ege (Backend)
- [x] E14: `assignTaskByCategory(gameId, category)` — kategori filtreli görev
- [x] E15: Kullanılmış görev takibi (`usedTaskIds`) — tekrar önleme
- [x] E16: `GameEntity`'ye `usedTaskIds` alanı ekle

---

## Faz 7 — Görünürlük Modları 👁️
> README: *"Açık Mod (içeriği önceden gör) / Kapalı Mod (sadece kategori görünür)"*

### Ata (Frontend)
- [x] A28: CreateRoom'a Görünürlük modu seçici eklendi ✅
- [x] A29: TaskScreen Kapalı Mod — içerik gizli, sadece kategori + çarpan ✅
- [x] A30: "Görevi Aç" butonu — Kapalı Mod'da tıklayınca içerik gösterilir ✅

### Ege (Backend)
- [x] E17: Room modeline `visibility: open | closed` alanı ekle
- [x] E18: Firestore Security Rules — visibility'ye göre content erişim kontrolü

---

## Faz 8 — Avatar Sistemi + Profil 🖼️
> README: *"Her oyuncu kendi fotoğrafını yükler. Puan durumuna göre efektler."*

### Ata (Frontend)
- [x] A31: Profil ekranı (avatar görüntüleme, isim değiştirme) ✅
- [x] A32: Avatar widget (`PlayerAvatar` + puan efektleri) ✅
- [x] A33: Puan bazlı efektler (🔥 alev / ❄️ buz / ✨ parıltı) ✅
- [x] A34: Lobi + oyun ekranlarında avatar göster ✅

### Ege (Backend)
- [x] E19: Firebase Storage avatar upload (`users/{uid}/avatar`)
- [x] E20: User koleksiyonu (`walletPoints`, `avatarUrl`, `rank`)
- [x] E21: Avatar URL → PlayerEntity bağlama

---

## Faz 9 — Meta-Game Puan Ekonomisi 💰
> README: *"Oyun sonunda toplanan puanlar kalıcı cüzdana eklenir."*

### Ata (Frontend)
- [x] A35: Cüzdan ekranı (toplam puan, harcama alanları) ✅
- [x] A36: Kozmetik mağazası UI (çerçeveler, taçlar) ✅
- [x] A37: GameOver → cüzdan puan aktarım animasyonu ✅

### Ege (Backend)
- [x] E22: Economy module (economy_repository, economy_provider)
- [x] E23: Client-Side Transaction — oyun sonu puan doğrulama + cüzdana ekleme
- [x] E24: Kozmetik envanter CRUD (ownedFrames, ownedPacks)

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
