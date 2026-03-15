"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onGameUpdated = void 0;
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
if (!admin.apps.length)
    admin.initializeApp();
const db = admin.firestore();
const RANK_REWARDS = [200, 100, 50];
const DEFAULT_REWARD = 20;
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
