# 🎭 SocialRisk Geliştirme Takip Listesi

Bu liste Ata ve Ege'nin paralel çalışabilmesi için fazlara ayrılmıştır.

## 🟢 FAZ 1: Kritik Oyun Akışı ve Hata Düzeltmeleri
*Öncelik: Oyunun temel mekaniklerinin doğru çalışması.*

### 🧑‍💻 Ata (UI & Akış)
- [ ] **"Gösteri Başladı" Hatası:** Client tarafında ekranın 2 kez gelmesi (çift yönlendirme) sorununun çözülmesi.
- [ ] **Görsel Düzenleme:** "Performansını Sergiliyor" ekranının tam ortalı görünmesi için layout düzeltmesi.

### 🧑‍💻 Ege (Mantık & DB)
- [ ] **Puanlama Hatası:** Görevi reddedince/yapamayınca -150 puan düşme mantığının düzeltilmesi.
- [ ] **Oyun Bitiş Kontrolü:** Tur sayısı bittiğinde oyunun `GameStatus.finished` durumuna geçmemesi sorununun çözümü.

---

## 🟡 FAZ 2: Senkronizasyon ve Kullanıcı Deneyimi
*Öncelik: Oyuncular arası etkileşim ve akıcılık.*

### 🧑‍💻 Ata (UI & Deneyim)
- [ ] **Loading Ekranları:** Veri çekme ve geçiş anlarına "Sahne Hazırlanıyor..." tadında yükleme ekranları eklenmesi.
- [ ] **Tur Sayacı:** Oyun ekranına "Kalan Tur: X" veya "Tur: 1/5" göstergesinin eklenmesi.

### 🧑‍💻 Ege (Mantık & DB)
- [ ] **Oyundan Çıkma:** Aktif oyundan/odadan güvenli çıkış butonunun işlevsel hale getirilmesi.
- [ ] **Liste Senkronizasyonu:** Bir oyuncu çıktığında lobi/oyun listesinin diğerlerinde anlık güncellenmesi.

---

## 🔵 FAZ 3: İçerik ve Cila
*Öncelik: Eksik verilerin tamamlanması ve son dokunuşlar.*

### 🧑‍💻 Ata (UI & Polish)
- [ ] Genel arayüz cilalaması (Smooth geçişler ve mikro etkileşimler).

### 🧑‍💻 Ege (Mantık & DB)
- [ ] **Mağaza İçerikleri:** Eksik olan tüm kozmetiklerin (çerçeve, ünvan vb.) Firestore'a girilmesi.

---

> [!NOTE]
> Görevleri tamamladıkça yanlarındaki kutucukları `[x]` şeklinde işaretleyelim.