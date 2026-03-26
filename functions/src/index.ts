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

// Her 6 saatte bir boş odaları temizle
export const cleanupEmptyRooms = functions.pubsub
  .schedule('every 6 hours')
  .onRun(async (context) => {
    console.log('Starting cleanup of empty rooms...');
    
    const roomsSnapshot = await db.collection('rooms').get();
    const batch = db.batch();
    let deletedCount = 0;
    
    for (const doc of roomsSnapshot.docs) {
      const room = doc.data();
      const players = room.players || {};
      const playerCount = Object.keys(players).length;
      
      // Boş oda veya 1 saatten eski ve 1 oyunculu odaları sil
      const roomAge = Date.now() - (room.createdAt?.toMillis?.() || 0);
      const oneHour = 60 * 60 * 1000;
      
      if (playerCount === 0 || (playerCount === 1 && roomAge > oneHour)) {
        batch.delete(doc.ref);
        deletedCount++;
        
        // İlgili oyunu da sil
        if (room.gameId) {
          batch.delete(db.collection('games').doc(room.gameId));
        }
      }
    }
    
    if (deletedCount > 0) {
      await batch.commit();
      console.log(`Deleted ${deletedCount} empty/abandoned rooms`);
    } else {
      console.log('No rooms to clean up');
    }
    
    return null;
  });

// Her gün eski oyunları temizle (24 saatten eski bitmiş oyunlar)
export const cleanupOldGames = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    console.log('Starting cleanup of old games...');
    
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    
    const gamesSnapshot = await db.collection('games')
      .where('status', '==', 'finished')
      .where('updatedAt', '<', oneDayAgo)
      .get();
    
    const batch = db.batch();
    let deletedCount = 0;
    
    for (const doc of gamesSnapshot.docs) {
      batch.delete(doc.ref);
      deletedCount++;
    }
    
    if (deletedCount > 0) {
      await batch.commit();
      console.log(`Deleted ${deletedCount} old finished games`);
    } else {
      console.log('No old games to clean up');
    }
    
    return null;
  });

// Inactive user'ları temizle (90 gündür giriş yapmayanlar)
export const cleanupInactiveUsers = functions.pubsub
  .schedule('0 0 1 * *') // Her ayın 1'inde saat 00:00'da
  .timeZone('America/New_York')
  .onRun(async (context) => {
    console.log('Starting cleanup of inactive users...');
    
    const ninetyDaysAgo = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000);
    
    const usersSnapshot = await db.collection('users')
      .where('lastSeenAt', '<', ninetyDaysAgo)
      .get();
    
    const batch = db.batch();
    let deletedCount = 0;
    
    for (const doc of usersSnapshot.docs) {
      const user = doc.data();
      
      // Sadece 0 puanlı ve hiç kozmetiği olmayan user'ları sil
      if (user.score === 0 && (!user.ownedCosmetics || user.ownedCosmetics.length === 0)) {
        batch.delete(doc.ref);
        deletedCount++;
      }
    }
    
    if (deletedCount > 0) {
      await batch.commit();
      console.log(`Deleted ${deletedCount} inactive users`);
    } else {
      console.log('No inactive users to clean up');
    }
    
    return null;
  });

interface VoteDoc {
  value?: string;
  timedOut?: boolean;
}

interface CosmeticDoc {
  price?: number;
  type?: string;
  categoryName?: string;
  name?: string;
}

export const buyCosmetic = functions.https.onCall(async (data, context) => {
  console.log('=== BUY COSMETIC DEBUG ===');
  console.log('buyCosmetic called with data:', data);
  console.log('auth context:', context.auth);
  
  if (!context.auth) {
    console.log('ERROR: No auth context');
    throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
  }

  const cosmeticId = typeof data?.cosmeticId === "string" ? data.cosmeticId.trim() : "";
  console.log('cosmeticId:', cosmeticId);
  
  if (!cosmeticId) {
    console.log('ERROR: No cosmeticId');
    throw new functions.https.HttpsError("invalid-argument", "cosmeticId is required.");
  }

  const uid = context.auth.uid;
  console.log('user uid:', uid);
  
  // Önce users collection'da user var mı kontrol et
  const userDoc = await db.collection('users').doc(uid).get();
  console.log('user exists:', userDoc.exists);
  
  if (!userDoc.exists) {
    console.log('ERROR: User not found in users collection for uid:', uid);
    // Tüm users'ları listele
    const allUsers = await db.collection('users').limit(5).get();
    console.log('Sample users in collection:');
    allUsers.docs.forEach(doc => {
      console.log(`- ${doc.id}: ${doc.data()?.displayName}`);
    });
    throw new functions.https.HttpsError("not-found", "User not found.");
  }
  
  console.log('User found, data:', userDoc.data());
  const userRef = db.collection("users").doc(uid);
  const cosmeticRef = db.collection("cosmetics").doc(cosmeticId);

  return db.runTransaction(async (transaction) => {
    const [userSnap, cosmeticSnap] = await Promise.all([
      transaction.get(userRef),
      transaction.get(cosmeticRef),
    ]);

    if (!userSnap.exists) {
      console.log('ERROR: User not found for uid:', uid);
      throw new functions.https.HttpsError("not-found", "User not found.");
    }
    console.log('User found, data:', userSnap.data());
    if (!cosmeticSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Cosmetic not found.");
    }

    const userData = userSnap.data() ?? {};
    const cosmeticData = cosmeticSnap.data() as CosmeticDoc;
    const ownedCosmetics = Array.isArray(userData.ownedCosmetics)
      ? userData.ownedCosmetics as string[]
      : [];

    if (ownedCosmetics.includes(cosmeticId)) {
      throw new functions.https.HttpsError("already-exists", "Cosmetic already owned.");
    }

    const currentPoints = typeof userData.walletPoints === "number" ? userData.walletPoints : 0;
    const price = typeof cosmeticData.price === "number" ? cosmeticData.price : 0;
    if (currentPoints < price) {
      throw new functions.https.HttpsError("failed-precondition", "Insufficient balance.");
    }

    const updates: Record<string, unknown> = {
      walletPoints: currentPoints - price,
      ownedCosmetics: admin.firestore.FieldValue.arrayUnion(cosmeticId),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (cosmeticData.type === "category") {
      const categoryName = cosmeticData.categoryName ?? cosmeticData.name;
      if (categoryName) {
        updates.ownedCategories = admin.firestore.FieldValue.arrayUnion(categoryName);
      }
    }

    transaction.update(userRef, updates);

    return {
      cosmeticId,
      walletPoints: currentPoints - price,
    };
  });
});

export const distributeRewards = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
  }

  const playerRewards = data?.playerRewards as Record<string, unknown>;
  if (!playerRewards || typeof playerRewards !== "object") {
    throw new functions.https.HttpsError("invalid-argument", "playerRewards map is required.");
  }

  const batch = db.batch();
  let totalDistributed = 0;

  for (const [uid, points] of Object.entries(playerRewards)) {
    const pointsInt = typeof points === "number" ? points : 0;
    if (pointsInt === 0) continue;

    const userRef = db.collection("users").doc(uid);
    batch.update(userRef, {
      walletPoints: admin.firestore.FieldValue.increment(pointsInt),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    totalDistributed += pointsInt;
  }

  await batch.commit();

  return {
    totalDistributed,
    playerCount: Object.keys(playerRewards).length,
  };
});

export const finalizeVotingRound = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
  }

  const gameId = typeof data?.gameId === "string" ? data.gameId.trim() : "";
  if (!gameId) {
    throw new functions.https.HttpsError("invalid-argument", "gameId is required.");
  }

  const gameRef = db.collection("games").doc(gameId);

  const result = await db.runTransaction(async (transaction) => {
    const gameSnap = await transaction.get(gameRef);
    if (!gameSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Game not found.");
    }

    const game = gameSnap.data() ?? {};
    const roomId = typeof game.roomId === "string" ? game.roomId : "";
    if (!roomId) {
      throw new functions.https.HttpsError("failed-precondition", "Game has no roomId.");
    }

    const roomRef = db.collection("rooms").doc(roomId);
    const roomSnap = await transaction.get(roomRef);
    if (!roomSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Room not found.");
    }

    const room = roomSnap.data() ?? {};
    if (room.hostId !== context.auth?.uid) {
      throw new functions.https.HttpsError("permission-denied", "Only host can finalize voting.");
    }

    if (game.status !== "voting") {
      throw new functions.https.HttpsError("failed-precondition", "Game is not in voting state.");
    }

    const currentPlayerId = typeof game.currentPlayerId === "string" ? game.currentPlayerId : "";
    if (!currentPlayerId) {
      throw new functions.https.HttpsError("failed-precondition", "Game has no current player.");
    }

    const currentTask = (game.currentTask ?? {}) as Record<string, unknown>;
    const taskMultiplier = typeof currentTask.multiplier === "number" ? currentTask.multiplier : 1;
    const selectedCategory = typeof game.selectedCategory === "string" ? game.selectedCategory : null;
    const hotCategory = typeof game.hotCategory === "string" ? game.hotCategory : null;
    const marketValues = (game.categoryMarketValues ?? {}) as Record<string, number>;
    const votesQuery = gameRef.collection("votes");
    const votesSnap = await transaction.get(votesQuery);

    let likes = 0;
    let neutrals = 0;
    let dislikes = 0;
    let penalizedCount = 0;

    for (const voteDoc of votesSnap.docs) {
      const vote = voteDoc.data() as VoteDoc;
      if (vote.timedOut === true) {
        penalizedCount += 1;
        transaction.update(
          roomRef.collection("players").doc(voteDoc.id),
          { score: admin.firestore.FieldValue.increment(-10) }
        );
      } else if (vote.value === "like") {
        likes += 1;
      } else if (vote.value === "dislike") {
        dislikes += 1;
      } else {
        neutrals += 1;
      }

      transaction.delete(voteDoc.ref);
    }

    let baseScore = 10;
    if (game.mode === "economy" && selectedCategory) {
      if (selectedCategory === hotCategory) {
        baseScore = 12;
      } else {
        const selectedValue = marketValues[selectedCategory];
        baseScore = typeof selectedValue === "number" ? selectedValue : 10;
      }
    }

    const fullRoundScore = baseScore * taskMultiplier;
    const mood = likes >= neutrals && likes >= dislikes
      ? "like"
      : dislikes >= likes && dislikes >= neutrals
        ? "dislike"
        : "neutral";
    const totalScore = mood === "like"
      ? fullRoundScore
      : mood === "neutral"
        ? Math.floor(fullRoundScore / 2)
        : 0;

    transaction.update(
      roomRef.collection("players").doc(currentPlayerId),
      { score: admin.firestore.FieldValue.increment(totalScore) }
    );

    const updates: Record<string, unknown> = {
      status: "results",
      lastRoundScore: totalScore,
      lastRoundAudienceScore: baseScore,
      lastRoundMultiplier: taskMultiplier,
      lastRoundPlayerId: currentPlayerId,
      lastRoundMood: mood,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const categoryPickOrder = Array.isArray(game.categoryPickOrder)
      ? (game.categoryPickOrder as string[])
      : [];

    if (categoryPickOrder.length > 0 && selectedCategory) {
      const nextMarketValues = { ...marketValues };
      const currentValue = typeof nextMarketValues[selectedCategory] === "number"
        ? nextMarketValues[selectedCategory]
        : 10;
      nextMarketValues[selectedCategory] = Math.max(0, Math.min(10, currentValue - 1));
      updates.categoryMarketValues = nextMarketValues;

      const currentPickIndex = typeof game.currentPickIndex === "number" ? game.currentPickIndex : 0;
      const nextPickIndex = currentPickIndex + 1;
      if (nextPickIndex >= categoryPickOrder.length) {
        updates.currentPickIndex = 0;
        updates.currentRound = (typeof game.currentRound === "number" ? game.currentRound : 1) + 1;
        updates.currentPlayerId = categoryPickOrder[0];

        const resetMarketValues = { ...(updates.categoryMarketValues as Record<string, number>) };
        for (const key of Object.keys(resetMarketValues)) {
          if ((resetMarketValues[key] ?? 0) === 0) {
            resetMarketValues[key] = 10;
          }
        }
        const atTen = Object.keys(resetMarketValues).filter((key) => (resetMarketValues[key] ?? 0) === 10);
        updates.categoryMarketValues = resetMarketValues;
        updates.hotCategory = atTen.length > 0
          ? atTen[Math.floor(Math.random() * atTen.length)]
          : null;
      } else {
        updates.currentPickIndex = nextPickIndex;
        updates.currentPlayerId = categoryPickOrder[nextPickIndex];
      }
    }

    transaction.update(gameRef, updates);

    return {
      totalScore,
      audienceScore: baseScore,
      mood,
      penalizedCount,
    };
  });

  return result;
});

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
