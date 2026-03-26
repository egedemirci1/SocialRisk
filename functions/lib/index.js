"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onGameUpdated = exports.finalizeVotingRound = exports.distributeRewards = exports.buyCosmetic = exports.cleanupInactiveUsers = exports.cleanupOldGames = exports.cleanupEmptyRooms = void 0;
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
if (!admin.apps.length)
    admin.initializeApp();
const db = admin.firestore();
const RANK_REWARDS = [200, 100, 50];
const DEFAULT_REWARD = 20;
const DEFAULT_ECONOMY_BASE_VALUE = 10;
const ECONOMY_PENALTY_AMOUNT = 2;
const HOT_CATEGORY_BONUS = DEFAULT_ECONOMY_BASE_VALUE + ECONOMY_PENALTY_AMOUNT;
const ECONOMY_PENALTY_VALUE = DEFAULT_ECONOMY_BASE_VALUE - ECONOMY_PENALTY_AMOUNT;
function economyResolvedStoredBaseValue(category, storedValues) {
    if (Object.keys(storedValues).length <= 2)
        return DEFAULT_ECONOMY_BASE_VALUE;
    const value = storedValues[category];
    return typeof value === "number" ? value : DEFAULT_ECONOMY_BASE_VALUE;
}
function economyPenaltyCategoryForNextTurn(categoryCount, selectedCategory, currentHotCategory) {
    if (categoryCount <= 2 || !selectedCategory)
        return null;
    if (selectedCategory === currentHotCategory)
        return null;
    return selectedCategory;
}
function pickEconomyHotCategory(categories, excludedCategories = []) {
    if (categories.length <= 2)
        return null;
    const excluded = new Set(excludedCategories);
    const candidates = categories.filter((category) => !excluded.has(category));
    if (candidates.length === 0)
        return null;
    return candidates[Math.floor(Math.random() * candidates.length)];
}
function buildEconomyTurnValues(categories, hotCategory, penalizedCategory) {
    return Object.fromEntries(categories.map((category) => {
        let value = DEFAULT_ECONOMY_BASE_VALUE;
        if (categories.length > 2) {
            if (hotCategory === category) {
                value = HOT_CATEGORY_BONUS;
            }
            else if (penalizedCategory === category) {
                value = ECONOMY_PENALTY_VALUE;
            }
        }
        return [category, value];
    }));
}
// Her 6 saatte bir boş odaları temizle
exports.cleanupEmptyRooms = functions.pubsub
    .schedule('every 6 hours')
    .onRun(async (context) => {
    var _a, _b;
    console.log('Starting cleanup of empty rooms...');
    const roomsSnapshot = await db.collection('rooms').get();
    const batch = db.batch();
    let deletedCount = 0;
    for (const doc of roomsSnapshot.docs) {
        const room = doc.data();
        const players = room.players || {};
        const playerCount = Object.keys(players).length;
        // Boş oda veya 1 saatten eski ve 1 oyunculu odaları sil
        const roomAge = Date.now() - (((_b = (_a = room.createdAt) === null || _a === void 0 ? void 0 : _a.toMillis) === null || _b === void 0 ? void 0 : _b.call(_a)) || 0);
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
    }
    else {
        console.log('No rooms to clean up');
    }
    return null;
});
// Her gün eski oyunları temizle (24 saatten eski bitmiş oyunlar)
exports.cleanupOldGames = functions.pubsub
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
    }
    else {
        console.log('No old games to clean up');
    }
    return null;
});
// Inactive user'ları temizle (90 gündür giriş yapmayanlar)
exports.cleanupInactiveUsers = functions.pubsub
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
    }
    else {
        console.log('No inactive users to clean up');
    }
    return null;
});
exports.buyCosmetic = functions.https.onCall(async (data, context) => {
    console.log('=== BUY COSMETIC DEBUG ===');
    console.log('buyCosmetic called with data:', data);
    console.log('auth context:', context.auth);
    if (!context.auth) {
        console.log('ERROR: No auth context');
        throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }
    const cosmeticId = typeof (data === null || data === void 0 ? void 0 : data.cosmeticId) === "string" ? data.cosmeticId.trim() : "";
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
            var _a;
            console.log(`- ${doc.id}: ${(_a = doc.data()) === null || _a === void 0 ? void 0 : _a.displayName}`);
        });
        throw new functions.https.HttpsError("not-found", "User not found.");
    }
    console.log('User found, data:', userDoc.data());
    const userRef = db.collection("users").doc(uid);
    const cosmeticRef = db.collection("cosmetics").doc(cosmeticId);
    return db.runTransaction(async (transaction) => {
        var _a, _b;
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
        const userData = (_a = userSnap.data()) !== null && _a !== void 0 ? _a : {};
        const cosmeticData = cosmeticSnap.data();
        const ownedCosmetics = Array.isArray(userData.ownedCosmetics)
            ? userData.ownedCosmetics
            : [];
        if (ownedCosmetics.includes(cosmeticId)) {
            throw new functions.https.HttpsError("already-exists", "Cosmetic already owned.");
        }
        const currentPoints = typeof userData.walletPoints === "number" ? userData.walletPoints : 0;
        const price = typeof cosmeticData.price === "number" ? cosmeticData.price : 0;
        if (currentPoints < price) {
            throw new functions.https.HttpsError("failed-precondition", "Insufficient balance.");
        }
        const updates = {
            walletPoints: currentPoints - price,
            ownedCosmetics: admin.firestore.FieldValue.arrayUnion(cosmeticId),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        if (cosmeticData.type === "category") {
            const categoryName = (_b = cosmeticData.categoryName) !== null && _b !== void 0 ? _b : cosmeticData.name;
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
exports.distributeRewards = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }
    const playerRewards = data === null || data === void 0 ? void 0 : data.playerRewards;
    if (!playerRewards || typeof playerRewards !== "object") {
        throw new functions.https.HttpsError("invalid-argument", "playerRewards map is required.");
    }
    const batch = db.batch();
    let totalDistributed = 0;
    for (const [uid, points] of Object.entries(playerRewards)) {
        const pointsInt = typeof points === "number" ? points : 0;
        if (pointsInt === 0)
            continue;
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
exports.finalizeVotingRound = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }
    const gameId = typeof (data === null || data === void 0 ? void 0 : data.gameId) === "string" ? data.gameId.trim() : "";
    if (!gameId) {
        throw new functions.https.HttpsError("invalid-argument", "gameId is required.");
    }
    const gameRef = db.collection("games").doc(gameId);
    const result = await db.runTransaction(async (transaction) => {
        var _a, _b, _c, _d, _e;
        const gameSnap = await transaction.get(gameRef);
        if (!gameSnap.exists) {
            throw new functions.https.HttpsError("not-found", "Game not found.");
        }
        const game = (_a = gameSnap.data()) !== null && _a !== void 0 ? _a : {};
        const roomId = typeof game.roomId === "string" ? game.roomId : "";
        if (!roomId) {
            throw new functions.https.HttpsError("failed-precondition", "Game has no roomId.");
        }
        const roomRef = db.collection("rooms").doc(roomId);
        const roomSnap = await transaction.get(roomRef);
        if (!roomSnap.exists) {
            throw new functions.https.HttpsError("not-found", "Room not found.");
        }
        const room = (_b = roomSnap.data()) !== null && _b !== void 0 ? _b : {};
        if (room.hostId !== ((_c = context.auth) === null || _c === void 0 ? void 0 : _c.uid)) {
            throw new functions.https.HttpsError("permission-denied", "Only host can finalize voting.");
        }
        if (game.status !== "voting") {
            throw new functions.https.HttpsError("failed-precondition", "Game is not in voting state.");
        }
        const currentPlayerId = typeof game.currentPlayerId === "string" ? game.currentPlayerId : "";
        if (!currentPlayerId) {
            throw new functions.https.HttpsError("failed-precondition", "Game has no current player.");
        }
        const currentTask = ((_d = game.currentTask) !== null && _d !== void 0 ? _d : {});
        const taskMultiplier = typeof currentTask.multiplier === "number" ? currentTask.multiplier : 1;
        const selectedCategory = typeof game.selectedCategory === "string" ? game.selectedCategory : null;
        const hotCategory = typeof game.hotCategory === "string" ? game.hotCategory : null;
        const marketValues = ((_e = game.categoryMarketValues) !== null && _e !== void 0 ? _e : {});
        const categoryNames = Object.keys(marketValues);
        const votesQuery = gameRef.collection("votes");
        const votesSnap = await transaction.get(votesQuery);
        let likes = 0;
        let neutrals = 0;
        let dislikes = 0;
        let penalizedCount = 0;
        for (const voteDoc of votesSnap.docs) {
            const vote = voteDoc.data();
            if (vote.timedOut === true) {
                penalizedCount += 1;
                transaction.update(roomRef.collection("players").doc(voteDoc.id), { score: admin.firestore.FieldValue.increment(-10) });
            }
            else if (vote.value === "like") {
                likes += 1;
            }
            else if (vote.value === "dislike") {
                dislikes += 1;
            }
            else {
                neutrals += 1;
            }
            transaction.delete(voteDoc.ref);
        }
        let baseScore = 10;
        if (game.mode === "economy" && selectedCategory) {
            baseScore = economyResolvedStoredBaseValue(selectedCategory, marketValues);
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
        transaction.update(roomRef.collection("players").doc(currentPlayerId), { score: admin.firestore.FieldValue.increment(totalScore) });
        const updates = {
            status: "results",
            lastRoundScore: totalScore,
            lastRoundAudienceScore: baseScore,
            lastRoundMultiplier: taskMultiplier,
            lastRoundPlayerId: currentPlayerId,
            lastRoundMood: mood,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        const categoryPickOrder = Array.isArray(game.categoryPickOrder)
            ? game.categoryPickOrder
            : [];
        if (categoryPickOrder.length > 0) {
            const currentPickIndex = typeof game.currentPickIndex === "number" ? game.currentPickIndex : 0;
            const nextPickIndex = currentPickIndex + 1;
            const penalizedCategory = economyPenaltyCategoryForNextTurn(categoryNames.length, selectedCategory, hotCategory);
            const nextHotCategory = pickEconomyHotCategory(categoryNames, penalizedCategory ? [penalizedCategory] : []);
            const nextTurnMarketValues = buildEconomyTurnValues(categoryNames, nextHotCategory, penalizedCategory);
            if (nextPickIndex >= categoryPickOrder.length) {
                updates.currentPickIndex = 0;
                updates.currentRound = (typeof game.currentRound === "number" ? game.currentRound : 1) + 1;
                updates.currentPlayerId = categoryPickOrder[0];
            }
            else {
                updates.currentPickIndex = nextPickIndex;
                updates.currentPlayerId = categoryPickOrder[nextPickIndex];
            }
            updates.categoryMarketValues = nextTurnMarketValues;
            updates.hotCategory = nextHotCategory;
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
exports.onGameUpdated = functions.firestore
    .document("games/{gameId}")
    .onUpdate(async (change, context) => {
    var _a, _b, _c, _d;
    const gameId = context.params.gameId;
    const after = change.after.data();
    const status = after === null || after === void 0 ? void 0 : after.status;
    if (status !== "results")
        return;
    const gameRef = change.after.ref;
    const roomId = after === null || after === void 0 ? void 0 : after.roomId;
    if (!roomId)
        return;
    const roomSnap = await db.collection("rooms").doc(roomId).get();
    if (!roomSnap.exists)
        return;
    const room = roomSnap.data();
    const endType = (_a = room === null || room === void 0 ? void 0 : room.endConditionType) !== null && _a !== void 0 ? _a : "score";
    const endValue = (_b = room === null || room === void 0 ? void 0 : room.endConditionValue) !== null && _b !== void 0 ? _b : 5000;
    const playersSnap = await db
        .collection("rooms")
        .doc(roomId)
        .collection("players")
        .get();
    // Oyuncu skorlarını veritabanından oku (onUpdate tetikleyicisi transaction commit edildikten sonra çalıştığı için skorlar zaten güncel)
    const players = playersSnap.docs.map((doc) => {
        const d = doc.data();
        const raw = d.score;
        const score = typeof raw === "number" ? Math.floor(raw) : parseInt(String(raw), 10) || 0;
        return { id: doc.id, score };
    });
    // Tur bazlı bitiş kontrolü için lastRoundPlayerId'ye ihtiyacımız var
    const lastRoundPlayerId = ((_d = (_c = after === null || after === void 0 ? void 0 : after.lastRoundPlayerId) !== null && _c !== void 0 ? _c : after === null || after === void 0 ? void 0 : after.currentPlayerId) !== null && _d !== void 0 ? _d : "");
    const turnOrder = Array.isArray(after === null || after === void 0 ? void 0 : after.turnOrder)
        ? after.turnOrder
        : [];
    const categoryPickOrder = Array.isArray(after === null || after === void 0 ? void 0 : after.categoryPickOrder)
        ? after.categoryPickOrder
        : [];
    const mode = (after === null || after === void 0 ? void 0 : after.mode) === "economy" ? "economy" : "classic";
    const orderSource = mode === "economy" && categoryPickOrder.length > 0
        ? categoryPickOrder
        : turnOrder;
    const activeOrder = orderSource.filter((id) => players.some((p) => p.id === id));
    const currentRound = typeof (after === null || after === void 0 ? void 0 : after.currentRound) === "number" ? after.currentRound : 1;
    const isLastActive = activeOrder.length > 0 &&
        activeOrder[activeOrder.length - 1] === lastRoundPlayerId;
    let shouldEnd = false;
    if (endType === "rounds") {
        shouldEnd = currentRound >= endValue && isLastActive;
    }
    else {
        // Veritabanından gelen güncel skorlarla bitiş kontrolü yap
        shouldEnd = players.some((p) => p.score >= endValue);
    }
    if (!shouldEnd)
        return;
    // Veritabanından gelen güncel skorlarla sıralama yap
    const sorted = [...players].sort((a, b) => b.score - a.score);
    const rewards = {};
    sorted.forEach((p, i) => {
        if (p.score <= 0)
            return;
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
        if (points <= 0)
            continue;
        const userRef = db.collection("users").doc(userId);
        batch.set(userRef, {
            walletPoints: admin.firestore.FieldValue.increment(points),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
    }
    await batch.commit();
    functions.logger.info(`Game ${gameId} finished and rewards distributed.`);
});
