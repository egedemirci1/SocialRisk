/// Dijital (Siber Risk ve Gizlilik İhlali) — Tam 120 görev.
/// 4 Alt Kategori:
/// 1. Canlı Sabotaj (Anlık İletişim Sabotajı)
/// 2. Algoritma ve Vitrin Linci (Dijital Ayak İzi)
/// 3. Galeri ve Medya Çöplüğü (Görsel/İşitsel İfşa)
/// 4. Açık Hedef ve Veri İfşası (Kontrol Kaybı ve Rulet)
/// Format: 'options' ve 'answer' içermez.
/// Kurallar: Aile/Genel kitleye uygun, nefret söylemi veya cinsellik içermez.


part 'tasks_dijital.dart.sabotaj.part.dart';
part 'tasks_dijital.dart.algoritma.part.dart';
part 'tasks_dijital.dart.galeri.part.dart';
part 'tasks_dijital.dart.veri.part.dart';

final List<Map<String, dynamic>> tasksDijital = [
  ..._tasksDijitalsabotaj,
  ..._tasksDijitalalgoritma,
  ..._tasksDijitalgaleri,
  ..._tasksDijitalveri,
];