# Sosyal Risk - Takım Görev Dağılımı (Modüler Çalışma)

Birbirinizle çakışmaları (conflict) önlemek adına tüm görevleri "Görsel/UI" ve "Mantık/State" olarak ikiye ayırdık. 

---

## 🎨 ATA (Arayüz, Metinler, Görseller ve Responsive)
*Ağırlıklı Çalışma Alanları: UI/UX, Widget dizilimleri, Assets (Logolar, ikonlar), Metin/Dil dosyaları.*

### Metin ve İsimlendirme Güncellemeleri
- [ ] "KATEGORİ" yazısı "Kategori" olarak güncellenecek (ve varsa bu tarz büyük harf hataları taranıp düzeltilecek).
- [ ] Sahnelerdeki ve butonlardaki tiyatro temalı eski terimler değiştirilecek:
  - "Sahnedeki görev" -> "Görev"
  - "Gösteriye Katıl" -> "Görevi Başlat"
  - "Gösteri Başladı" -> "Görev Başladı"
  - "Senaryonuz" -> "İçerik"
  - "Senaryoyu sergilediyseniz" -> "Görevi tamamladıysanız performansınızı bitirin"
  - "Performansı bitir" -> "Görevi Bitir"
  - "Ekonomi Oyun modunun" adı -> "Borsa" olarak güncellenecek.
  - Arayüzdeki "göreve özel" yazısı kaldırılacak.
- [ ] Puan metinlerindeki "+" işareti kaldırılacak ("+10 Puan" yerine "10 puan" / "Tahmini Kazan. 10 puan" şeklinde).
- [ ] Görev altındaki "3x Puan" gibi katsayı metinleri, Ata'nın hesapladığı net puan ile birleşip "30 puan", "20 puan" formatında sadece sonuç olarak yazılacak.

### UI İyileştirmeleri ve Bug Fixler
- [ ] **İstatistikler Ekranı:** "Bakiye", "Rütbe", "Ev", "Koleksiyon" değerleri sağa yaslanacak. *(biraz uğraştırabilir)*
- [ ] **Profil Ekranı:** 
  - İsim, profil fotoğrafına hizalanacak.
  - Kalem ikonu ismin direkt yanına alınacak. *(biraz uğraştırabilir)*
  - Profil fotoğrafı çerçevesinin kare olma sorunu çözülüp fotoğrafı tam kaplaması sağlanacak.
- [ ] **Pop-uplar ve Boş Durumlar (Empty States):**
  - Çıkış yap pop-up'ında "Hayır" ve "Sil Ve Çık" butonlarındaki harflerin hepsi büyük harf olmayacak.
  - Eşyalar (Items) boş sekmesine "Henüz bir eşyanız yok, mağazadaki harika içeriklere göz atmak ister misiniz?" yazısı eklenecek ve altına "Mağaza"ya yönlendiren buton konulacak.
- [ ] **Lobi Ekranı:**
  - Dönen yazıların içeriği ve rastgele çıkan diğer içerikler düzenlenecek.
  - O an oynanacak oyun modunun bilgisi ana lobiye eklenecek.
- [ ] **Menü Yapısı:**
  - Ana sayfadaki "Ayarlar" butonu "Menü" olacak ve tıklayınca alttan (Bottom Sheet) açılacak. Menü başlığı "Menü" olacak.
  - Menü listesine "Ayarlar" eklenecek (Ses/Dil değişiklikleri buradan yapılacak).
  - Menü ekranından "Profil" seçeneği kaldırılacak.
  - Ayarlar/Menü alanının en altına "2026 Tüm Hakları Saklıdır" yazısı eklenecek.
- [ ] Çark modundaki katman renkleri yenilenecek (her kategoriye farklı renk atanacak).
- [ ] Emote (Tepki) ekranına mevcut 7 seçeneğe 1 tane daha eklenerek 8'e çıkartılacak (UI yerleşimi tasarlanacak).
- [ ] Liderlik tablosunda kullanıcının kendi ismi vurgulu (highlighted) görünecek.
- [ ] Tüm cihazlarda genel Responsive kaymaları / boyutlandırmaları kontrol edilip çözülecek.

### Asset ve İçerik Görevleri
- [ ] Oyun logosu, logonun altındaki logotype ve mobil logolar güncellenecek. *(biraz uğraştırabilir)*
- [ ] Mağazadaki "bilet (ticket)" logosu uygun/yeni bir ikonla değiştirilecek.
- [ ] İçerik havuzu (sorular, görevler) Ege tarafından gözden geçirilip metinsel olarak düzenlenecek.

---

## ⚙️ EGE (Oyun Mantığı, State Management ve Core Sistemler)
*Ağırlıklı Çalışma Alanları: Provider/Bloc (State), Oyun Döngüsü, Matematik/Puan Hesaplamaları, Testler, Entegrasyonlar.*

### Oyun Mantığı ve Döngüsü (Game Loop)
- [ ] Oyun sonunda (son görev bitince) ara ekran atlanıp direkt sonuç ekranına (Liderlik/Puan tablosu) geçilecek.
- [ ] Tur bitimi sahnesinde çıkacak karakter ifadesi (Emote), görevin seyirci tarafından "Beğenilme/Beğenilmeme" durumuna göre dinamik olarak değiştirilecek.
- [ ] Çark modunda üst üste aynı kişiye görev gelmemesi için rastgele oyuncu seçimi mantığı (sıra mekanizması) kontrol edilip düzeltilecek.
- [ ] Tek kategori seçildiğinde, sistemin otomatik "Borsa Moduna" geçmesi ve kullanıcıya uyarı pop-up'ı çıkarılması logic'i yazılacak (Katsayının sabit kalacağına dair).
- [ ] Zamanlayıcı (Timer) senkronizasyonu: Geri sayım sayacında alt ve üst sayaçlar birbiriyle tutarlı (senkron) hale getirilecek.
- [ ] Çıkış onayındaki "Sil ve Çık" butonu için 10 saniyelik bir geri sayım engeli konulacak. Süre bitmeden buton aktifleşmeyecek.

### Borsa (Ekonomi) Modu Özel Mantık ve Fixler
- [ ] **Puan Dağılımı:** Maç sonu +5 hardcoded puan kaldırılacak; ilk 3 oyuncuya sırasıyla `200, 100, 50`, geri kalanlara `20'şer` puan verilme sistemi yazılacak.
- [ ] **Dinamik Görev Puanları:** Görev tamamlanınca verilen "10" hardcoded puan yerine, "Katsayı x Temel Puan" (örn: 12 puanlık oyunda 3x çarpan = 36) dinamik hesaplaması sisteme entegre edilecek.
- [ ] Tahmini kazanç metinlerine gidecek veriler dinamik hesaplanıp Ege'nin UI'ına sunulacak. Bütün Borsa modunun toplam puan hesaplaması ve senkron kaymaları düzeltilecek.
- [ ] **Tur Arızaları:** Borsa modunda bazı durumlarda turun ilerlememesi/hiç geçmemesi ve "oyunun bitmeme sorunu" kontrol edilip çözülecek (Turn-Skip bug'ı).
- [ ] Oyundan çıkıldığında "Odadan Ayrıldınız" tarzında oyuna uygun bir "toaster/snackbar" tetiklenecek.
- [ ] Kategori seçiminden sonra arkada zorluk seviyesi ekranının kısa süreli görünmesi/atlaması (UI state sıçraması / routing sorunu) engellenecek.
- [ ] **Borsa/Ekonomi Mantığı İçin Test Yazımı:** Yukarıdaki puan/tur hesaplamalarının bir daha bozulmaması adına `Mantık hesaplama bölümü için Test Scripti` yazılacak.

### Yeni Sistem Entegrasyonları (Altyapı)
- [ ] **Achievement Sistemi:** Profil ekranında görünecek "Başarımlar (Achievements)" kontrol mekanizması ve database/state altyapısı kurulacak.
- [ ] **Auth:** +18 içerik girişleri için Google Authentication yaş/izin check işlemi eklenecek.
- [ ] **Localization (Yerelleştirme):** Oyuna çoklu dil desteği kazandıracak altyapı (örn. `easy_localization` vb.) entegre edilecek. (Metinleri daha sonra Ege doldurabilecek).
- [ ] **Ses (Sound) Sistemi:** Yeni ses efektlerini (arka plan müziği, tık efektleri, başarı sesleri vb.) tetikleyecek "AudioPlayer" servis/altyapısı kurulacak.