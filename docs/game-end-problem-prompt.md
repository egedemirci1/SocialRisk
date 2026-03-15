# Oyun Bitişi – Problem Promptu (Başka Agent’a Verilecek)

Aşağıdaki metni olduğu gibi kopyalayıp başka bir AI asistanına ver. Alternatif çözüm önerebilir.

---

## Kopyalanacak prompt

```
Sosyal Risk adlı çok oyunculu bir parti oyunu var. Flutter (web/mobile), state için Riverpod, veri için Firestore kullanılıyor. Oda sahibi (host) ve oyuncular (client) aynı oyunda; oyun durumu Firestore’da games/{gameId} dokümanında status ile tutuluyor (playing, performing, voting, results, finished).

Problem şu:

Oyun bittiğinde sonuç/skor ekranı (game-over, final sıralama) tek bir kaynaktan gelmiyordu. Yani “oyun bitti ve skorlar şu” bilgisi tek bir hesap tek bir yazıyla belirlenmiyordu. Bunun yerine:
- Hem host hem client farklı yerlerde karar verebiliyor veya yazabiliyordu,
- Ya da sonuç ekranına geçiş / skorların kaydedilmesi birden fazla cihazdan veya birden fazla yazıdan tetikleniyordu.

Bu yüzden bazen bir oyuncu sonuç ekranına hiç geçmiyordu, bazen “sonuçlar kaydedilirken hata” / “Missing or insufficient permissions” gibi hatalar çıkıyordu, ya da ekranlar tutarsız davranıyordu.

İstenen: Oyun bitişinde sonuç/skor ekranının tek bir kaynaktan (tek bir karar, mümkünse tek bir yazı) gelmesi; tüm oyuncuların aynı “oyun bitti, skorlar bu” durumunu görmesi ve gerekirse ödüllerin güvenli şekilde dağıtılması.

Şu anki çözüm özetle:
- Bitiş kararı tek noktada veriliyor (applyScore içinde shouldEndAfterRound hesaplanıp setRoundResult(..., shouldEndGame: true/false) tek çağrıda yazıyor).
- Son turda status doğrudan finished yazılıyor; ödüller game dokümanında rewards map’i olarak tutuluyor, users koleksiyonuna transaction içinde yazılmıyor (izin hatası önlendi).
- Her oyuncu game-over ekranına gelince kendi ödülünü claimGameReward ile sadece kendi users/{userId} dokümanına yazarak alıyor.

Bu yapıyı değiştirmeden veya farklı bir mimari önererek aynı hedefe (oyun bitişi ve skor ekranının tek kaynaktan gelmesi, tutarlı ve hatasız davranması) ulaşacak başka bir çözüm var mı? Varsa öner, yoksa mevcut çözümün risklerini ve iyileştirme önerilerini yaz.
```

---

Bu dosyadaki yukarıdaki kutu içi metni kopyalayıp başka bir sohbete yapıştırabilirsin.
