import 'tasks_fiziksel_en.dart';
import 'tasks_bilgi_en.dart';
import 'tasks_dijital_en.dart';
import 'tasks_itiraf_en.dart';
import 'tasks_zihinsel_en.dart';
import 'tasks_ahlaki_en.dart';
import 'tasks_gorsel_en.dart';
import 'tasks_mahrem_en.dart';
// Diğer kategoriler buraya eklenecek

class TaskTranslationMap {
  static const Map<String, String> _en = {
    ...tasksFizikselEn,
    ...tasksBilgiEn,
    ...tasksDijitalEn,
    ...tasksItirafEn,
    ...tasksZihinselEn,
    ...tasksAhlakiEn,
    ...tasksGorselEn,
    ...tasksMahremEn,
  };

  /// Görev ID'sine göre eğer dil İngilizce ise çeviriyi döndürür.
  /// Eğer çeviri yoksa orijinal içeriği döndürür.
  static String getTranslation(String taskId, String originalContent, String languageCode) {
    if (languageCode != 'en') return originalContent;
    
    // local_... ID'sine göre ara
    if (_en.containsKey(taskId)) {
      return _en[taskId]!;
    }
    
    // ID bulunamadıysa (Firestore görevleri vb.) fallback olarak içeriğe bakılabilir 
    // veya orijinal içerik döndürülür.
    return originalContent;
  }
}
