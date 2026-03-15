# Oyun Bitişi ve Skor Hesaplama Mantığı - Mevcut Durum Analizi

## 1. Oyunun Bitip Bitmediğine Nerede ve Nasıl Karar Veriliyor?

### 1.1. `applyScore` Fonksiyonu

**Konum:** `lib/features/game/providers/game_provider.dart`

```73:90:lib/features/game/providers/game_provider.dart
  /// Tur sonucunu yazar. Bitiş kararı Cloud Function'da verilir; istemci sadece status = 'results' yazar.
  Future<void> applyScore({
    required String gameId,
    required String roomId,
    required String playerId,
    required int scoreToAdd,
    required int audienceScore,
    required int taskMultiplier,
  }) async {
    await ref.read(gameRepositoryProvider).setRoundResult(
          gameId: gameId,
          roomId: roomId,
          playerId: playerId,
          score: scoreToAdd,
          audienceScore: audienceScore,
          multiplier: taskMultiplier,
        );
  }
```

**Kullanım:** Voting ekranında oylama bittiğinde çağrılır:

```69:76:lib/features/voting/presentation/voting_screen.dart
      await ref.read(gameControllerProvider.notifier).applyScore(
            gameId: widget.gameId,
            roomId: widget.roomCode,
            playerId: currentPlayerId,
            scoreToAdd: earned,
            audienceScore: voteResult.audienceScore,
            taskMultiplier: taskMultiplier,
          );
```

### 1.2. `setRoundResult` Fonksiyonu

**Konum:** `lib/features/game/data/firebase_game_source.dart`

```210:270:lib/features/game/data/firebase_game_source.dart
  @override
  Future<void> setRoundResult({
    required String gameId,
    required String roomId,
    required String playerId,
    required int score,
    required int audienceScore,
    required int multiplier,
  }) async {
    try {
      final gameDocRef = _gameDoc(gameId);
      final playerDocRef = _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc(playerId);

      await _firestore.runTransaction((transaction) async {
        final gameSnap = await transaction.get(gameDocRef);
        if (!gameSnap.exists) return;
        final game = GameModel.fromJson(gameSnap.data()!, gameSnap.id);

        transaction.update(playerDocRef, {
          'score': FieldValue.increment(score),
        });

        final updates = <String, dynamic>{
          'status': 'results',
          'lastRoundScore': score,
          'lastRoundAudienceScore': audienceScore,
          'lastRoundMultiplier': multiplier,
          'lastRoundPlayerId': playerId,
        };

        // Ekonomi Modu: Sıra Değişimi Hazırlığı
        if (game.categoryPickOrder.isNotEmpty) {
          final nextPickIndex = game.currentPickIndex + 1;
          if (nextPickIndex >= game.categoryPickOrder.length) {
            updates['currentPickIndex'] = 0;
            updates['currentRound'] = game.currentRound + 1;
            updates['currentPlayerId'] = game.categoryPickOrder[0];
            final marketValues = Map<String, int>.from(game.categoryMarketValues);
            for (final k in marketValues.keys.toList()) {
              if ((marketValues[k] ?? 0) == 0) marketValues[k] = 10;
            }
            final atTen = marketValues.keys.where((c) => (marketValues[c] ?? 0) == 10).toList();
            updates['categoryMarketValues'] = marketValues;
            updates['hotCategory'] = atTen.isNotEmpty ? atTen[_random.nextInt(atTen.length)] : null;
          } else {
            updates['currentPickIndex'] = nextPickIndex;
            updates['currentPlayerId'] = game.categoryPickOrder[nextPickIndex];
          }
        }

        transaction.update(gameDocRef, updates);
      });
    } on FirebaseException catch (e) {
      throw Exception('Sonuçlar kaydedilirken hata oluştu: ${e.message}');
    } catch (e) {
      throw Exception('Sonuçlar kaydedilirken beklenmeyen hata: $e');
    }
  }
```

**Önemli:** Bu fonksiyon **her zaman** `status: 'results'` yazar. Bitiş kararı **Cloud Function** tarafında verilir.

### 1.3. `shouldEndGame` Hesaplaması (Cloud Function)

**Konum:** `functions/src/index.ts`

Cloud Function `onGameUpdated`, `status === 'results'` olduğunda tetiklenir ve bitiş koşulunu kontrol eder:

```27:89:functions/src/index.ts
export const onGameUpdated = functions.firestore
  .document("games/{gameId}")
  .onUpdate(async (change, context) => {
    const gameId = context.params.gameId as string;
    const after = change.after.data();
    const status = after?.status;

    if (status !== "results") return;

    const gameRef = change.after.ref;
    const roomId = after?.roomId as string | undefined;
    if (!roomId) return;

    const roomSnap = await db.collection("rooms").doc(roomId).get();
    if (!roomSnap.exists) return;
    const room = roomSnap.data() as RoomDoc;
    const endType = room?.endConditionType ?? "score";
    const endValue = room?.endConditionValue ?? 5000;

    const playersSnap = await db
      .collection("rooms")
      .doc(roomId)
      .collection("players")
      .get();

    const players: PlayerScore[] = playersSnap.docs.map((doc) => {
      const d = doc.data();
      const raw = d.score;
      const score =
        typeof raw === "number" ? Math.floor(raw) : parseInt(String(raw), 10) || 0;
      return { id: doc.id, score };
    });

    const turnOrder: string[] = Array.isArray(after?.turnOrder)
      ? after.turnOrder
      : [];
    const categoryPickOrder: string[] = Array.isArray(after?.categoryPickOrder)
      ? after.categoryPickOrder
      : [];
    const mode = after?.mode === "economy" ? "economy" : "classic";
    const orderSource =
      mode === "economy" && categoryPickOrder.length > 0
        ? categoryPickOrder
        : turnOrder;
    const activeOrder = orderSource.filter((id) =>
      players.some((p) => p.id === id)
    );
    const currentRound =
      typeof after?.currentRound === "number" ? after.currentRound : 1;
    const lastRoundPlayerId =
      (after?.lastRoundPlayerId ?? after?.currentPlayerId ?? "") as string;
    const isLastActive =
      activeOrder.length > 0 &&
      activeOrder[activeOrder.length - 1] === lastRoundPlayerId;

    let shouldEnd = false;
    if (endType === "rounds") {
      shouldEnd = currentRound >= endValue && isLastActive;
    } else {
      shouldEnd = players.some((p) => p.score >= endValue);
    }

    if (!shouldEnd) return;
```

**Bitiş Koşulları:**
- **Skor bazlı:** Herhangi bir oyuncunun skoru `endConditionValue`'ya ulaştığında
- **Tur bazlı:** `currentRound >= endConditionValue` ve son aktif oyuncu turunu tamamladığında

### 1.4. `nextTurn` İçinde Tur Limit Kontrolü

**Konum:** `lib/features/game/data/firebase_game_source.dart`

```306:318:lib/features/game/data/firebase_game_source.dart
        if (isNewRound) {
          final roomDocRef = _firestore.collection('rooms').doc(game.roomId);
          final roomSnap = await transaction.get(roomDocRef);
          if (roomSnap.exists) {
            final roomData = roomSnap.data()!;
            final endType = roomData['endConditionType'] as String?;
            final endVal = roomData['endConditionValue'] as int? ?? 10;
            if (endType == 'rounds' && game.currentRound >= endVal) {
              transaction.update(gameDocRef, {'status': 'results'});
              return;
            }
          }
        }
```

**Not:** Bu kontrol sadece tur limitini kontrol eder ve `status: 'results'` yazar. Asıl bitiş kararı Cloud Function'da verilir.

---

## 2. Oyun Statüsü (status: 'finished') Firestore'a Nerede ve Nasıl Yazılıyor?

### 2.1. Cloud Function Tarafından Otomatik Yazma

**Konum:** `functions/src/index.ts`

Cloud Function, bitiş koşulu sağlandığında `status: 'finished'` yazar:

```99:105:functions/src/index.ts
    batch.update(gameRef, {
      status: "finished",
      rewards,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
```

### 2.2. Manuel `endGame` Fonksiyonu

**Konum:** `lib/features/game/data/firebase_game_source.dart`

Host, round-result ekranında "PARTİ BİTTİ" butonuna basınca çağrılır:

```372:378:lib/features/game/data/firebase_game_source.dart
  @override
  Future<void> endGame(String gameId) async {
    final gameSnap = await _gameDoc(gameId).get();
    if (!gameSnap.exists) return;
    final game = GameModel.fromJson(gameSnap.data()!, gameSnap.id);
    if (game.status == 'finished') return;
    await _gameDoc(gameId).update({'status': 'finished'});
  }
```

**Kullanım:** Round-result ekranında host butonu:

```295:303:lib/features/game/presentation/round_result_screen.dart
            onPressed: () async {
              if (isGameOver) {
                await ref.read(gameControllerProvider.notifier).endGame(widget.gameId);
              } else {
                await ref
                    .read(gameControllerProvider.notifier)
                    .nextTurn(widget.gameId);
              }
            },
```

---

## 3. Ödül Sistemi Nasıl Çalışıyor?

### 3.1. `claimGameReward` Fonksiyonu

**Durum:** Projede `claimGameReward` fonksiyonu **bulunmuyor**. Ödüller otomatik olarak Cloud Function tarafından dağıtılıyor.

### 3.2. Otomatik Ödül Dağıtımı (Cloud Function)

**Konum:** `functions/src/index.ts`

Oyun bittiğinde (`status: 'finished'`), Cloud Function ödülleri hesaplayıp dağıtır:

```91:121:functions/src/index.ts
    const sorted = [...players].sort((a, b) => b.score - a.score);
    const rewards: Record<string, number> = {};
    sorted.forEach((p, i) => {
      if (p.score <= 0) return;
      rewards[p.id] =
        i < RANK_REWARDS.length ? RANK_REWARDS[i] : DEFAULT_REWARD;
    });

    const batch = db.batch();

    batch.update(gameRef, {
      status: "finished",
      rewards,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    for (const [userId, points] of Object.entries(rewards)) {
      if (points <= 0) continue;
      const userRef = db.collection("users").doc(userId);
      batch.set(
        userRef,
        {
          walletPoints: admin.firestore.FieldValue.increment(points),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    await batch.commit();
    functions.logger.info(`Game ${gameId} finished and rewards distributed.`);
```

**Ödül Sistemi:**
- 1. sıra: 200 puan
- 2. sıra: 100 puan
- 3. sıra: 50 puan
- Diğerleri: 20 puan
- Negatif skorlu oyuncular: 0 puan

### 3.3. Game Over Ekranında Ödül Gösterimi

**Konum:** `lib/features/game/presentation/game_over_screen.dart`

Game Over ekranı ödülü gösterir ama **claim işlemi yapmaz** (zaten Cloud Function tarafından yapılmış):

```68:77:lib/features/game/presentation/game_over_screen.dart
          final myPlayer = user != null
              ? sorted.where((p) => p.id == user.uid).firstOrNull
              : null;
          final myRank = user != null
              ? sorted.indexWhere((p) => p.id == user.uid) + 1
              : 0;
          final hasNegativeScore = myPlayer != null && myPlayer.score <= 0;
          final myReward = (myRank > 0 && !hasNegativeScore)
              ? rewardForRank(myRank, sorted.length)
              : 0;
```

**Not:** Eski bir Cloud Function (`functions/index.js` içindeki `onGameFinished`) de var ama bu sadece skorları `walletPoints`'e aktarıyor, ödül sistemi değil.

---

## 4. Kullanıcıları Sonuç Ekranına (Game Over UI) Yönlendiren Riverpod State Dinleyicisi

### 4.1. Round Result Ekranında Dinleyici

**Konum:** `lib/features/game/presentation/round_result_screen.dart`

```57:74:lib/features/game/presentation/round_result_screen.dart
    ref.listen<AsyncValue<GameEntity?>>(
      watchGameProvider(widget.gameId),
      (previous, next) {
        if (!context.mounted) return;
        final prevStatus = previous?.value?.status;
        final currentStatus = next.value?.status;

        if (currentStatus == GameStatus.playing ||
            currentStatus == GameStatus.choosingDifficulty) {
          context.go(
            '/task',
            extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
          );
        } else if (currentStatus == GameStatus.finished && prevStatus != GameStatus.finished) {
          context.go('/game-over', extra: widget.roomCode);
        }
      },
    );
```

### 4.2. Voting Ekranında Dinleyici

**Konum:** `lib/features/voting/presentation/voting_screen.dart`

```103:118:lib/features/voting/presentation/voting_screen.dart
    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
      previous,
      next,
    ) {
      if (!mounted) return;
      final prevStatus = previous?.value?.status;
      final currentStatus = next.value?.status;
      if (currentStatus == GameStatus.results && prevStatus != GameStatus.results) {
        context.go(
          '/round-result',
          extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
        );
      } else if (currentStatus == GameStatus.finished && prevStatus != GameStatus.finished) {
        context.go('/game-over', extra: widget.roomCode);
      }
    });
```

### 4.3. Waiting Ekranında Dinleyici

**Konum:** `lib/features/game/presentation/waiting_screen.dart`

```61:109:lib/features/game/presentation/waiting_screen.dart
    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
      previous,
      next,
    ) {
      if (!mounted) return;

      if (next.hasError || (next.hasValue && next.value == null)) {
        // Oyun silinmiş veya hata oluşmuş (Muhtemelen host çıktığı için)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ToastUtils.showError(context, 'Oyun sona erdi veya ev sahibi ayrıldı.');
            context.go('/home');
          }
        });
        return;
      }

      final nextGame = next.value;
      if (nextGame != null && previous?.value?.status != nextGame.status) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (nextGame.status == GameStatus.finished) {
              context.replace('/game-over', extra: widget.roomCode);
            } else if (nextGame.status == GameStatus.voting) {
              context.replace(
                '/voting',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            } else if (nextGame.status == GameStatus.results) {
              context.replace(
                '/round-result',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            } else if (nextGame.status == GameStatus.playing ||
                nextGame.status == GameStatus.choosingDifficulty) {
              // Tüm oyuncular task ekranına yönlendirilir
              context.replace(
                '/task',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            } else if (nextGame.status == GameStatus.performing) {
              context.replace(
                '/performing',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            }
          }
        });
      }
    });
```

### 4.4. Diğer Ekranlarda Benzer Dinleyiciler

- **Task Screen:** `lib/features/game/presentation/task_screen.dart`
- **Performing Screen:** `lib/features/game/presentation/performing_screen.dart`
- **Difficulty Choice Screen:** `lib/features/game/presentation/difficulty_choice_screen.dart`
- **Economy Pick Screen:** `lib/features/game/presentation/economy_pick_screen.dart`

**Mantık:** Tüm ekranlarda `ref.listen` ile `watchGameProvider` dinlenir. `status` değiştiğinde:
- `GameStatus.finished` → `/game-over` ekranına yönlendirilir
- `GameStatus.results` → `/round-result` ekranına yönlendirilir
- Diğer durumlar → İlgili ekranlara yönlendirilir

---

## Özet Akış Diyagramı

```
1. Oylama Biter
   ↓
2. VotingScreen._processResults() çağrılır
   ↓
3. GameController.applyScore() → setRoundResult()
   ↓
4. setRoundResult() → status: 'results' yazar
   ↓
5. Cloud Function onGameUpdated tetiklenir
   ↓
6. Cloud Function bitiş koşulunu kontrol eder
   ├─ Koşul sağlanmazsa → return (oyun devam eder)
   └─ Koşul sağlanırsa → status: 'finished' + ödüller dağıtılır
   ↓
7. Firestore'da status: 'finished' değişikliği
   ↓
8. Tüm ekranlardaki ref.listen() tetiklenir
   ↓
9. context.go('/game-over') ile Game Over ekranına yönlendirilir
```

---

## Önemli Notlar

1. **Bitiş kararı istemci tarafında değil, Cloud Function tarafında verilir.** Bu, güvenlik ve tutarlılık için kritiktir.

2. **Ödül sistemi otomatiktir.** `claimGameReward` gibi bir fonksiyon yok; Cloud Function oyun bittiğinde otomatik olarak ödülleri dağıtır.

3. **İki farklı Cloud Function var:**
   - `functions/src/index.ts` → `onGameUpdated`: Bitiş kararı verir ve ödülleri dağıtır
   - `functions/index.js` → `onGameFinished`: Sadece skorları `walletPoints`'e aktarır (eski sistem)

4. **Tüm ekranlar Riverpod `ref.listen` ile game status değişikliklerini dinler** ve otomatik olarak ilgili ekranlara yönlendirir.
