/// Ahlaki (Etik İkilemler ve Şeytanın Avukatlığı) — Tam 120 görev.
/// 4 Alt Kategori:
/// 1. Tanrı Kompleksi (Genel Vahşet & Makro Etik)
/// 2. Satış Noktası (Bireysel İhanet & Mikro Etik)
/// 3. Kutsal Yalanlar (Paradoksal Savunma)
/// 4. Kirli Ayna (Karanlık İtiraf & Analiz)
/// Format: Oyuncu ahlaken savunulması zor olanı savunur veya masadakilerle acımasızca yüzleşir.
/// Masa, oyuncunun performansını ve ikna ediciliğini oylar.


part 'tasks_ahlaki.dart.tanri.part.dart';
part 'tasks_ahlaki.dart.satis.part.dart';
part 'tasks_ahlaki.dart.kutsal.part.dart';
part 'tasks_ahlaki.dart.kirli.part.dart';

final List<Map<String, dynamic>> tasksAhlaki = [
  ..._tasksAhlakitanri,
  ..._tasksAhlakisatis,
  ..._tasksAhlakikutsal,
  ..._tasksAhlakikirli,
];