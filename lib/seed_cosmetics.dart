import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// Assuming firebase options are initialized in main.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    // ── EFSANELİK (5)
    'title_legend': {
      'name': 'Efsane',
      'type': 'title',
      'imageUrl': '⚡',
      'price': 1200,
      'isActive': true,
    },
    'title_king': {
      'name': 'Kral',
      'type': 'title',
      'imageUrl': '👑',
      'price': 1000,
      'isActive': true,
    },
    'title_chosen': {
      'name': 'Seçilmiş',
      'type': 'title',
      'imageUrl': '🌟',
      'price': 900,
      'isActive': true,
    },
    'title_emperor': {
      'name': 'İmparator',
      'type': 'title',
      'imageUrl': '🏛️',
      'price': 1500,
      'isActive': true,
    },
    'title_immortal': {
      'name': 'Ölümsüz',
      'type': 'title',
      'imageUrl': '✨',
      'price': 1800,
      'isActive': true,
    },
    // ── SAVAŞÇI (5)
    'title_knight': {
      'name': 'Şövalye',
      'type': 'title',
      'imageUrl': '⚔️',
      'price': 600,
      'isActive': true,
    },
    'title_warrior': {
      'name': 'Savaşçı',
      'type': 'title',
      'imageUrl': '🗡️',
      'price': 400,
      'isActive': true,
    },
    'title_arena': {
      'name': 'Arena Şampiyonu',
      'type': 'title',
      'imageUrl': '🏆',
      'price': 800,
      'isActive': true,
    },
    'title_berserker': {
      'name': 'Zorba',
      'type': 'title',
      'imageUrl': '💪',
      'price': 500,
      'isActive': true,
    },
    'title_commander': {
      'name': 'Komutan',
      'type': 'title',
      'imageUrl': '🎖️',
      'price': 700,
      'isActive': true,
    },
    // ── GİZEM (5)
    'title_mage': {
      'name': 'Büyücü',
      'type': 'title',
      'imageUrl': '🔮',
      'price': 800,
      'isActive': true,
    },
    'title_shadow': {
      'name': 'Gölge',
      'type': 'title',
      'imageUrl': '🌑',
      'price': 600,
      'isActive': true,
    },
    'title_alchemist': {
      'name': 'Simyacı',
      'type': 'title',
      'imageUrl': '⚗️',
      'price': 700,
      'isActive': true,
    },
    'title_phantom': {
      'name': 'Hayalet',
      'type': 'title',
      'imageUrl': '👻',
      'price': 500,
      'isActive': true,
    },
    'title_oracle': {
      'name': 'Kahin',
      'type': 'title',
      'imageUrl': '🔭',
      'price': 900,
      'isActive': true,
    },
    // ── EĞLENCELİ (5)
    'title_jester': {
      'name': 'Soytarı',
      'type': 'title',
      'imageUrl': '🤡',
      'price': 200,
      'isActive': true,
    },
    'title_trickster': {
      'name': 'Oyunbaz',
      'type': 'title',
      'imageUrl': '🃏',
      'price': 300,
      'isActive': true,
    },
    'title_showman': {
      'name': 'Göstericisi',
      'type': 'title',
      'imageUrl': '🎪',
      'price': 350,
      'isActive': true,
    },
    'title_comedian': {
      'name': 'Komedyen',
      'type': 'title',
      'imageUrl': '😂',
      'price': 250,
      'isActive': true,
    },
    'title_chameleon': {
      'name': 'Kameleon',
      'type': 'title',
      'imageUrl': '🦎',
      'price': 400,
      'isActive': true,
    },
    // ── HAFİFMEŞREP (5)
    'title_daredevil': {
      'name': 'Pervasız',
      'type': 'title',
      'imageUrl': '🔥',
      'price': 600,
      'isActive': true,
    },
    'title_nightowl': {
      'name': 'Gece Kuşu',
      'type': 'title',
      'imageUrl': '🦉',
      'price': 450,
      'isActive': true,
    },
    'title_flirt': {
      'name': 'Çapkın',
      'type': 'title',
      'imageUrl': '😏',
      'price': 350,
      'isActive': true,
    },
    'title_rebel': {
      'name': 'İsyancı',
      'type': 'title',
      'imageUrl': '💀',
      'price': 500,
      'isActive': true,
    },
    'title_wild': {
      'name': 'Başıbozuk',
      'type': 'title',
      'imageUrl': '🎭',
      'price': 400,
      'isActive': true,
    },
    'scenario_18': {
      'name': 'Kapalı Gişe (18+)',
      'description': 'Daha cesur ve yetişkinlere yönelik hikayeler.',
      'type': 'category',
      'categoryName': 'Kapalı Gişe',
      'imageUrl': '🔞',
      'price': 1500,
      'isActive': true,
    },
    'scenario_romance': {
      'name': 'Aşkın Sahnesi',
      'description': 'Romantik ve duygusal temalı hikayeler.',
      'type': 'category',
      'categoryName': 'Aşkın Sahnesi',
      'imageUrl': '❤️',
      'price': 1000,
      'isActive': true,
    },
    'scenario_mystery': {
      'name': 'Gizemli Parti',
      'description': 'Gerilim ve gizem dolu hikayeler.',
      'type': 'category',
      'categoryName': 'Gizemli Parti',
      'imageUrl': '🔍',
      'price': 1200,
      'isActive': true,
    },
    'frame_ivy': {
      'name': 'Doğa Çerçevesi',
      'type': 'frame',
      'imageUrl': '🌿',
      'price': 400,
      'isActive': true,
    },
    'frame_neon': {
      'name': 'Neon Çerçeve',
      'type': 'frame',
      'imageUrl': '⚡',
      'price': 700,
      'isActive': true,
    },
    'frame_stars': {
      'name': 'Yıldız Çerçevesi',
      'type': 'frame',
      'imageUrl': '⭐',
      'price': 800,
      'isActive': true,
    },
    'frame_lightning': {
      'name': 'Şimşek Çerçevesi',
      'type': 'frame',
      'imageUrl': '🌩️',
      'price': 600,
      'isActive': true,
    },
  };

  for (var entry in items.entries) {
    batch.set(cosmeticsRef.doc(entry.key), entry.value);
  }

  await batch.commit();
  debugPrint("Seeding complete.");
}
