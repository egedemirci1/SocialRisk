# Oyun Bitiş Akışı – Scriptler ve Açıklama Prompt'u

## 1. Konuyu Açıklayan Prompt (AI / dokümantasyon için)

Aşağıdaki metni başka bir geliştiriciye veya AI asistanına vererek bu konuyu özetleyebilirsin:

---

**Sosyal Risk oyununda oyun bitişi ve ekran geçişleri**

Oyun durumu Firestore'da `game.status` ile tutuluyor: `playing`, `performing`, `voting`, `results`, `finished`.

**Normal turlar (son tur değil):**
- Oylama bitince backend `setRoundResult` ile status = `results` yapar.
- Her iki oyuncu da (host + client) `results` görünce **tur bitti ekranına** (round-result, `/round-result`) gider. Bu ekranda tur puanı ve sıralama gösterilir.
- Host "SIRADAKİ GÖREV"e basınca `nextTurn` çağrılır, status tekrar `playing` olur ve oyun devam eder.

**Son tur:**
- Son turda **tur bitti ekranı gösterilmez** (sıralama zaten game-over'da olacağı için gereksiz).
- `GameEndUtils.shouldEndAfterRound(game, room, players)` ile "bu tur sonunda oyun bitecek mi?" kararı verilir (round limiti veya skor hedefi).
- Oylama bitince yine `setRoundResult` → status = `results`. Ama `shouldEnd == true` ise:
  - **Voting screen:** ref.listen ve build içinde `results` görünce round-result'a **gitme** (return / navigate etme).
  - **Performing screen:** Aynı şekilde son turda round-result'a gitme.
  - Sadece **host** `_processResults` içinde `endGame(gameId)` çağırır → status = `finished`.
  - Host, `endGame` bittikten hemen sonra `context.go('/game-over', extra: roomCode)` ile **doğrudan** game-over'a gider (stream gecikmesine güvenilmez).
  - Client, Firestore'dan `finished` status'ünü alınca ref.listen ile game-over'a gider.

**Özet kurallar:**
- `results` + `!shouldEndAfterRound` → herkes `/round-result` (tur bitti).
- `results` + `shouldEndAfterRound` → kimse round-result'a gitmez; host `endGame` çağırır ve kendini game-over'a atar, client `finished` ile game-over'a gider.
- `finished` → her ekranda ref.listen veya build içi kontrol ile `/game-over`.
- ref.listen sadece **build()** içinde kullanılmalı (Riverpod kuralı); postFrameCallback veya initState içinde ref.listen çağrılmaz.

---

## 2. Mevcut Scriptler (ilgili kod parçaları)

### 2.1 GameEndUtils – Son tur kararı

**Dosya:** `lib/features/game/domain/game_end_utils.dart`

```dart
import '../../room/domain/room_entity.dart';
import 'game_entity.dart';
import '../../../shared/models/enums.dart';

/// Tek noktadan "oyun bu tur sonunda bitmeli mi?" kararını verir.
class GameEndUtils {
  static bool shouldEndAfterRound({
    required GameEntity game,
    required RoomEntity room,
    required List<PlayerEntity> players,
  }) {
    if (room.endConditionType == EndConditionType.rounds) {
      final activePlayerIds = players.map((p) => p.id).toSet();
      final orderSource = game.mode == GameMode.economy
          ? game.categoryPickOrder
          : game.turnOrder;
      final activeOrder =
          orderSource.where((id) => activePlayerIds.contains(id)).toList();
      final roundPlayerId = game.lastRoundPlayerId ?? game.currentPlayerId;
      final isLastActive = activeOrder.isNotEmpty && activeOrder.last == roundPlayerId;
      return game.currentRound >= room.endConditionValue && isLastActive;
    }

    return players.any((p) => p.score >= room.endConditionValue);
  }
}
```

---

### 2.2 Voting Screen – Oylama bitişi ve yönlendirme

**Dosya:** `lib/features/voting/presentation/voting_screen.dart`

**ref.listen (build içinde):**  
- `results` + shouldEnd → round-result'a gitme (return).  
- `results` + !shouldEnd → `context.go('/round-result', ...)`.  
- `finished` → `context.go('/game-over', extra: roomCode)`.

**Build body (gameAsync.when data):**  
- `game.status == results` + !shouldEnd → addPostFrameCallback ile round-result'a git.  
- `game.status == finished` → addPostFrameCallback ile game-over'a git.

**_processResults (sadece host çalıştırır):**  
- `applyScore` → setRoundResult (status = results).  
- latestGame/latestRoom/latestPlayers ile shouldEnd hesapla (rounds + score koşulları).  
- **shouldEnd ise:** `endGame(gameId)` çağır, ardından `context.go('/game-over', extra: widget.roomCode)` (host’u hemen game-over’a at).

```dart
// _processResults içinde (özet)
await ref.read(gameControllerProvider.notifier).applyScore(...);

final latestGame = ref.read(watchGameProvider(widget.gameId)).value;
final latestRoom = ref.read(watchRoomProvider(widget.roomCode)).value;
final latestPlayers = ref.read(watchPlayersProvider(widget.roomCode)).value ?? [];
if (latestGame != null && latestRoom != null) {
  var shouldEnd = GameEndUtils.shouldEndAfterRound(
    game: latestGame,
    room: latestRoom,
    players: latestPlayers,
  );
  if (!shouldEnd && latestRoom.endConditionType == EndConditionType.score) {
    // skor hedefi kontrolü...
  }
  if (shouldEnd) {
    await ref.read(gameControllerProvider.notifier).endGame(widget.gameId);
    if (mounted) {
      context.go('/game-over', extra: widget.roomCode);
    }
  }
}
```

```dart
// ref.listen (build içinde)
if (currentStatus == GameStatus.results) {
  final game = next.value;
  final room = ref.read(watchRoomProvider(widget.roomCode)).value;
  final players = ref.read(watchPlayersProvider(widget.roomCode)).value ?? [];
  if (game != null && room != null &&
      GameEndUtils.shouldEndAfterRound(game: game, room: room, players: players)) {
    return; // son tur: round-result'a gitme
  }
  context.go('/round-result', extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode});
} else if (currentStatus == GameStatus.finished) {
  context.go('/game-over', extra: widget.roomCode);
}
```

---

### 2.3 Performing Screen – Gösteri ekranından yönlendirme

**Dosya:** `lib/features/game/presentation/performing_screen.dart`

**ref.listen:**  
- `results` + !shouldEnd → addPostFrameCallback ile `/round-result`.  
- `results` + shouldEnd → hiçbir şey (return).  
- `finished` → addPostFrameCallback ile `/game-over`.  
- `voting` (ve sıra bende değilse) → `/voting`.

**Build body (gameAsync.when data):**  
- `game.status == results` + !shouldEnd → addPostFrameCallback ile round-result.  
- `game.status == results` + shouldEnd → sadece spinner dön, yönlendirme yok.  
- `game.status == finished` → addPostFrameCallback ile game-over.

```dart
// ref.listen içinde results/finished kısmı
if (game.status == GameStatus.results) {
  final room = ref.read(watchRoomProvider(widget.roomCode)).value;
  final players = ref.read(watchPlayersProvider(widget.roomCode)).value ?? [];
  final shouldEnd = room != null &&
      GameEndUtils.shouldEndAfterRound(game: game, room: room, players: players);
  if (!shouldEnd) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go('/round-result', extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode});
      }
    });
  }
  return;
}
if (game.status == GameStatus.finished) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) context.go('/game-over', extra: widget.roomCode);
  });
  return;
}
```

---

### 2.4 Round Result Screen – Tur bitti / parti bitti

**Dosya:** `lib/features/game/presentation/round_result_screen.dart`

**ref.listen:**  
- `playing` veya `choosingDifficulty` → `/task`.  
- `finished` → `/game-over`.

**İçerik:**  
- `isGameOver = (game.status == finished) || GameEndUtils.shouldEndAfterRound(...)`.  
- Host: isGameOver ise "PARTİ BİTTİ" → `endGame(gameId)`; değilse "SIRADAKİ GÖREV" → `nextTurn(gameId)`.  
- Client: Bekleme mesajı (spinner).

```dart
// ref.listen
if (currentStatus == GameStatus.playing || currentStatus == GameStatus.choosingDifficulty) {
  context.go('/task', extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode});
} else if (currentStatus == GameStatus.finished) {
  context.go('/game-over', extra: widget.roomCode);
}
```

```dart
// _buildActionButtons (host)
if (isGameOver) {
  await ref.read(gameControllerProvider.notifier).endGame(widget.gameId);
} else {
  await ref.read(gameControllerProvider.notifier).nextTurn(widget.gameId);
}
```

---

## 3. Kısa Akış Özeti

| Durum | Kim | Ne yapılır |
|--------|-----|------------|
| Oylama bitti, son tur değil | Backend | setRoundResult → status = results |
| results, !shouldEnd | Her iki oyuncu | round-result'a git |
| results, shouldEnd | Host | endGame + context.go game-over |
| results, shouldEnd | Client | Hiçbir yere gitme; finished gelince game-over |
| finished | Her ekran | ref.listen/build ile game-over'a git |

Bu dosyayı referans alarak aynı akışı koruyacak şekilde değişiklik yapabilir veya yeni ekranlar ekleyebilirsin.

---

## 4. Güncel Yapı ve Çözülen Problem – Tek Prompt (AI / yeni geliştirici için)

Aşağıdaki metni kopyalayıp başka bir AI asistanına veya geliştiriciye vererek hem mevcut yapıyı hem de çözülen izin problemini özetleyebilirsin:

---

**Sosyal Risk – Oyun bitişi, ödül dağıtımı ve Firestore izinleri**

**Mevcut yapı**

- Oyun durumu Firestore’da `games/{gameId}` içinde `status` ile tutuluyor: `playing`, `performing`, `voting`, `results`, `finished`.
- **Oylama bitince** tek noktada `GameController.applyScore` çalışıyor. Bu metot `watchGame`, `watchRoom`, `watchPlayers` ile güncel oyun/oda/oyuncu verisini alıp `GameEndUtils.shouldEndAfterRound(...)` ile “bu tur sonunda oyun bitecek mi?” kararını veriyor. Ardından **tek çağrıda** `GameRepository.setRoundResult(..., shouldEndGame: shouldEnd)` çağrılıyor.
- **setRoundResult (FirebaseGameSource):** Tek transaction’da:
  - Önce oyuncu skorları `rooms/{roomId}/players/{playerId}` üzerinden okunuyor (read).
  - Sonra tek `transaction.update` ile: oyuncu skoru güncelleniyor, game dokümanında `status` (`results` veya `finished`), `lastRound*` alanları ve gerekirse `rewards` map’i yazılıyor. **Ödül dağıtımı artık transaction içinde `users` koleksiyonuna yazmıyor.** Son turda (`shouldEndGame: true`) ödüller sadece `game.rewards` (Map<String, int>: `userId → puan`) olarak game dokümanına yazılıyor.
- **nextTurn (tur limitiyle bitiş):** Tur sayısı dolunca oyun bittiğinde yine `users`’a yazılmıyor; `rewards` map’i game dokümanına yazılıp `status: finished` yapılıyor.
- **UI yönlendirme:** Ekranlarda (voting, performing, round-result, difficulty-choice) `ref.listen` **sadece build içinde** kullanılıyor. Davranış: `game.status == results` → `/round-result`, `game.status == finished` → `/game-over`. Bitiş kararı UI’da değil, `applyScore` / `setRoundResult` tarafında verildiği için son turda backend doğrudan `status: finished` yazıyor; client da `finished` görünce game-over’a gidiyor.
- **Ödülü cüzdana aktarma (claim):** Her oyuncu **game-over ekranına** geldiğinde bir kez `claimGameReward(gameId, userId)` çağrılıyor. Bu metot sadece **kendi** `users/{userId}` dokümanına yazar: game dokümanından `rewards[userId]` okunur, `lastClaimedGameId != gameId` ise `walletPoints` artırılır ve `lastClaimedGameId = gameId` yazılır. Böylece tek bir kullanıcı sadece kendi user dokümanını günceller; Firestore kurallarıyla uyumludur.
- **Model:** `GameEntity` / `GameModel` içinde `rewards` alanı var (Map<String, int>, varsayılan `const {}`). Firestore’dan okurken sayılar `int`/`num` uyumlu parse ediliyor.

**Çözülen problem**

- **“Sonuçlar kaydedilirken hata” / “Missing or insufficient permissions”:** Önceden oyun bitişinde (setRoundResult veya nextTurn) transaction/batch içinde **birden fazla oyuncunun** `users/{playerId}` dokümanına ödül yazılıyordu. Firestore güvenlik kuralları genelde sadece `request.auth.uid == userId` ile kullanıcının kendi `users/{userId}` dokümanına yazmasına izin verir. Sunucu tarafında veya tek bir client’tan diğer kullanıcıların `users` dokümanlarına yazmaya çalışınca izin hatası oluşuyordu.
- **Çözüm:** (1) Oyun bitişinde ödül dağıtımı **transaction/batch içinde users’a yazmayı bıraktık**; ödüller sadece `game.rewards` olarak game dokümanına yazılıyor. (2) Her oyuncu kendi ödülünü **game-over ekranında** `claimGameReward` ile alıyor; bu metot yalnızca `users/{userId}` dokümanına yazdığı için izin hatası oluşmuyor.

**Dikkat**

- **endGame:** Round-result ekranında host “PARTİ BİTTİ”e basınca çağrılan `endGame(gameId)` hâlâ batch ile **tüm** oyuncuların `users` dokümanlarına yazıyor. Bu path genelde son turda `setRoundResult(..., shouldEndGame: true)` ile zaten `finished` yazıldığı için az kullanılsa da, bu path tetiklenirse aynı “Missing or insufficient permissions” hatası oluşabilir. İleride `endGame` de sadece `status: finished` (ve gerekirse `rewards`’ı game’e yazma) yapacak şekilde güncellenip, ödül dağıtımı tamamen `claimGameReward`’a bırakılabilir.

---
