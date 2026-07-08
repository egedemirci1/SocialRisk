/// Ahlaki (Etik İkilemler ve Şeytanın Avukatlığı) — Tam 120 görev.
/// 4 Alt Kategori:
/// 1. Şeytanın Avukatı (Genel Vahşet & Makro Etik)
/// 2. Sırt Bıçağı (Bireysel İhanet & Mikro Etik)
/// 3. Kırmızı Çizgi (Ahlaki Sınır) + Pişman Olmam (Gururlu Savunma)
/// 4. Hangisi Daha Az Kötü? (Zorunlu İkilem & Gerekçelendirme)
/// Format: Oyuncu rol canlandırır, ikilemde karar verir veya masayı ikna eder; masa performansı oylar.


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