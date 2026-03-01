const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * E28: Oyun bittiğinde sunucu taraflı puan doğrulama ve cüzdana aktarım.
 *
 * Trigger: games/{gameId} dokümanında status 'finished' olduğunda tetiklenir.
 *
 * İş mantığı:
 * 1. Oyunun roomId'sine git, tüm oyuncuların skorlarını oku
 * 2. Her oyuncunun cüzdanına (users/{uid}.walletPoints) kazandığı puanı ekle
 * 3. İşlem sonucunu oyun belgesine yaz (walletTransferred: true)
 */
exports.onGameFinished = functions.firestore
  .document("games/{gameId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Sadece status 'finished' olduğunda tetikle
    if (before.status === "finished" || after.status !== "finished") {
      return null;
    }

    // Zaten transfer edilmişse tekrar yapma
    if (after.walletTransferred === true) {
      return null;
    }

    const gameId = context.params.gameId;
    const roomId = after.roomId;

    if (!roomId) {
      console.error(`Game ${gameId} has no roomId`);
      return null;
    }

    try {
      // Oyuncuları ve skorlarını oku
      const playersSnap = await db
        .collection("rooms")
        .doc(roomId)
        .collection("players")
        .get();

      const batch = db.batch();
      let transferCount = 0;

      for (const playerDoc of playersSnap.docs) {
        const score = playerDoc.data().score || 0;

        if (score > 0) {
          const userRef = db.collection("users").doc(playerDoc.id);
          batch.update(userRef, {
            walletPoints: admin.firestore.FieldValue.increment(score),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          transferCount++;
        }
      }

      // Oyun belgesine transfer durumunu yaz
      batch.update(change.after.ref, {
        walletTransferred: true,
        walletTransferredAt: admin.firestore.FieldValue.serverTimestamp(),
        walletTransferCount: transferCount,
      });

      await batch.commit();

      console.log(
        `Game ${gameId}: Transferred scores for ${transferCount} players`
      );
      return null;
    } catch (error) {
      console.error(`Game ${gameId}: Error transferring scores:`, error);
      return null;
    }
  });

/**
 * Yeni kullanıcı oluştuğunda otomatik profil belgesi oluştur.
 */
exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
  try {
    await db
      .collection("users")
      .doc(user.uid)
      .set({
        displayName: user.displayName || "Oyuncu",
        avatarUrl: user.photoURL || null,
        walletPoints: 0,
        ownedCosmetics: [],
        activeFrame: null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    console.log(`Created profile for user ${user.uid}`);
  } catch (error) {
    console.error(`Error creating profile for user ${user.uid}:`, error);
  }
});
