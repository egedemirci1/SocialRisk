# Sosyal Risk - Hata Ayıklama & Geliştirme Planı (Modüler Çalışma)

Bu görev listesi, detaylı testlerin ardından bildirilen hata (bug) raporları ve UX iyileştirme talepleri doğrultusunda yapılandırılmıştır.

---

## 🎨 ATA (UI/UX, Responsive, Tasarım)

### 1. Responsive ve Ekran Taşma (Overflow) Sorunları
- [x] **Lobi Ekranı Kart Sıkışması:** Lobi ekranında 5'ten fazla oyuncu girince kartlar sığmıyor. 8 kişiye kadar sığacak şekilde oyuncu kartlarının boyutları dinamik (responsive) olarak ayarlanacak. Kartlar cihaz boyutuna göre ölçeklenmeli. Header kısmına da "Mevcut/Toplam (örn. 1/8)" kişi bilgisi eklenecek.
- [x] **Görev Sahnesi (Task Screen):** Küçük telefonlarda menü tasarımı sabit pixelle çizildiği için scroll'a giriyor. Görev kartının yüksekliği ve aşağıdaki izleyici avatarları yüzdelik dilimlerle (Flexible/Expanded) sınırlandırılacak.
- [x] **Oylama Ekranı (Voting Screen):** Beğen/Nötr/Beğenme butonları (VotingPanel) küçük ekranlarda sorunun/kartın üstüne taşıyor. "Eleştirme ve Oylama" yazısı responsive şekilde küçültülüp kartlaştırılacak ve butonların güvenli alanda (SafeArea) kalması sağlanacak.
- [ ] **Tur Bitti Ekranı (Round Result):** Küçük telefonlarda elementler sıkışıyor ve scroll çıkıyor. Elementler (skorlar vb.) UI sınırlarına göre otomatik küçülecek (FittedBox/Expanded).
- [ ] **Performans Sahnesi:** "Rezem oynuyor" veya "Senin sıran" yazıları boyutlandırma sınırları olmadığı için profil fotoğrafıyla (avatar) iç içe giriyor. İki element arasına boşluk ve esneklik (Flexible) eklenecek.
- [ ] **Zorluk Seçimi (Sıcak Fırsat):** Borsa modunda kategori/zorluk seçerken en alttaki element overflow oluyor. Ayrıca kart içindeki "Sıcak Fırsat" (3x) yazısı diğer yazılarla çakışıyor, responsive hale getirilecek.
- [ ] **Oyun Sonu Ekranı (Game Over):** Kupa logosu ve kazanan bilgisi yukarıdan (start align) çizilse ekranda daha fazla yer açılır. Aşağıdaki skor sıralaması listesi daha ferah konumlandırılacak.
- [ ] **Çark Modu Görev Alanı:** Çark modunda görev sunulurken ekran küçükse gereksiz şekilde scroll çıkıyor, görev kartı ana ekrana sığacak şekilde ayarlanacak.
- [ ] **Çerçevelerin Ölçeklenmesi:** Tıpkı lobide olduğu gibi oyun içi (ör. altta duran izleyiciler) çerçeve çizimleri de ekran bazlı responsive ölçeklenecek.
- [ ] **Puan Durumu Tablosu (Leaderboard/Bottom Sheet):** Oyun içi puan durumu gösterildiği zaman oyuncu sayısı çoksa, o liste de responsive olarak lobideki mantıkla sıkışmadan çalışacak.

### 2. Görsel / UI Düzeltmeleri
- [ ] **Doğa Çerçevesi Dengesi:** "Doğa" çerçevesi tasarımı diğerlerinden büyük durduğu için biraz küçültülerek diğer çerçevelerle görsel denge yakalanacak.
- [ ] **İçerik Ekleme Sekmesi:** İçerik ekleme sayfasında (CustomDeck) "İptal" ve "İçerik Ekle" butonları arasına boşluk (spacing) eklenecek.
- [ ] **Kategori İsimleri Formatı:** Senaryo seçimindeki kategori adları "BILGI" şeklinde düz İngilizce ve büyük harf çıkıyor. Türkçe kuralına uygun (sadece ilk harf büyük "Bilgi") şekilde gösterilecek.
- [ ] **Profil Fotoğrafı Konumu:** Sıra bize geldiğinde profil fotoğrafı aşırı yukarıda ve yapışık duruyor. Yeri hafifçe aşağıya (margin/padding) alınacak, üst limit korunacak.

---

## ⚙️ EGE (Backend, Oyun Döngüsü, State Management)

### 1. Oyun Mantığı ve Döngüsü Bugları

- [X] **Senkronizasyon / Oyunda Kalma Bug'ı (Kritik):** 4 kişilik oyunda (hem borsa hem çark) oyun sonunda sonuç ekranını (GameOver) sadece kurucu (Host) görüyor. Diğerleri yükleniyorda/voting'de/performing'de asılı kalıyor. *(Neden: Host oyunu bitirip `GameStatus.finished` gönderdiğinde clone state alan dinleyiciler (stream) routing yapamıyor. Voting/RoundResult state kontrollerindeki stream logic düzeltilmeli.)*
- [X] **Puanlama Matematiği Eksikliği (Kritik):** 4 kişilik oylamada (2 kararsız, 1 beğenmedim) -> *Bu normalde eksi puandır.* Ancak 2 kararsız 1 beğendim olunca oylama x3 katsayıyla 60 puan veriyor. *(Neden: Bonus matematiği yanlış dengelenmiş. Temel Puan * Çarpan mekanizması izleyici oylarıyla doğru ağırlıkta hesaplanmıyor.)*

### 2. Admin ve Bildirim Entegrasyonları
- [ ] **Yönetici Paneli Sınırları:** Yönetici paneli backend tarafında kontrol edilecek. Soru ekleme/çıkarma işlevleri durdurulup sadece temel panel özellikleri netleştirilecek.

- [ ] **Sahne Adı Hatası (Login):** Giriş yaparken "Lütfen sahne adınızı belirleyin" toast hatası yersiz tetikleniyorsa giderilecek.

### 3. Yeni Özellik ve Check'ler
- [ ] **Gelişmiş İstatistikler:** Kullanıcı modeline Toplam Oyun Sayısı, Kazanılan Şampiyonluk, En Yüksek Puan gibi rekor verileri (DB) eklenecek ve İstatistikler panelinde gösterilecek.
- [ ] **Rütbe (Rank) Sistemi Kontrolü:** "Çırak" rütbesi neye göre belirleniyor, diğer eşikler neler? Rank mekanizması kontrol edilip düzene oturtulacak.
- [ ] **Özel Senaryo Testi:** Şuan mağazada "Yakında" olarak kilitli olan özel senaryo db yapılarının backend tarafında doğru kilitlenip kilitlenmediği test edilecek.