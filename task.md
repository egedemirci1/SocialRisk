# 🎭 SocialRisk Geliştirme Takip Listesi

Bu liste Ata ve Ege'nin paralel çalışabilmesi için fazlara ayrılmıştır.

## 🟢 FAZ 1: Kritik Oyun Akışı ve Hata Düzeltmeleri
*Öncelik: Oyunun temel mekaniklerinin doğru çalışması.*

### 🧑‍💻 Ata (UI & Akış)
- [x] **"Gösteri Başladı" Hatası:** Client tarafında ekranın 2 kez gelmesi (çift yönlendirme) sorununun çözülmesi.
- [x] **Görsel Düzenleme:** "Performansını Sergiliyor" ekranının tam ortalı görünmesi için layout düzeltmesi.

### 🧑‍💻 Ege (Mantık & DB)
- [x] **Puanlama Hatası:** Görevi reddedince/yapamayınca -150 puan düşme mantığının düzeltilmesi.
- [x] **Oyun Bitiş Kontrolü:** Tur sayısı bittiğinde oyunun `GameStatus.finished` durumuna geçmemesi sorununun çözümü.

---

## 🟡 FAZ 2: Senkronizasyon ve Kullanıcı Deneyimi
*Öncelik: Oyuncular arası etkileşim ve akıcılık.*

### 🧑‍💻 Ata (UI & Deneyim)
- [x] **Loading Ekranları:** Veri çekme ve geçiş anlarına "Sahne Hazırlanıyor..." tadında yükleme ekranları eklenmesi.
- [x] **Tur Sayacı:** Oyun ekranına "Kalan Tur: X" veya "Tur: 1/5" göstergesinin eklenmesi.

### 🧑‍💻 Ege (Mantık & DB)
- [x] **Oyundan Çıkma:** Aktif oyundan/odadan güvenli çıkış butonunun işlevsel hale getirilmesi.
- [x] **Liste Senkronizasyonu:** Bir oyuncu çıktığında lobi/oyun listesinin diğerlerinde anlık güncellenmesi.

---

## 🔵 FAZ 3: İçerik ve Cila
*Öncelik: Eksik verilerin tamamlanması ve son dokunuşlar.*

### 🧑‍💻 Ata (UI & Polish)
- [x] Genel arayüz cilalaması (Smooth geçişler ve mikro etkileşimler).

### 🧑‍💻 Ege (Mantık & DB)
- [x] **Soru İçerikleri:** "Varsayılan İçerik" ve "Özel Senaryo" ayrımı kaldırıldı. Custom (Özel) seçeneği kategoriler listesine eklendi ve seçildiğinde kullanıcının kendi görevleri oyuna dahil edilecek.lmesi.

---

## 🟣 FAZ 4: Kategori ve Kimlik Doğrulama Güncellemeleri
*Öncelik: Veri yapısının ve giriş yöntemlerinin düzenlenmesi.*

### 🧑‍💻 Ata (Genel Görevler)
- [x] **Apple ile Giriş:** Ekranda yer alan "Apple ile Bağlan" butonunun arayüzden kaldırılması ve altyapıdan (gerekirse) temizlenmesi.
- [x] **Custom Deck:** Custom deck'in mevcut kategorilere dahil edilmeyip, ayrı bir kategori yapısına dönüştürülmesi.

---

## 🟠 FAZ 5: "Clean Party Energy" Tasarım Yenilenmesi
*Öncelik: Görsel kalitenin, eğlence hissiyatının ve responsive yapının artırılması.*

### 🎨 Tasarım Sistemi ve Çekirdek Yapı
- [x] **Renk Paleti Revizyonu:** `AppColors` dosyasının İndigo-Mango-Turkuaz paletine güncellenmesi.
- [/] **Buton Redesign:** `StageButton` widget'ının oval "hap" şekline ve Nunito fontuna geçirilmesi.
- [x] **Web Splash:** `index.html` üzerinden web yükleme ekranının indigo temaya uyarlanması.

### 📱 Ekran Bazlı Güncellemeler
- [x] **Karşılama Ekranı (Splash):** Dart tarafındaki yükleme ekranının temizlenmesi.
- [x] **Giriş (Login) & Ana Menü (Home):** Tiyatro fontlarının kaldırılması, Poppins fontlu "pop" başlıkların ve geniş ekran sınırlamalarının eklenmesi.
- [x] **Oda Kurma (Create Room):** Silik cyan başlıkların belirginleştirilmesi, tiyatro terimlerinin (Perde vs.) parti terimleriyle değiştirilmesi, tüm çiplerin ovalleştirilmesi.
- [ ] **Lobi & Oyun Ekranları:** Kalan tüm ekranlardaki eski tırnaklı fontların ve kahverengi tonların temizlenmesi.
- [ ] **Responsive İnce Ayar:** Tablet ve web görünümünde içeriklerin çok yayılmaması için `ConstrainedBox` kontrollerinin yaygınlaştırılması.

### 🔔 Hata Yönetimi & Bildirimler (Toaster)
- [x] Merkezi ToastUtils yapısının kurulması ve tüm ScaffoldMessenger.showSnackBar yapısının buna taşınması (Ege) <!-- id: 14 -->
- [x] Toast bildirimlerinin sağ üste taşınması ve Overlay yapısına geçilmesi (Ege) <!-- id: 17 -->
- [x] Giriş ekranında en az 3 karakter kontrolü eklenmesi (Ege) <!-- id: 18 -->
- [x] Toast tasarımlarının (Success, Error, Warning, Info) yapılması (Ege) <!-- id: 15 -->
- [x] Tüm sayfalardaki (Login, Profile, Room, Admin, Game vb.) snackbar çağrılarının ToastUtils ile değiştirilmesi (Ege) <!-- id: 16 -->

---

> [!NOTE]
> Görevleri tamamladıkça yanlarındaki kutucukları `[x]` şeklinde işaretleyelim.