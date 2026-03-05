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
- [x] **Mağaza İçerikleri:** Eksik olan tüm kozmetiklerin (çerçeve, ünvan vb.) Firestore'a girilmesi.

---

## 🟣 FAZ 4: İçerik, Kategori ve Kimlik Doğrulama Güncellemeleri
*Öncelik: Veri yapısının ve giriş yöntemlerinin düzenlenmesi.*

### 🧑‍💻 Ata (UI & Akış)
- [ ] **Apple ile Giriş:** Ekranda yer alan "Apple ile Bağlan" butonunun arayüzden kaldırılması.
- [ ] **İçerik Sayfası:** İçerik sayfasının güncellenmesi ve yeni yapıya göre düzenlenmesi.

### 🧑‍💻 Ege (Mantık & DB)
- [ ] **Custom Deck:** Custom deck'in mevcut kategorilere dahil edilmeyip, ayrı bir kategori yapısına dönüştürülmesi.
- [ ] **Soru İçerikleri:** Sistemdeki/veritabanındaki mevcut soruların düzenlenmesi.
- [ ] **Apple Auth:** Altyapıdan Apple giriş yönteminin (gerekirse) kaldırılması.

---

## 🟠 FAZ 5: Tasarım Yenilenmesi ve Responsive Yapı
*Öncelik: Görsel kalitenin ve cihaz uyumluluğunun artırılması.*

### 🧑‍💻 Ata (UI & Deneyim)
- [ ] **Kapsamlı Tasarım Revizyonu:** Font, görsel, video, butonlar, renkler ve metin içeriklerinin baştan aşağı yenilenmesi.
- [ ] **Responsive Kurulum:** Tüm ekran boyutlarına (farklı telefonlar ve tabletler) uygun responsive yapının oturtulması.

---

> [!NOTE]
> Görevleri tamamladıkça yanlarındaki kutucukları `[x]` şeklinde işaretleyelim.