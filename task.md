# Sosyal Risk - Eksik Tasklar Listesi

## 1. Arayüz ve Metin Güncellemeleri (UI & Text Changes)
- [ ] "KATEGORİ" yazısını "Kategori" olarak güncellenecek. varsa bu tarz hataların tümünü kontrol etsin.
- [ ] Puanlardaki "+" işaretini kaldırılacak (Örn: "+10 Puan" yerine "10 puan"). "Tahmini Kazan. +10 Puan" vb. metinler "10 puan", "20 puan" formatında düzeltilecek.
- [ ] "Sahnedeki görev" metni "Görev" olarak değiştirilecek.
- [ ] Görev altındaki "3x Puan" gibi katsayılar hesaplanmış net puan ("30 puan", "20 puan" vb.) olarak yazılacak.
- [ ] "Gösteriye Katıl" butonu "Görevi Başlat" yapılacak.
- [ ] "Gösteri Başladı" metni "Görev Başladı" yapılacak.
- [ ] "Senaryonuz" başlığı "İçerik" olarak değiştirilecek.
- [ ] "Senaryoyu sergilediyseniz" uyarısı "Görevi tamamladıysanız performansınızı bitirin" yapılacak.
- [ ] "Performansı bitir" butonu "Görevi Bitir" yapılacak.
- [ ] İstatistikler ekranında "Bakiye", "Rütbe", "Ev", "Koleksiyon" değerleri sağa yaslanacak. (biraz uğraştırabilir)
- [ ] Profil düzenleme ekranında isim profil fotoğrafına hizalanacak, kalem ikonu ismin direkt yanına alınacak. (biraz uğraştırabilir)
- [ ] Çıkış yap pop-up'ında "Hayır" ve "Sil Ve Çık" butonlarındaki harflerin hepsi büyük harf olmayacak.
- [ ] Eşyalar (Items) boş sekmesinde "Henüz bir eşyanız yok, mağazadaki harika içeriklere göz atmak ister misiniz?" yazısı gösterilecek ve altına "Mağaza"ya yönlendiren buton eklenecek.
- [ ] Lobi ekranında dönen yazıların içeriği düzenlecek ve Rastgele ekranda çıkan diğer içerikler düzenlenecek. 
- [ ] Lobi ekranına o an oynanacak oyun modu bilgisi eklenecek.
- [ ] Çark modundaki renkler yenilenecek. (her kategori farklı renk)
- [ ] Arayüzdeki "göreve özel" yazısı kaldırılacak.
- [ ] Oyuncu sıralamasında herkes kendi ismini vurgulu (highlighted) görecek.
- [ ] Ekonomi Oyun modunun adı "Borsa" olarak değiştirilecek.
- [ ] "Menü" yapısının güncellenmesi:
  - [ ] Ana sayfadaki "Ayarlar" butonu "Menü" olacak ve tıklandığında alttan açılacak.
  - [ ] Alttan açılan barın başlığı "Menü" olacak.
  - [ ] Menü listesinde "Ayarlar" eklenecek ve ses açma/dil değişikliği bu alt ekrandan yapılacak.
  - [ ] Menü ekranından "Profil" seçeneği kaldırılacak.
  - [ ] Ayarlar bölümünün en altında 2026 Tüm Hakları Sakldıır yazsın.
- [ ] Profil fotoğrafı etrafındaki çerçevenin kare olma sorunu çözülüp tam kaplaması sağlanacak.
- [ ] Oyun logosu, logo altındaki logotype ve uygulamanın mobil logoları güncellenecek. (biraz uğraştırabilir)
- [ ] Mağaza içerisindeki bilet (ticket) logosu farklı ve uygun bir ikonla değiştirilecek.
- [ ] Tepki/Emote seçim ekranındaki mevcut 7 seçeneğe 1 tane daha eklenerek 8'e çıkartılacak.
- [ ] Tüm cihaz türlerindeki genel Responsive kaymaları / boyutlandırmaları kontrol edilecek.



## 2. Oyun Mantığı ve Hata Çözümleri (Logic & Bug Fixes) (Test Scripti Yazılabilir)
- [ ] Oyun sonunda (son görevden sonra) görev sonu ara ekranı atlanıp direkt sonuç ekranına gidilecek.
- [ ] Borsa Modu (Ekonomi) Puan/Mantık Hataları:
  - [ ] +5 puan hardcoded olarak verilmeyecek. İlk 3 oyuncuya sırasıyla 200, 100, 50 puan, geri kalanlara 20 puan verilecek.
  - [ ] Tahmini kazanç yazıları statik değil, çarpan katsayısına göre dinamik hesaplanıp gösterilecek.
  - [ ] Görev tamamlandıktan sonra verilen puanlar hardcoded 10 yerine seçilen katsayıyla dinamik verilecek (örn: 12 puanlık oyunda 3x çarpan varsa 36 puan). Mod genelinde toplam puan hesaplaması düzeltilecek.
  - [ ] Tur mekanizması arızaları (örn: 3 turluk oyunda birine turun hiç geçmemesi) onarılacak.
  - [ ] Oyunun bitmeme sorunu düzeltilecek.
  - [ ] Borsa modunda oyundan çıkıldığında "Odadan Ayrıldınız" tarzında bir toaster uyarısı gösterilecek.
- [ ] Ekonomi modunda kategori seçimi sonrasında, arkada zorluk seviyesi ekranının kısa süreliğine görünmesi/atlaması engellenecek.
- [ ] Çark modunda üst üste aynı kişiye görev gelmemesi için sıra mekanizması kontrol edilecek.
- [ ] Geri sayım sayacında (timer) alt ve üst sayaçlar birbiriyle senkron çalışacak.
- [ ] Çıkış onayındaki "Sil ve Çık" butonu kullanıcının okuyabilmesi için 10 saniyelik geri sayımdan sonra aktif hale gelecek.
- [ ] Tur bitti sahnesindeki karakter ifadesi (emote), görevin beğenilip beğenilmeme durumuna göre dinamik değişecek.
- [ ] Tek kategori seçildiği durumlarda sistem otomatik "Borsa Moduna" geçecek, uyarı pop-up'ı (katsayının sabit kalacağı vb. hakkında) gösterilecek.
- [ ] İçerik havuzu (sorular, görevler) gözden geçirilip düzenlenecek.
  [ ] Test Scripti Yazılabilir Mantık hesaplama bölümü için.

## 3. Yeni Özellikler (New Features)
- [ ] Profil ekranına "Başarımlar (Achievements)" eklenecek.
- [ ] +18 içerikler için Google Authentication check işlemi yapılacak.
- [ ] Oyuna çoklu dil kullanımını destekleyecek yerelleştirme (Localization) altyapısı eklenecek.
- [ ] Yeni "Ses" (Sound) entegrasyonları oyuna dahil edilecek.