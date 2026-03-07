// Cosmetics koleksiyonunu Firestore'da seed'ler.
// Çalıştırmak için (Firebase bağlantısı gerekir): flutter run -t tool/seed_cosmetics.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_risk/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final cosmeticsRef = firestore.collection('cosmetics');

  final snap = await cosmeticsRef.get();
  debugPrint("Found ${snap.docs.length} cosmetics in db. Clearing...");

  final batch = firestore.batch();
  for (var doc in snap.docs) {
    batch.delete(doc.reference);
  }

  final items = {
    'frame_fire': {
      'name': 'Ateş Çerçevesi',
      'type': 'frame',
      'imageUrl': '🔥',
      'price': 500,
      'isActive': true,
    },
    'frame_ice': {
      'name': 'Buz Çerçevesi',
      'type': 'frame',
      'imageUrl': '🧊',
      'price': 500,
      'isActive': true,
    },
    'frame_flower': {
      'name': 'Çiçek Çerçevesi',
      'type': 'frame',
      'imageUrl': '🌸',
      'price': 400,
      'isActive': true,
    },
    'frame_shield': {
      'name': 'Kalkan Çerçevesi',
      'type': 'frame',
      'imageUrl': '🛡️',
      'price': 600,
      'isActive': true,
    },
    'title_king': {
      'name': 'Kral Unvanı',
      'type': 'title',
      'imageUrl': '👑',
      'price': 1000,
      'isActive': true,
    },
    'title_knight': {
      'name': 'Şövalye Unvanı',
      'type': 'title',
      'imageUrl': '⚔️',
      'price': 600,
      'isActive': true,
    },
    'title_mage': {
      'name': 'Büyücü Unvanı',
      'type': 'title',
      'imageUrl': '🔮',
      'price': 800,
      'isActive': true,
    },
    'title_assassin': {
      'name': 'Suikastçı Unvanı',
      'type': 'title',
      'imageUrl': '🗡️',
      'price': 700,
      'isActive': true,
    },
    'title_jester': {
      'name': 'Soytarı Unvanı',
      'type': 'title',
      'imageUrl': '🤡',
      'price': 200,
      'isActive': true,
    },
  };

  for (var entry in items.entries) {
    batch.set(cosmeticsRef.doc(entry.key), entry.value);
  }

  await batch.commit();
  debugPrint("Seeding complete.");
}
