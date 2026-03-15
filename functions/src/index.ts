import * as functions from "firebase-functions/v1";
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
  .onUpdate(async (change: functions.Change<functions.firestore.DocumentSnapshot>, context: functions.EventContext) => {
    const gameId = context.params.gameId as string;
    const after = change.after.data();
    const status = after?.status;

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

    // Oyuncu skorlarını veritabanından oku (onUpdate tetikleyicisi transaction commit edildikten sonra çalıştığı için skorlar zaten güncel)
    const players: PlayerScore[] = playersSnap.docs.map((doc) => {
      const d = doc.data();
      const raw = d.score;
      const score =
        typeof raw === "number" ? Math.floor(raw) : parseInt(String(raw), 10) || 0;
      
      return { id: doc.id, score };
    });

    // Tur bazlı bitiş kontrolü için lastRoundPlayerId'ye ihtiyacımız var
    const lastRoundPlayerId =
      (after?.lastRoundPlayerId ?? after?.currentPlayerId ?? "") as string;

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
    const currentRound =
      typeof after?.currentRound === "number" ? after.currentRound : 1;
    const isLastActive =
      activeOrder.length > 0 &&
      activeOrder[activeOrder.length - 1] === lastRoundPlayerId;

    let shouldEnd = false;
    if (endType === "rounds") {
      shouldEnd = currentRound >= endValue && isLastActive;
    } else {
      // Veritabanından gelen güncel skorlarla bitiş kontrolü yap
      shouldEnd = players.some((p) => p.score >= endValue);
    }

    if (!shouldEnd) return;

    // Veritabanından gelen güncel skorlarla sıralama yap
    const sorted = [...players].sort((a, b) => b.score - a.score);
    const rewards: Record<string, number> = {};
    sorted.forEach((p, i) => {
      if (p.score <= 0) return;
      rewards[p.id] =
        i < RANK_REWARDS.length ? RANK_REWARDS[i] : DEFAULT_REWARD;
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
