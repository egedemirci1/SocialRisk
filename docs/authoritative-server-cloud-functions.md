# Otoriter Sunucu (Authoritative Server) – Cloud Functions Mimarisi

Bu dokümanda: endüstri standardı **Authoritative Server** yaklaşımı, Firebase ekosisteminde **Cloud Functions** ile nasıl uygulanacağı ve Social Risk için **TypeScript fonksiyon taslağı** yer alıyor.

---

## 1. Neden Otoriter Sunucu?

Çok oyunculu oyunlarda altın kural: **istemciye (oyuncunun cihazına) asla güvenilmez.** Cihazın şarjı bitebilir, host'un interneti kopabilir veya araya girilip hile yapılabilir. Oyunun kaderini belirleyen kritik işlemler **her zaman güvenli bir sunucuda** yapılmalıdır.

| Yaklaşım | Karar veren | Ödül yazan | Risk |
|----------|-------------|------------|------|
| İstemci (mevcut) | Host/client (applyScore, shouldEndGame) | İstemci claim veya sunucu batch | Bağlantı kopunca tutarsızlık, izin hataları, race |
| **Otoriter sunucu** | **Cloud Function** | **Cloud Function (Admin SDK)** | Tek doğru kaynak, atomik, kurallara takılmaz |

**Faydalar:**

- **Tek doğru kaynak (Single Source of Truth):** Oyunun bittiğine ve kimin ne ödül alacağına cihazlar değil, izole sunucu karar verir.
- **Bağlantı kopmalarına direnç:** Host tam oyun biterken bağlantıyı kesse bile, son hamle Firestore'a ulaştığı an fonksiyon tetiklenir; oyunu bitirir ve sonuçları yayınlar.
- **Atomik işlemler, sıfır izin hatası:** Admin SDK ile Security Rules bypass; batch write ile tüm ödüller tek seferde. Double claim yok.

---

## 2. Mimari Özet

```
┌─────────────────────────────────────────────────────────────────┐
│  İstemci (Flutter) – "aptal arayüz"                               │
│  • Sadece niyeti yazar: oy, hamle, tur sonucu (skor artışı).      │
│  • Bitiş kararı vermez; sadece status = 'results' yazar.          │
└──────────────────────────────┬──────────────────────────────────┘
                               │ Firestore write (games/{gameId})
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  Firestore: games/{gameId} güncellendi                            │
└──────────────────────────────┬──────────────────────────────────┘
                               │ onDocumentUpdated
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  Cloud Function (Node.js / TypeScript)                            │
│  1. Dokümana bak: status === 'results'?                           │
│  2. room + players oku; shouldEnd(game, room, players) hesapla.    │
│  3. Eğer bitmeli: tek batch içinde:                              │
│     • game: status = 'finished', rewards = { uid: puan }          │
│     • users/{uid}: walletPoints += reward (Admin SDK)             │
└─────────────────────────────────────────────────────────────────┘
```

**İstemci tarafında yapılacak değişiklik:**

- `applyScore` / `setRoundResult` artık **hiçbir zaman** `shouldEndGame: true` göndermez.
- Her zaman sadece tur sonucunu yazar: skor artışı, `status: 'results'`, `lastRound*`. Bitiş kararı **sadece** Cloud Function’da.

---

## 3. Social Risk’e Özel Mantık (Sunucuda)

Bitiş koşulları (mevcut `GameEndUtils.shouldEndAfterRound` ile uyumlu):

- **Tur sayısı (rounds):** `room.endConditionType === 'rounds'` ve `game.currentRound >= room.endConditionValue` ve bu turda son oyuncu oynadı (`lastRoundPlayerId` sıradaki son aktif oyuncu).
- **Skor hedefi (score):** Herhangi bir oyuncunun skoru `>= room.endConditionValue`.

Ödül (mevcut sabitler): 1. 200, 2. 100, 3. 50, sonrakiler 20.

---

## 4. TypeScript Cloud Function Taslağı

Aşağıdaki kod **Firestore tetikleyicisi** ile çalışır: `games/{gameId}` güncellendiğinde tetiklenir. Sadece `status === 'results'` iken “oyun bitmeli mi?” diye bakar; bitmeli ise tek batch’te `finished` + ödül dağıtımı yapar.

**Gereksinimler:** Firebase Admin SDK, Firestore tetikleyicisi. Projede `functions` klasörü ve `firebase-functions` + `firebase-admin` kurulu olmalı.

```typescript
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

if (!admin.apps.length) admin.initializeApp();

const db = admin.firestore();

const RANK_REWARDS = [200, 100, 50];
const DEFAULT_REWARD = 20;

interface RoomDoc {
  endConditionType?: string;
  endConditionValue?: number;
}

interface PlayerScore {
  id: string;
  score: number;
}

/**
 * Oyun dokümanı güncellendiğinde tetiklenir.
 * status === 'results' ve bitiş koşulu sağlanıyorsa:
 * - status = 'finished', rewards map'ini game'e yazar
 * - Her oyuncunun users/{userId} dokümanına walletPoints ekler (Admin SDK ile izin sorunu yok)
 */
export const onGameUpdated = functions.firestore
  .document("games/{gameId}")
  .onUpdate(async (change, context) => {
    const gameId = context.params.gameId;
    const after = change.after.data();
    const status = after?.status;

    // Sadece tur sonucu yazıldığında (client status = 'results' yazdı) kontrol et
    if (status !== "results") return;

    const gameRef = change.after.ref;
    const roomId = after?.roomId as string | undefined;
    if (!roomId) return;

    const roomSnap = await db.collection("rooms").doc(roomId).get();
    if (!roomSnap.exists) return;
    const room = roomSnap.data() as RoomDoc;
    const endType = room?.endConditionType ?? "score";
    const endValue = room?.endConditionValue ?? 5000;

    const playersSnap = await db
      .collection("rooms")
      .doc(roomId)
      .collection("players")
      .get();

    const players: PlayerScore[] = playersSnap.docs.map((doc) => {
      const d = doc.data();
      const raw = d.score;
      const score =
        typeof raw === "number" ? Math.floor(raw) : parseInt(raw, 10) || 0;
      return { id: doc.id, score };
    });

    const turnOrder: string[] = Array.isArray(after?.turnOrder)
      ? after.turnOrder
      : [];
    const categoryPickOrder: string[] = Array.isArray(after?.categoryPickOrder)
      ? after.categoryPickOrder
      : [];
    const mode = after?.mode === "economy" ? "economy" : "classic";
    const orderSource =
      mode === "economy" && categoryPickOrder.length > 0
        ? categoryPickOrder
        : turnOrder;
    const activeOrder = orderSource.filter((id) =>
      players.some((p) => p.id === id)
    );
    const currentRound = typeof after?.currentRound === "number" ? after.currentRound : 1;
    const lastRoundPlayerId =
      after?.lastRoundPlayerId ?? after?.currentPlayerId ?? "";
    const isLastActive =
      activeOrder.length > 0 && activeOrder[activeOrder.length - 1] === lastRoundPlayerId;

    let shouldEnd = false;
    if (endType === "rounds") {
      shouldEnd = currentRound >= endValue && isLastActive;
    } else {
      shouldEnd = players.some((p) => p.score >= endValue);
    }

    if (!shouldEnd) return;

    const sorted = [...players].sort((a, b) => b.score - a.score);
    const rewards: Record<string, number> = {};
    sorted.forEach((p, i) => {
      if (p.score <= 0) return;
      rewards[p.id] = i < RANK_REWARDS.length ? RANK_REWARDS[i] : DEFAULT_REWARD;
    });

    const batch = db.batch();

    batch.update(gameRef, {
      status: "finished",
      rewards,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    for (const [userId, points] of Object.entries(rewards)) {
      if (points <= 0) continue;
      const userRef = db.collection("users").doc(userId);
      batch.set(
        userRef,
        {
          walletPoints: admin.firestore.FieldValue.increment(points),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    await batch.commit();
    functions.logger.info(`Game ${gameId} finished and rewards distributed.`);
  });
```

---

## 5. İstemci Tarafında Yapılacaklar

1. **setRoundResult her zaman `shouldEndGame: false`**
   - `GameController.applyScore` içinde `shouldEndGame` hesaplanmasını kaldır; her zaman `setRoundResult(..., shouldEndGame: false)` çağır.
   - Böylece istemci sadece `status: 'results'` ve tur skorunu yazar; bitiş kararı tamamen Cloud Function’da kalır.

2. **endGame / claim**
   - Bu mimaride sunucu ödülleri doğrudan `users/{userId}`’e yazdığı için **claim akışına gerek kalmaz** (istersen yine de game-over’da gösterim için `game.rewards` okuyabilirsin).
   - Round-result’ta “PARTİ BİTTİ” için çağrılan `endGame`: Artık sadece `status: 'finished'` yazmak için kullanılabilir veya kaldırılabilir; ödül dağıtımı zaten fonksiyonda yapıldığı için `endGame`’in users’a yazan kısmı kapatılmalı veya silinmeli.

3. **nextTurn ile tur limiti**
   - Şu an client’ta `nextTurn` tur limitine gelince `finished` + `rewards` (game’e) yazıyor; users’a yazmıyor, claim ile alınıyor. İki seçenek:
     - **A)** Olduğu gibi bırak: Tur limiti bitişi client’ta kalır, ödüller game’de, claim ile dağıtılır.
     - **B)** nextTurn da sadece `status: 'playing'` ve sıra güncellemesi yapsın; “tur limiti doldu” kararını da bir Cloud Function’a bırak (ör. aynı `onGameUpdated` içinde `status === 'playing'` ve yeni round’da `currentRound >= endValue` kontrolü). Bu biraz daha fazla mantık gerektirir.

---

## 6. Özet

| Konu | Mevcut (client-authoritative) | Cloud Functions (authoritative server) |
|------|-------------------------------|----------------------------------------|
| Bitiş kararı | İstemci (applyScore) | Sunucu (onGameUpdated) |
| Ödül yazma | game.rewards + claim veya batch (izin riski) | Admin SDK batch (tek seferde, güvenli) |
| Tek kaynak | Hayır | Evet |
| Bağlantı kopsa | Tutarsızlık riski | Son yazı Firestore’a ulaştıysa sunucu halleder |

Bu yapı, “skor ekranının tek bir kaynaktan (sunucu) gelmesi” ve “ödüllerin izin hatası olmadan, atomik dağıtılması” hedeflerine endüstri standardına uygun şekilde ulaşır.
