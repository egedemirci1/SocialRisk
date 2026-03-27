"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onGameUpdated = exports.finalizeVotingRound = exports.distributeRewards = exports.activatePremium = exports.buyCosmetic = exports.forceCleanupOldPlayingRooms = exports.runMaintenanceCleanup = exports.auditContentState = exports.deleteOwnUserData = exports.cleanupInactiveUsers = exports.cleanupOldGames = exports.cleanupEmptyRooms = void 0;
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
if (!admin.apps.length)
    admin.initializeApp();
const db = admin.firestore();
const storageBucket = admin.storage().bucket("socialrisk-9840e.firebasestorage.app");
const RANK_REWARDS = [200, 100, 50];
const DEFAULT_REWARD = 20;
const DEFAULT_ECONOMY_BASE_VALUE = 10;
const ECONOMY_PENALTY_AMOUNT = 2;
const HOT_CATEGORY_BONUS = DEFAULT_ECONOMY_BASE_VALUE + ECONOMY_PENALTY_AMOUNT;
const ECONOMY_PENALTY_VALUE = DEFAULT_ECONOMY_BASE_VALUE - ECONOMY_PENALTY_AMOUNT;
const EXPECTED_SEEDED_TASK_COUNT = 800;
const ADMIN_UIDS = [
    "y51M7E6YXZT5I04M9YFqGzSgZ7Y2",
    "hW42qgzVJIXr6sOLO0q1zPOdv6w1",
    "d7sLOX946mRfrmkYMRUOJXNa44l2",
];
const PREMIUM_LIFETIME_PRODUCT_ID = "premium_lifetime";
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
function timestampMillis(value) {
    if (value instanceof admin.firestore.Timestamp) {
        return value.toMillis();
    }
    if (value instanceof Date) {
        return value.getTime();
    }
    if (typeof value === "number") {
        return value;
    }
    return 0;
}
async function deleteFilesWithPrefixes(prefixes) {
    let deleted = 0;
    for (const prefix of prefixes) {
        const [files] = await storageBucket.getFiles({ prefix });
        for (const file of files) {
            await file.delete({ ignoreNotFound: true });
            deleted++;
        }
    }
    return deleted;
}
async function deleteUserData(uid, avatarUrl) {
    var _a, _b, _c, _d;
    const userRef = db.collection("users").doc(uid);
    const customTasksRef = userRef.collection("custom_tasks");
    const [profileSnap, customTasksSnap] = await Promise.all([
        userRef.get(),
        customTasksRef.get(),
    ]);
    let deletedFiles = await deleteFilesWithPrefixes([
        `avatars/${uid}_`,
        `users/${uid}/`,
    ]);
    const resolvedAvatarUrl = (_b = avatarUrl !== null && avatarUrl !== void 0 ? avatarUrl : (profileSnap.exists ? (_a = profileSnap.data()) === null || _a === void 0 ? void 0 : _a.avatarUrl : null)) !== null && _b !== void 0 ? _b : null;
    if (resolvedAvatarUrl && resolvedAvatarUrl.startsWith("https://firebasestorage.googleapis.com")) {
        try {
            const file = storageBucket.file(decodeURIComponent((_d = (_c = resolvedAvatarUrl.split("/o/")[1]) === null || _c === void 0 ? void 0 : _c.split("?")[0]) !== null && _d !== void 0 ? _d : ""));
            await file.delete({ ignoreNotFound: true });
            deletedFiles++;
        }
        catch (error) {
            functions.logger.warn("Avatar URL cleanup failed", { uid, error });
        }
    }
    for (const doc of customTasksSnap.docs) {
        await doc.ref.delete();
    }
    if (profileSnap.exists) {
        await userRef.delete();
    }
    try {
        await admin.auth().deleteUser(uid);
    }
    catch (error) {
        functions.logger.warn("Auth user cleanup skipped", { uid, error });
    }
    return { deletedFiles };
}
async function deleteRoomAndRelatedData(roomRef, roomData) {
    const gameId = typeof roomData.gameId === "string" ? roomData.gameId : "";
    await db.recursiveDelete(roomRef);
    if (gameId) {
        await db.recursiveDelete(db.collection("games").doc(gameId));
    }
}
function isAdminUid(uid) {
    return typeof uid === "string" && ADMIN_UIDS.includes(uid);
}
async function performEmptyRoomCleanup() {
    var _a, _b;
    const roomsSnapshot = await db.collection("rooms").get();
    let deletedCount = 0;
    for (const doc of roomsSnapshot.docs) {
        const room = doc.data();
        const storedPlayerCount = typeof room.playerCount === "number" ? room.playerCount : 0;
        let playerCount = storedPlayerCount;
        if (storedPlayerCount <= 1) {
            const playersSnapshot = await doc.ref.collection("players").limit(2).get();
            playerCount = playersSnapshot.size;
        }
        const roomAge = Date.now() - (((_b = (_a = room.createdAt) === null || _a === void 0 ? void 0 : _a.toMillis) === null || _b === void 0 ? void 0 : _b.call(_a)) || 0);
        const oneHour = 60 * 60 * 1000;
        if (playerCount === 0 || (playerCount === 1 && roomAge > oneHour)) {
            await deleteRoomAndRelatedData(doc.ref, room);
            deletedCount++;
        }
    }
    return deletedCount;
}
async function performOldGamesCleanup() {
    const oneDayAgoMs = Date.now() - 24 * 60 * 60 * 1000;
    const gamesSnapshot = await db.collection("games")
        .where("status", "==", "finished")
        .get();
    let deletedCount = 0;
    for (const doc of gamesSnapshot.docs) {
        const game = doc.data();
        const referenceTime = timestampMillis(game.finishedAt)
            || timestampMillis(game.updatedAt)
            || timestampMillis(game.createdAt)
            || doc.updateTime.toMillis();
        if (referenceTime > 0 && referenceTime < oneDayAgoMs) {
            await db.recursiveDelete(doc.ref);
            deletedCount++;
        }
    }
    return deletedCount;
}
async function performInactiveUsersCleanup() {
    const ninetyDaysAgoMs = Date.now() - 90 * 24 * 60 * 60 * 1000;
    const usersSnapshot = await db.collection("users").get();
    let deletedCount = 0;
    for (const doc of usersSnapshot.docs) {
        const user = doc.data();
        const lastActivity = timestampMillis(user.lastSeenAt)
            || timestampMillis(user.updatedAt)
            || doc.updateTime.toMillis();
        const walletPoints = typeof user.walletPoints === "number" ? user.walletPoints : 0;
        const ownedCosmetics = Array.isArray(user.ownedCosmetics) ? user.ownedCosmetics : [];
        if (lastActivity > 0 &&
            lastActivity < ninetyDaysAgoMs &&
            walletPoints === 0 &&
            ownedCosmetics.length === 0) {
            await deleteUserData(doc.id, user.avatarUrl);
            deletedCount++;
        }
    }
    return deletedCount;
}
function hasReachedScoreTarget(players, targetScore) {
    return players.some((player) => player.score >= targetScore);
}
function comparePlayersForFinalRank(a, b) {
    if (b.score !== a.score)
        return b.score - a.score;
    if (b.totalLikes !== a.totalLikes)
        return b.totalLikes - a.totalLikes;
    return a.id.localeCompare(b.id);
}
// Her 6 saatte bir boş odaları temizle
exports.cleanupEmptyRooms = functions.pubsub
    .schedule('every 6 hours')
    .onRun(async (context) => {
    console.log('Starting cleanup of empty rooms...');
    const deletedCount = await performEmptyRoomCleanup();
    if (deletedCount === 0) {
        console.log('No rooms to clean up');
    }
    else {
        console.log(`Deleted ${deletedCount} empty/abandoned rooms`);
    }
    return null;
});
// Her gün eski oyunları temizle (24 saatten eski bitmiş oyunlar)
exports.cleanupOldGames = functions.pubsub
    .schedule('every 24 hours')
    .onRun(async (context) => {
    console.log('Starting cleanup of old games...');
    const deletedCount = await performOldGamesCleanup();
    if (deletedCount === 0) {
        console.log('No old games to clean up');
    }
    else {
        console.log(`Deleted ${deletedCount} old finished games`);
    }
    return null;
});
// Inactive user'ları temizle (90 gündür giriş yapmayanlar)
exports.cleanupInactiveUsers = functions.pubsub
    .schedule('0 0 1 * *') // Her ayın 1'inde saat 00:00'da
    .timeZone('America/New_York')
    .onRun(async (context) => {
    console.log('Starting cleanup of inactive users...');
    const deletedCount = await performInactiveUsersCleanup();
    if (deletedCount === 0) {
        console.log('No inactive users to clean up');
    }
    else {
        console.log(`Deleted ${deletedCount} inactive users`);
    }
    return null;
});
exports.deleteOwnUserData = functions.https.onCall(async (data, context) => {
    var _a;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }
    const uid = typeof (data === null || data === void 0 ? void 0 : data.uid) === "string" ? data.uid.trim() : context.auth.uid;
    if (uid !== context.auth.uid) {
        throw new functions.https.HttpsError("permission-denied", "You can only delete your own user data.");
    }
    const profileSnap = await db.collection("users").doc(uid).get();
    const avatarUrl = profileSnap.exists ? (_a = profileSnap.data()) === null || _a === void 0 ? void 0 : _a.avatarUrl : undefined;
    const cleanupResult = await deleteUserData(uid, avatarUrl);
    return {
        deleted: true,
        deletedFiles: cleanupResult.deletedFiles,
    };
});
exports.auditContentState = functions.https.onCall(async (data, context) => {
    var _a, _b;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }
    const [tasksSnap, roomsSnap, gamesSnap, usersSnap, customTasksSnap] = await Promise.all([
        db.collection("tasks").get(),
        db.collection("rooms").get(),
        db.collection("games").get(),
        db.collection("users").get(),
        db.collectionGroup("custom_tasks").get(),
    ]);
    const tasksByCategory = {};
    const tasksByDifficulty = {};
    let activeTaskCount = 0;
    let missingCoreFieldsCount = 0;
    let latestTaskCreatedAtMs = 0;
    for (const doc of tasksSnap.docs) {
        const task = doc.data();
        const category = typeof task.category === "string" ? task.category : "unknown";
        const difficulty = typeof task.difficulty === "string" ? task.difficulty : "unknown";
        tasksByCategory[category] = ((_a = tasksByCategory[category]) !== null && _a !== void 0 ? _a : 0) + 1;
        tasksByDifficulty[difficulty] = ((_b = tasksByDifficulty[difficulty]) !== null && _b !== void 0 ? _b : 0) + 1;
        if (task.isActive === true) {
            activeTaskCount++;
        }
        if (!task.category || !task.content || !task.difficulty || !task.type) {
            missingCoreFieldsCount++;
        }
        latestTaskCreatedAtMs = Math.max(latestTaskCreatedAtMs, timestampMillis(task.createdAt));
    }
    let emptyRoomsCount = 0;
    let orphanGamesCount = 0;
    let twoCategoryEconomyIssueCount = 0;
    for (const roomDoc of roomsSnap.docs) {
        const roomData = roomDoc.data();
        const storedPlayerCount = typeof roomData.playerCount === "number" ? roomData.playerCount : 0;
        if (storedPlayerCount === 0) {
            emptyRoomsCount++;
        }
    }
    for (const gameDoc of gamesSnap.docs) {
        const game = gameDoc.data();
        const roomId = typeof game.roomId === "string" ? game.roomId : "";
        if (!roomId || !roomsSnap.docs.some((roomDoc) => roomDoc.id === roomId)) {
            orphanGamesCount++;
        }
        const marketValues = game.categoryMarketValues;
        const categoryCount = marketValues ? Object.keys(marketValues).length : 0;
        const lockedCategories = Array.isArray(game.lockedCategories) ? game.lockedCategories : [];
        const hasNonTenBase = marketValues
            ? Object.values(marketValues).some((value) => typeof value === "number" && value !== 10)
            : false;
        if (game.mode === "economy" && categoryCount > 0 && categoryCount < 3 && (lockedCategories.length > 0 || hasNonTenBase)) {
            twoCategoryEconomyIssueCount++;
        }
    }
    return {
        tasks: {
            total: tasksSnap.size,
            active: activeTaskCount,
            expectedSeededMinimum: EXPECTED_SEEDED_TASK_COUNT,
            categories: tasksByCategory,
            difficulties: tasksByDifficulty,
            missingCoreFieldsCount,
            latestCreatedAtMs: latestTaskCreatedAtMs,
            looksSeededAndCurrent: tasksSnap.size >= EXPECTED_SEEDED_TASK_COUNT && missingCoreFieldsCount === 0,
        },
        customTasks: {
            total: customTasksSnap.size,
        },
        rooms: {
            total: roomsSnap.size,
            emptyCount: emptyRoomsCount,
        },
        games: {
            total: gamesSnap.size,
            orphanCount: orphanGamesCount,
            economyIssuesUnderThreeCategories: twoCategoryEconomyIssueCount,
        },
        users: {
            total: usersSnap.size,
        },
    };
});
exports.runMaintenanceCleanup = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }
    if (!isAdminUid(context.auth.uid)) {
        throw new functions.https.HttpsError("permission-denied", "Admin access required.");
    }
    const [roomsDeleted, gamesDeleted, usersDeleted] = await Promise.all([
        performEmptyRoomCleanup(),
        performOldGamesCleanup(),
        performInactiveUsersCleanup(),
    ]);
    return {
        roomsDeleted,
        gamesDeleted,
        usersDeleted,
    };
});
exports.forceCleanupOldPlayingRooms = functions.https.onCall(async (data, context) => {
    var _a, _b;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }
    if (!isAdminUid(context.auth.uid)) {
        throw new functions.https.HttpsError("permission-denied", "Admin access required.");
    }
    const threeHoursAgoMs = Date.now() - 3 * 60 * 60 * 1000;
    const roomsSnapshot = await db.collection("rooms").get();
    let deletedCount = 0;
    for (const doc of roomsSnapshot.docs) {
        const room = doc.data();
        // Aggressive: use updateTime if createdAt is missing
        const createdAt = timestampMillis(room.createdAt);
        const docUpdateTime = ((_b = (_a = doc.updateTime) === null || _a === void 0 ? void 0 : _a.toMillis) === null || _b === void 0 ? void 0 : _b.call(_a)) || 0;
        const referenceTime = createdAt > 0 ? createdAt : docUpdateTime;
        const isOld = referenceTime > 0 && referenceTime < threeHoursAgoMs;
        // Aggressive: if status is missing, treat as "unknown" and still delete if old
        const status = room.status || "unknown";
        const isPlaying = status === "playing" || status === "lobby" || status === "unknown";
        if (isPlaying && isOld) {
            await deleteRoomAndRelatedData(doc.ref, room);
            deletedCount++;
        }
    }
    return {
        deleted: deletedCount,
    };
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
        if (cosmeticData.type === "category" && userData.isPremium !== true) {
            throw new functions.https.HttpsError("permission-denied", "Premium membership required for scenario packs.");
        }
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
exports.activatePremium = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }
    const uid = context.auth.uid;
    const productId = typeof (data === null || data === void 0 ? void 0 : data.productId) === "string" ? data.productId.trim() : "";
    const purchaseId = typeof (data === null || data === void 0 ? void 0 : data.purchaseId) === "string" ? data.purchaseId.trim() : "";
    const verificationData = typeof (data === null || data === void 0 ? void 0 : data.verificationData) === "string"
        ? data.verificationData.trim()
        : "";
    const source = typeof (data === null || data === void 0 ? void 0 : data.source) === "string" ? data.source.trim() : "";
    if (productId !== PREMIUM_LIFETIME_PRODUCT_ID) {
        throw new functions.https.HttpsError("invalid-argument", "Unsupported productId.");
    }
    if (source !== "play_store" && source !== "app_store") {
        throw new functions.https.HttpsError("invalid-argument", "Invalid purchase source.");
    }
    if (!purchaseId && !verificationData) {
        throw new functions.https.HttpsError("invalid-argument", "purchaseId or verificationData is required.");
    }
    // NOTE: Real store-side receipt validation should be added with Play/App Store APIs.
    // This callable currently performs server-side entitlement issuance and replay protection.
    const purchaseKey = purchaseId || verificationData.substring(0, 120);
    const purchaseRef = db.collection("premiumPurchases").doc(purchaseKey);
    const userRef = db.collection("users").doc(uid);
    await db.runTransaction(async (transaction) => {
        var _a;
        const [purchaseSnap, userSnap] = await Promise.all([
            transaction.get(purchaseRef),
            transaction.get(userRef),
        ]);
        if (!userSnap.exists) {
            throw new functions.https.HttpsError("not-found", "User not found.");
        }
        if (purchaseSnap.exists) {
            const purchaseData = (_a = purchaseSnap.data()) !== null && _a !== void 0 ? _a : {};
            const existingUid = typeof purchaseData.uid === "string" ? purchaseData.uid : "";
            if (existingUid && existingUid !== uid) {
                throw new functions.https.HttpsError("already-exists", "Purchase already linked to another user.");
            }
        }
        transaction.set(purchaseRef, {
            uid,
            productId,
            source,
            purchaseId: purchaseId || null,
            verificationDataHash: verificationData ? verificationData.substring(0, 64) : null,
            activatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        transaction.set(userRef, {
            isPremium: true,
            premiumType: "lifetime",
            premiumSource: source,
            premiumProductId: productId,
            premiumActivatedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
    });
    return { ok: true, isPremium: true };
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
        transaction.update(roomRef.collection("players").doc(currentPlayerId), {
            score: admin.firestore.FieldValue.increment(totalScore),
            totalLikes: admin.firestore.FieldValue.increment(likes),
        });
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
        const rawScore = d.score;
        const rawTotalLikes = d.totalLikes;
        const score = typeof rawScore === "number" ? Math.floor(rawScore) : parseInt(String(rawScore), 10) || 0;
        const totalLikes = typeof rawTotalLikes === "number"
            ? Math.floor(rawTotalLikes)
            : parseInt(String(rawTotalLikes), 10) || 0;
        return { id: doc.id, score, totalLikes };
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
        // Skor modu her zaman oyuncunun tur sonunda gerçekten ulaştığı toplam puana göre karar verir.
        // Challenge'ın ham değeri veya teorik tam puanı değil, oylama sonrası persisted skor esas alınır.
        shouldEnd = isLastActive && hasReachedScoreTarget(players, endValue);
    }
    if (!shouldEnd)
        return;
    // Veritabanından gelen güncel skorlarla sıralama yap
    const sorted = [...players].sort(comparePlayersForFinalRank);
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
