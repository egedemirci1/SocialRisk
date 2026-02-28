---
applyTo: 'test/**/*.dart, integration_test/**/*.dart'
---

# Test Guardrails — Sosyal Risk (Flutter / Dart)

Sosyal Risk Flutter projesinde birim, widget ve entegrasyon testleri yazarken uyulacak kurallar.

---

## Proje Bağlamı

- **Birim Testler:** `flutter_test` / `test` paketi
- **Widget Testler:** `flutter_test` (`testWidgets`)
- **Entegrasyon Testler:** `patrol` veya `flutter_test` integration
- **Mock:** `mockito` + `build_runner` veya `mocktail`
- **Provider Test:** `riverpod` `ProviderContainer` ile izole test
- **Test Klasörü:** `test/` (unit + widget), `integration_test/` (E2E)
- **CI:** GitHub Actions / Firebase Test Lab

---

## 1) Temel Güvenilirlik İlkeleri

- Testler deterministik ve tekrar çalıştırılabilir olmalıdır.
- Testler birbirinden bağımsız olmalıdır (test sırası önemli olmamalı).
- Paylaşılan mutable state testler arasında sızdırılmamalıdır.
- Gerçek Firebase/Supabase bağlantısı yerine mock/fake kullanılır.
- Her test tek bir davranışı doğrular.
- AAA pattern uygulanır: **Arrange → Act → Assert**.

---

## 2) Test Klasör Yapısı

```
test/
├── unit/
│   ├── features/
│   │   ├── game/
│   │   │   ├── game_notifier_test.dart
│   │   │   └── score_calculator_test.dart
│   │   ├── room/
│   │   │   └── room_repository_test.dart
│   │   └── voting/
│   │       └── vote_processor_test.dart
│   └── core/
│       └── penalty_formula_test.dart
├── widget/
│   ├── voting_panel_test.dart
│   ├── player_avatar_test.dart
│   ├── category_card_test.dart
│   └── score_counter_test.dart
└── helpers/
    ├── test_helpers.dart       # Ortak yardımcı fonksiyonlar
    ├── mock_game_repository.dart
    └── fake_game_state.dart
integration_test/
├── game_flow_test.dart         # Tam oyun akışı E2E testi
└── room_creation_test.dart
```

---

## 3) Birim Test Kuralları

### Repository Testleri

```dart
// DOĞRU: Mock repository ile izole test
void main() {
  late MockGameRepository mockRepo;
  late GameNotifier notifier;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockGameRepository();
    container = ProviderContainer(
      overrides: [
        gameRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    notifier = container.read(gameNotifierProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('oyuncu pas geçince ceza puanı artmalı', () async {
    // Arrange
    when(() => mockRepo.applyPenalty(any(), any()))
        .thenAnswer((_) async => const PenaltyResult(newScore: -50, passStreak: 1));

    // Act
    await notifier.pass();

    // Assert
    verify(() => mockRepo.applyPenalty(any(), 1)).called(1);
  });
}
```

### Provider / Notifier Testleri

- `ProviderContainer` ile izole ortam kurulur.
- Gerçek Firebase/Supabase bağlantısı kurulmaz; fake/mock kullanılır.
- Her `setUp` sonrasında `tearDown(() => container.dispose())` çağrılır.

---

## 4) Widget Test Kuralları

```dart
// DOĞRU: VotingPanel widget testi
testWidgets('oy kullandıktan sonra butonlar devre dışı kalmalı', (tester) async {
  // Arrange
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...],
      child: const MaterialApp(home: VotingPanel()),
    ),
  );

  // Act
  await tester.tap(find.byKey(const Key('vote-positive')));
  await tester.pump();

  // Assert
  final likeButton = tester.widget<ElevatedButton>(
    find.byKey(const Key('vote-positive')),
  );
  expect(likeButton.onPressed, isNull);
});
```

**Kurallar:**
- Raw string yerine `Key` ile selector kullanılır: `find.byKey(const Key('...'))`.
- `find.text()` yalnızca görünür metin doğrulaması için kullanılır.
- `tester.pump()` animasyon/async işlem tamamlama için; `tester.pumpAndSettle()` tamamen sakin duruma getirmek için kullanılır.
- Gerçek ağ isteği yapılmaz; `http.MockClient` veya mock repository kullanılır.

---

## 5) Key Stratejisi (Selector)

Priority sırası:

1. `find.byKey(const Key('...'))` — birincil tercih
2. `find.byType(WidgetType)` — tip bazlı arama
3. `find.byIcon(Icons.xyz)` — ikon bazlı
4. `find.text('...')` — yalnızca metin doğrulaması için

**Kurallar:**
- Fragile CSS selector gibi iç yapı sorgulama yapılmaz.
- `find.descendant` ve `find.ancestor` aşırı iç içe kullanımdan kaçınılır.
- Her kritik interaktif widget'a anlamlı `Key` atanır.

---

## 6) Async Test Güvenliği

```dart
// YANLIŞ: Zamana bağımlı test
testWidgets('...', (tester) async {
  await Future.delayed(Duration(seconds: 2)); // yasak
  expect(...);
});

// DOĞRU: pump ile kontrollü ilerleme
testWidgets('...', (tester) async {
  await tester.pump(const Duration(milliseconds: 800));
  expect(...);
});
```

- `Future.delayed` test dosyalarında kullanılmaz.
- Animasyon testi için `tester.pump(duration)` kullanılır.
- Stream aboneliği testleri `FakeAsync` ile zaman kontrolü yapılır.

---

## 7) Mock Kuralları

```dart
// mockito ile
@GenerateNiceMocks([MockSpec<GameRepository>()])
void main() {}

// mocktail ile
class MockGameRepository extends Mock implements GameRepository {}
```

- Mock'lar `test/helpers/` klasöründe merkezi tutulur.
- Her test dosyasında kendi mock'unu tanımlamaz; paylaşılan mock'ları import eder.
- Mock setup `setUp()`'ta; cleanup `tearDown()`'da yapılır.

---

## 8) Test İsimlendirme Standardı

- Test isimleri davranış odaklı, Türkçe veya İngilizce tutarlı yazılır.
- Gruplar `group()` veya `testWidgets('...', ...)` ile feature/sayfa bazında organize edilir.

```dart
group('VotingPanel', () {
  testWidgets('oy kullanılmadan önce 3 buton aktif olmalı', ...);
  testWidgets('oy kullandıktan sonra butonlar pasif olmalı', ...);
  testWidgets('süre bitince panel kapanmalı', ...);
});
```

---

## 9) Puan ve Oyun Mantığı Testleri

Sunucu mantığını simüle eden kritik birim testler zorunludur:

```dart
group('Ceza Formülü', () {
  test('ilk pas: -50 puan', () {
    expect(calculatePenalty(basePenalty: 50, passStreak: 0), -50);
  });
  test('ikinci pas: -150 puan', () {
    expect(calculatePenalty(basePenalty: 50, passStreak: 1), -150);
  });
  test('üçüncü pas: -450 puan', () {
    expect(calculatePenalty(basePenalty: 50, passStreak: 2), -450);
  });
});

group('Puan Hesaplama', () {
  test('tam beğeni oyu + x2 çarpan = 2x puan', () {
    expect(calculateScore(voteResult: 1.0, multiplier: 2), 200);
  });
});
```

---

## 10) Entegrasyon Test (E2E) Kuralları

- Gerçek Firebase Emulator Suite kullanılır (production'a dokunulmaz).
- Her test kendi test ortamını kurar ve temizler.
- `integration_test` paketi ile Flutter driver entegrasyonu yapılır.
- Unique oda kodları `'test-room-${DateTime.now().millisecondsSinceEpoch}'` ile üretilir.

---

## 11) CI Kuralları

- Her PR'de `flutter test` komutu çalışır.
- Test coverage eşiği: **%70 minimum** (kritik oyun mantığı için **%90**).
- Widget testleri smoke test olarak her build'de çalışır.
- Failed test PR merge'i engeller.

---

## 12) Yasak Anti-Pattern'ler

Asla şunlara izin verilmez:

- `Future.delayed()` test dosyalarında
- Gerçek Firebase/Supabase bağlantısı birim ve widget testlerinde
- Test dosyasında tekrarlanan login/auth akışı (fixture/helper kullan)
- Global mutable değişken testler arası paylaşımı
- Sıra bağımlı testler
- Tek test içinde birden fazla bağımsız özellik testi
- Stale locator / widget finder tekrar kullanımı farklı pump'lardan sonra

Yanlış yazılmış bir test varsa yeniden yaz.
