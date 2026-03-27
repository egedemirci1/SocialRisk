/// 8 kategori × 100 soru = 800 soru, tamamen local.
/// Kategoriler: Fiziksel, Bilgi, Dijital, İtiraf, Zihinsel, Ahlaki, Görsel, Mahrem.
/// + Stand-Up ve Kıvırma Premium Senaryolar
library;
import 'tasks_fiziksel.dart';
import 'tasks_bilgi.dart';
import 'tasks_dijital.dart';
import 'tasks_itiraf.dart';
import 'tasks_zihinsel.dart';
import 'tasks_ahlaki.dart';
import 'tasks_gorsel.dart';
import 'tasks_mahrem.dart';
import 'tasks_standup.dart';
import 'tasks_kivirma.dart';

/// Tüm local seed soruları (1040 adet). Uygulama veya seed akışı bu listeyi kullanabilir.
List<Map<String, dynamic>> getAllSeededTasks() {
  return [
    ...tasksFiziksel,
    ...tasksBilgi,
    ...tasksDijital,
    ...tasksItiraf,
    ...tasksZihinsel,
    ...tasksAhlaki,
    ...tasksGorsel,
    ...tasksMahrem,
    ...tasksStandUp,
    ...tasksKivirma,
  ];
}
