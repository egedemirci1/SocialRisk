---
name: Loading + Kategori Hazır
overview: "İki görev: (1) Firebase/odaya bağlanma ve oyun başlatma sırasında tam ekran loading overlay ile donma hissini gidermek; (2) Kategori veri yapısını tek kaynaktan sabitleyip admin panelinde \"içerik girişine hazır\" durumunu netleştirmek."
todos: []
isProject: false
---

# Loading State Yönetimi + Kategori Kontrolü & Veri Girişi Onayı

## Mevcut Durum Özeti

- **Loading:** `LoadingOverlay` ve `TheaterLoadingScreen` zaten var. Odaya katılma ekranında "Sahneye bağlanılıyor..." kullanılıyor; oyun ekranları (waiting, task, performing, voting) async veri yüklenirken `TheaterLoadingScreen` gösteriliyor. **Eksik:** Lobby'de host "PERDEYİ AÇ" tıkladığında `startGameInRoom` (Firestore’da task pool çekme + oyun dokümanı yazma) sırasında hiç loading gösterilmiyor; ekran donmuş gibi görünebiliyor.
- **Kategoriler:** Firestore’da `categories` koleksiyonu yok; **kategoriler tamamen local (kodda)**. Soru metinleri de local bir seed dosyasında tutulacak; istenirse bu dosyadan Firestore’a tek seferlik seed yapılabilir veya uygulama ileride sadece local dosyadan okuyabilir.

---

## Görev 1: Bekleme (Loading) State Yönetimi

**Hedef:** Odaya bağlanırken ve oyun başlarken (soru çekilirken) tam ekran loading ile donma hissini kaldırmak.

**Yapılacaklar:**

1. **Lobby – "PERDEYİ AÇ" (start game) sırasında loading**
  - [lib/features/room/presentation/lobby_screen.dart](lib/features/room/presentation/lobby_screen.dart) içinde `_isStartingGame` (veya benzeri) bir state ekle.
  - "PERDEYİ AÇ" tıklandığında bu state’i `true` yap; `startGameInRoom` bitince (veya hata olursa) `false` yap.
  - Sayfayı `Stack` içine alıp, `_isStartingGame == true` iken tam ekran **TheaterLoadingScreen** overlay göster (mesaj: **"Sahne Hazırlanıyor..."**). Mevcut [lib/shared/widgets/common/theater_loading_screen.dart](lib/shared/widgets/common/theater_loading_screen.dart) kullanılabilir; gerekirse `LoadingOverlay` ile aynı davranışı sağlayan bir wrapper (örn. tam ekran `TheaterLoadingScreen` + `IgnorePointer`) kullanılabilir.
  - Böylece soru çekilirken ve oyun dokümanı yazılırken kullanıcı net bir yükleme mesajı görür.
2. **Diğer noktaların kontrolü (opsiyonel dokunuşlar)**
  - Odaya katılma: Zaten [lib/features/room/presentation/join_room_screen.dart](lib/features/room/presentation/join_room_screen.dart) `LoadingOverlay` + "Sahneye bağlanılıyor..." kullanıyor; değişiklik gerekmez.
  - Oyun ekranları: Waiting/Task/Performing/Voting ekranları `AsyncValue.loading()` dalında zaten `TheaterLoadingScreen` kullanıyor; ek bir işlem gerekmez.

**Özet:** Asıl değişiklik sadece lobby’de "PERDEYİ AÇ" akışına `isLoading` + tam ekran "Sahne Hazırlanıyor..." overlay’inin eklenmesi.

---

## Görev 2: Kategori Kontrolü & Veri Girişi Onayı

**Hedef:** Kategorilerin tek kaynakta (kodda) tutulması; admin panelinden içerik girişine "Hazır" durumunun netleştirilmesi. **Veritabanında kategori koleksiyonu yok;** sadece bu sabit liste kullanılacak.

### Sabit kategoriler (8 + Özel)


| ID (isim)    | Kısa açıklama                                                                         |
| ------------ | ------------------------------------------------------------------------------------- |
| **Fiziksel** | Bedensel hareket ve refleks; denge, hız, fiziksel koordinasyon.                       |
| **Bilgi**    | Baskı altında hafıza; grubun geçmişi, popüler kültür, absürt detaylar, kısıtlı süre.  |
| **Dijital**  | Siber risk ve gizlilik; telefon, galeri, mesajlaşma, sosyal medya "dijital ayak izi". |
| **İtiraf**   | Maske düşüren gerçekler; sırlar, cringe anılar, unpopular opinion.                    |
| **Zihinsel** | Odaklanma ve kelime oyunları; kelime yasakları, tersinden konuşma, zihin tuzakları.   |
| **Ahlaki**   | Etik ikilemler ve şeytanın avukatlığı; sınırlar ve tabular.                           |
| **Görsel**   | Soyut anlatım ve taklit; çizerek, mimiklerle veya objelerle ifade (konuşma yasak).    |
| **Mahrem**   | Cinsellik ve tabular; cinsel gerilim, kaçamaklar, fanteziler, flört.                  |
| **Özel**     | Oyuncunun eklediği custom kategori (oda/oyunda "custom deck" ile kullanılır).         |


Uygulama tarafında **defaultCategories** = bu 8 sabit isim (+ oyun/oda akışında Özel ayrı ele alınır). Admin task editor’da TÜR dropdown’unda 8 sabit + isteğe bağlı Özel gösterilebilir.

### Yapılacaklar (kodda tek kaynak)

1. **Tek kaynak (Single Source of Truth)**
  - Yeni dosya örn. `lib/core/constants/category_constants.dart`: `CategoryDefinition` (id, name, icon, color) + yukarıdaki 8 kategorinin tam listesi. Özel için genel bir fallback ikon/renk (örn. `Icons.category_rounded`).
  - [lib/core/constants/game_constants.dart](lib/core/constants/game_constants.dart): `defaultCategories` bu listeden türetilsin (sadece isim listesi: Fiziksel, Bilgi, Dijital, İtiraf, Zihinsel, Ahlaki, Görsel, Mahrem; Özel oda/oyun mantığında ayrı kalabilir).
2. **Widget’lar**
  - [lib/shared/widgets/game/spin_wheel.dart](lib/shared/widgets/game/spin_wheel.dart) ve [lib/shared/widgets/cards/game_card.dart](lib/shared/widgets/cards/game_card.dart): Kategori → renk/ikon eşlemesini kaldırıp `CategoryConstants` (veya türetilmiş liste) üzerinden okusun.
3. **Admin paneli**
  - [lib/features/admin/presentation/task_editor_screen.dart](lib/features/admin/presentation/task_editor_screen.dart): TÜR dropdown’unu bu tek kaynaktan doldur (8 sabit + isteğe bağlı Özel).
  - [lib/features/admin/presentation/admin_dashboard_screen.dart](lib/features/admin/presentation/admin_dashboard_screen.dart): "Kategoriler sabitlendi. İçerik girişine hazırsınız." bilgi alanı.
4. **Mevcut veri**
  - Firestore `tasks.category` string kalır; yeni kategori isimleri (Fiziksel, Bilgi, Dijital, İtiraf, Zihinsel, Ahlaki, Görsel, Mahrem, Özel) ile uyumlu olacak. Eski isimler (Cesaret, Taklit, Sosyal Medya vb.) varsa migrasyon veya fallback kararı ayrı alınabilir.

---

## Görev 3: 8 Kategori İçin Local Soru Havuzu (800 soru)

**Hedef:** Veritabanında değil, **local** bir dosyada tutulacak şekilde her biri için **100’er soru** (toplam 800), **kolay / orta / zor** seviyelerinde yazılacak.

### Dağılım

- **8 kategori:** Fiziksel, Bilgi, Dijital, İtiraf, Zihinsel, Ahlaki, Görsel, Mahrem.
- **Her kategori:** 100 soru → örn. ~34 kolay, ~33 orta, ~33 zor (veya 33/34/33).
- **Format:** Mevcut seed yapısıyla uyumlu: `category`, `content`, `difficulty` ('easy'/'medium'/'hard'), `type` ('action'), `tags` (örn. ['classic','adult'] veya ['classic','family']).

### Nerede tutulacak

- Tek bir **local** kaynak: örn. `lib/core/data/seeded_tasks_8categories.dart` (veya [lib/features/admin/data/task_seed_migration.dart](lib/features/admin/data/task_seed_migration.dart) yerine geçecek / ek olacak yeni seed dosyası).
- Bu dosya: uygulama içinde sabit liste; Admin "Seed" ile istenirse Firestore’a aktarılabilir veya ileride uygulama doğrudan bu listeyi okuyacak şekilde bağlanabilir.

### İçerik kuralları

- Her soru, ilgili kategorinin tanımına uygun (Fiziksel = bedensel/refleks, Bilgi = baskı altında hafıza, Dijital = telefon/sosyal medya riski, İtiraf = sır/cringe, Zihinsel = kelime/odak oyunları, Ahlaki = etik ikilem, Görsel = çizim/mimik/taklit, Mahrem = cinsellik/tabular).
- Metinler Türkçe, oyun kartında tek cümle/talimat olarak okunabilir uzunlukta (~200 karakter sınırına uygun).
- Zorluk: kolay = hızlı/az riskli, orta = daha cesur/utandırıcı, zor = en sınır zorlayıcı veya teknik açıdan zor.

### Checklist (Görev 3 detay)

- 800 sorunun yazılması (100 × 8 kategori, kolay/orta/zor dağılımlı).
- Local seed dosyasına eklenmesi (mevcut seed formatında).
- (İsteğe bağlı) Seed akışının bu yeni dosyayı kullanacak şekilde güncellenmesi veya admin Seed’in bu listeyi Firestore’a yüklemesi.

**Not:** Bu içerik işi onaylandığında tek seferde veya kategori kategori üretilebilir.

---

## Sıra ve Bağımlılıklar

- **Görev 1** tek başına uygulanabilir; sadece lobby loading state’i.
- **Görev 2** ile birlikte yapıldığında: Önce kategori tek kaynağı ve admin entegrasyonu (Görev 2), ardından veya paralel Lobby loading (Görev 1) yapılabilir. İkisi birbirine teknik bağımlı değil.
- **Görev 3** (800 soru): Kategori isimleri netleştikten (Görev 2) sonra yazılmalı; local seed dosyası Görev 2’deki yeni kategori isimleriyle (Fiziksel, Bilgi, Dijital, İtiraf, Zihinsel, Ahlaki, Görsel, Mahrem) uyumlu olacak.

---

## Kısa Uygulama Checklist

**Görev 1**

- Lobby’de `_isStartingGame` state ekle; "PERDEYİ AÇ" tıklandığında true, `startGameInRoom` bitince/hata da false.
- Lobby body’yi Stack + tam ekran TheaterLoadingScreen("Sahne Hazırlanıyor...") overlay ile sarmala.

**Görev 2**

- `category_constants.dart` (veya eşdeğeri): 8 sabit kategori (Fiziksel, Bilgi, Dijital, İtiraf, Zihinsel, Ahlaki, Görsel, Mahrem) + Özel için CategoryDefinition (id, name, icon, color). GameConstants.defaultCategories buradan türetilsin.
- spin_wheel ve game_card kategori → renk/ikon eşlemesini bu tek kaynaktan okusun.
- Task editor TÜR dropdown: 8 sabit + Özel bu kaynaktan gelsin.
- Admin dashboard: "Kategoriler sabitlendi. İçerik girişine hazırsınız." bilgi alanı ekle.
- (Opsiyonel) Eski task kategori isimleri (Cesaret, Taklit, Sosyal Medya vb.) için migrasyon veya fallback.

**Görev 3 (800 soru)**

- 8 kategori × 100 soru (kolay/orta/zor dağılımlı), mevcut seed formatında.
- Local dosyada: örn. `seeded_tasks_8categories.dart` veya mevcut seed’in yerini alan yeni dosya.
- Seed/Admin akışının bu listeyi kullanacak şekilde (isteğe bağlı) güncellenmesi.

