import 'tasks_fiziksel_en.dart';
import 'tasks_bilgi_en.dart';
import 'tasks_dijital_en.dart';
import 'tasks_itiraf_en.dart';
import 'tasks_zihinsel_en.dart';
import 'tasks_ahlaki_en.dart';
import 'tasks_gorsel_en.dart';
import 'tasks_mahrem_en.dart';
import 'tasks_standup_en.dart';
import 'tasks_kivirma_en.dart';
import 'tasks_kaos_muhendisi_en.dart';
import 'tasks_bos_vaatler_en.dart';
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
    ...tasksStandUpEn,
    ...tasksKivirmaEn,
    ...tasksKaosMuhendisiEn,
    ...tasksBosVaatlerEn,
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

  /// Kategori ismini dile göre çevirir.
  static String getCategoryTranslation(String category, String languageCode) {
    if (languageCode != 'en') return category;

    switch (category.toLowerCase()) {
      case 'ahlaki':
        return 'Moral';
      case 'bilgi':
        return 'Knowledge';
      case 'dijital':
        return 'Digital';
      case 'fiziksel':
        return 'Physical';
      case 'gorsel':
      case 'görsel':
        return 'Visual';
      case 'itiraf':
        return 'Confession';
      case 'mahrem':
        return 'Intimate';
      case 'zihinsel':
        return 'Mental';
      case 'stand-up':
      case 'standup':
        return 'Stand-Up';
      case 'kıvırma':
      case 'kivirma':
        return 'The Art of Wiggling Out';
      case 'kaos mühendisi':
      case 'kaos muhendisi':
        return 'Chaos Engineer';
      case 'boş vaatler':
      case 'bos vaatler':
        return 'Empty Promises';
      default:
        return category;
    }
  }
}
