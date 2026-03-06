# Sosyal Risk Görsel & Deneyim (UX) Geliştirme Yol Haritası

Bu liste, analiz raporunda belirlenen "Premium Parti Deneyimi" hedeflerine ulaşmak için uygulanacak somut adımları içerir. Her madde, oyunun ruhunu güçlendirmek ve oyuncuyu ekran başında tutmak için tasarlanmıştır.

## 1. Genel Altyapı ve Duyusal Geri Bildirim
- [ ] **Haptic Feedback (Titreşim) Katmanı:** `HapticFeedback` kullanarak; butonlara basıldığında `lightImpact`, görev onaylandığında `mediumImpact`, ceza alındığında veya süre bittiğinde ise `vibrate` (uzun titreşim) tetikleyicileri eklenecek. Telefon artık oyunla birlikte tepki verecek.
- [ ] **Tematik Ses Efektleri (Opsiyonel/Altyapı):** Çark dönerken "tık-tık" sesleri ve oylama tamamlandığında bir "başarı/alkış" sesi için `audioplayers` altyapısı kurulacak (dosyalar yoksa ses kütüphanesi hazır tutulacak).

## 2. Karşılama ve Atmosfer (Login & Home)
- [x] **Dinamik Neon Arka Plan:** Login ekranındaki sabit ışıklandırma yerine, yavaşça yer değiştiren, nefes alan (fade-in/out) mor ve camgöbeği mesh-gradient tozları eklenecek. Ekran "yaşayan bir parti alanı" gibi hissettirecek.
- [x] **Giriş Butonunun Enerjisini Artırma:** "Giriş Yap" butonu "Partiye Katıl!" olarak güncellenecek. Butona basıldığında bir anlık beyaz parlama (flare) efekti ve haptic feedback ile oyuncu içeri "davet" edilecek.

## 3. Kurulum ve Bekleme Ekranları (Create Room & Lobby)
- [x] **Ateşli Slider Tasarımı:** Oda kurarken Puan/Tur slider'ı; düşük değerlerde (5-10) sakin mavi/teal rengindeyken, değer arttıkça (`Color.lerp` ile) turuncuya ve ardından "Ateşli" kırmızıya dönecek. Sayı fontu seçilen değer büyüdükçe hafifçe "pop" (scale up) yapacak.
- [-] **Lobi Etkileşimi (Poke/Dürtme):** *(İptal Edildi - Sunucu yükü sebebiyle kaldırıldı)* Bekleyen oyuncular canı sıkılmasın diye, diğer oyuncuların avatarlarına tıkladığında o avatarın üzerinden uçuşan 🔥, 😂, 👀 emojileri çıkacak. Bu, lobiyi sosyal bir alana çevirecek.
- [x] **Host İçin "Başlat" Çağrısı:** Odadaki herkes "Hazır" olduğunda, Host'un ekranındaki "Oyunu Başlat" butonu bir neon aura ile parlamaya ve hafifçe sallanmaya (shake) başlayacak: "Haydi, herkes seni bekliyor!" mesajını verecek.

## 4. Oyun İçi Senaryo ve Görev Anı (Task Screen)
- [ ] **Riskli Pass Butonu:** Görevi reddetme butonu (`TextButton`'dan `OutlinedButton`'a) daha belirgin ve uyarıcı hale getirilecek. Basıldığında ekran hafifçe sarsılacak ("Emin misin?") ve puan kaybı görsel bir kırmızı efektle vurgulanacak.
- [ ] **Gizli Görev "Kazıma" Deneyimi:** Kapalı oyunlarda karta dokunup butonla açmak yerine; kartın üstünde gümüş bir katman olacak ve oyuncu parmağıyla (veya uzun basarak) bu katmanı "kazıyarak" görevi görecek. Bu, merak duygusunu fiziksel bir eyleme dönüştürecek.

## 5. Oylama ve Gerilimin Zirvesi (Voting Screen)
- [ ] **Ambiyans Işıklandırması:** Oylama esnasında arka plan rengi, görevin o anki zorluk derecesine göre (Zor: Kırmızı, Kolay: Yeşil) köşelerden hafifçe yanıp sönen bir ışık (glow) verecek. Odadaki gerilim görselleştirilecek.
- [ ] **Dinamik "Zaman Baskısı" Barı:** Her oylamaya 20 saniyelik bir geri sayım barı eklenecek. Bar kısaldıkça rengi sarıdan kırmızıya dönecek ve son 3 saniyede titreyerek oyuncuyu hızlı karar vermeye itecek.
- [ ] **Psikolojik Metinler:** "Herkes senin kararını bekliyor...", "Zaman daralıyor!" gibi rastgele seçilen gaz verici metinler ekranın ortasında süzülecek.

## 6. Final ve Ödüllendirme (Round Result Screen)
- [ ] **Skor Patlaması:** Kazanılan puan ekrana geldiğinde sadece text değil, arkasından bir havai fişek/emoji patlaması çıkacak. Puan ne kadar yüksekse patlama o kadar büyük olacak.
- [ ] **Liderin Tahtı:** Liderlik tablosunda o anki birinci oyuncunun satırı altın sarısı parlayan bir çerçeve (`Glow`) ve yanında küçük bir taç ikonuyla gösterilecek. Rekabet görsel olarak ödüllendirilecek.
- [ ] **Host Buton Karakterizasyonu:** "SIRADAKİ GÖREV" yerine "SIRADAKİ KURBANINI SEÇ" gibi oyunun eğlence tonuna uygun, daha kışkırtıcı metinler kullanılacak.