import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Assuming firebase options are initialized in main.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final cosmeticsRef = firestore.collection('cosmetics');

  final snap = await cosmeticsRef.get();
  debugPrint("Found ${snap.docs.length} cosmetics in db.");

  if (snap.docs.isEmpty) {
    debugPrint("Seeding cosmetics...");
    final items = [
      {
        'name': 'Ateş Çerçevesi',
        'type': 'frame',
        'imageUrl': '🔥',
        'price': 500,
        'isActive': true,
      },
      {
        'name': 'Buz Çerçevesi',
        'type': 'frame',
        'imageUrl': '🧊',
        'price': 500,
        'isActive': true,
      },
      {
        'name': 'Kral Unvanı',
        'type': 'title',
        'imageUrl': '👑',
        'price': 1000,
        'isActive': true,
      },
      {
        'name': 'Soytarı Unvanı',
        'type': 'title',
        'imageUrl': '🤡',
        'price': 200,
        'isActive': true,
      },
    ];

    for (var item in items) {
      await cosmeticsRef.add(item);
    }
    debugPrint("Seeding complete.");
  }
}
