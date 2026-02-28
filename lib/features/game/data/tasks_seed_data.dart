import 'game_model.dart';

/// Minimum 30 görev, kategorilere ayrılmış.
/// Multiplier: 1x (kolay), 2x (orta), 3x (zor/cesaret)
final List<TaskModel> tasksSeedData = [
  // ── CESARET (Dare) ──────────────────────────────────
  const TaskModel(id: 't1',  category: 'Cesaret', content: 'Telefondaki son aramanı herkese göster.', multiplier: 1),
  const TaskModel(id: 't2',  category: 'Cesaret', content: 'Yanındaki kişiye 1 dakika boyunca iltifat et.', multiplier: 1),
  const TaskModel(id: 't3',  category: 'Cesaret', content: 'Rastgele bir kişiyi ara ve "Seni özledim" de.', multiplier: 3),
  const TaskModel(id: 't4',  category: 'Cesaret', content: 'Gruptaki en komik anını anlat.', multiplier: 1),
  const TaskModel(id: 't5',  category: 'Cesaret', content: 'Telefonundaki son fotoğrafı herkese göster.', multiplier: 2),
  const TaskModel(id: 't6',  category: 'Cesaret', content: '30 saniye boyunca robot gibi dans et.', multiplier: 2),
  const TaskModel(id: 't7',  category: 'Cesaret', content: 'Instagram hikayene "Bu oyun harika!" yaz ve paylaş.', multiplier: 3),

  // ── İTİRAF (Confession) ─────────────────────────────
  const TaskModel(id: 't8',  category: 'İtiraf', content: 'Hayatında en çok utandığın anı anlat.', multiplier: 2),
  const TaskModel(id: 't9',  category: 'İtiraf', content: 'En son ne hakkında yalan söyledin?', multiplier: 2),
  const TaskModel(id: 't10', category: 'İtiraf', content: 'Gruptaki birini seç ve onun hakkında düşündüğün bir şeyi söyle.', multiplier: 3),
  const TaskModel(id: 't11', category: 'İtiraf', content: 'En garip alışkanlığını itiraf et.', multiplier: 1),
  const TaskModel(id: 't12', category: 'İtiraf', content: 'Hiç kopya çektin mi? Nasıl?', multiplier: 1),
  const TaskModel(id: 't13', category: 'İtiraf', content: 'En son kimi stalkladın?', multiplier: 2),
  const TaskModel(id: 't14', category: 'İtiraf', content: 'Gizli bir yeteneğini göster veya anlat.', multiplier: 1),

  // ── TAKLİT (Imitation) ──────────────────────────────
  const TaskModel(id: 't15', category: 'Taklit', content: 'Gruptaki birinin yürüyüşünü taklit et, herkes tahmin etsin.', multiplier: 2),
  const TaskModel(id: 't16', category: 'Taklit', content: 'Ünlü birinin konuşmasını taklit et.', multiplier: 2),
  const TaskModel(id: 't17', category: 'Taklit', content: 'Bir hayvanı ses ve hareketleriyle taklit et.', multiplier: 1),
  const TaskModel(id: 't18', category: 'Taklit', content: 'Bir film sahnesini canlandır, herkes tahmin etsin.', multiplier: 2),
  const TaskModel(id: 't19', category: 'Taklit', content: 'Gruptaki birinin ses tonuyla 30 saniye konuş.', multiplier: 3),

  // ── SOSYAL MEDYA ────────────────────────────────────
  const TaskModel(id: 't20', category: 'Sosyal Medya', content: 'WhatsApp son konuşmalarını 10 saniye göster.', multiplier: 3),
  const TaskModel(id: 't21', category: 'Sosyal Medya', content: 'Instagram keşfetini herkese göster.', multiplier: 1),
  const TaskModel(id: 't22', category: 'Sosyal Medya', content: 'Son beğendiğin 5 gönderiyi göster.', multiplier: 2),
  const TaskModel(id: 't23', category: 'Sosyal Medya', content: 'Ekran süren kaç saat? Herkese göster.', multiplier: 1),

  // ── FİZİKSEL GÖREV ─────────────────────────────────
  const TaskModel(id: 't24', category: 'Fiziksel', content: '20 şınav çek.', multiplier: 2),
  const TaskModel(id: 't25', category: 'Fiziksel', content: '1 dakika boyunca tek ayak üstünde dur.', multiplier: 1),
  const TaskModel(id: 't26', category: 'Fiziksel', content: 'Odanın etrafında 3 tur koş.', multiplier: 1),
  const TaskModel(id: 't27', category: 'Fiziksel', content: '30 saniye plank yap.', multiplier: 2),

  // ── BİLGİ / ZEKA ───────────────────────────────────
  const TaskModel(id: 't28', category: 'Bilgi', content: '10 saniyede 5 başkent say.', multiplier: 1),
  const TaskModel(id: 't29', category: 'Bilgi', content: '15 saniyede 10 hayvan ismi say.', multiplier: 1),
  const TaskModel(id: 't30', category: 'Bilgi', content: 'Tersten 100\'den 7\'şer say.', multiplier: 3),
  const TaskModel(id: 't31', category: 'Bilgi', content: '20 saniyede 5 ülke ve başkentini eşleştir.', multiplier: 2),
  const TaskModel(id: 't32', category: 'Bilgi', content: 'Gruptaki herkesin burcunu tahmin et.', multiplier: 2),
];
