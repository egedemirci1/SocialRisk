import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

const db = admin.firestore();

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
  .schedule('every 30 days')
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
