from pathlib import Path

p = Path('lib/features/game/data/firebase_game_source.dart')
t = p.read_text(encoding='utf-8')
a_start = t.index('  @override\n  Future<void> assignTaskByCategory')
a_end = t.index('  @override\n  Future<void> chooseDifficulty')
pass_start = t.index('  @override\n  Future<void> passTask')
pass_end = t.index('  @override\n  Future<void> setRoundResult')
assign_body = t[a_start:a_end].split('async {', 1)[1].rsplit('  }\n\n', 1)[0]
pass_body = t[pass_start:pass_end].split('async {', 1)[1].rsplit('  }\n\n', 1)[0]


def qual(body: str) -> str:
    for name in (
        '_pickEconomyHotCategory',
        '_gameDoc',
        '_gamesRef',
        '_firestore',
        '_random',
    ):
        body = body.replace(name, f'source.{name}')
    return body


part = f"""part of 'firebase_game_source.dart';

Future<void> _fgsAssignTaskByCategory(
  FirebaseGameSource source, {{
  required String gameId,
  required String category,
}}) async {{
{qual(assign_body)}
}}

Future<void> _fgsPassTask(
  FirebaseGameSource source, {{
  required String gameId,
  required String roomId,
  required String playerId,
  required int basePenalty,
}}) async {{
{qual(pass_body)}
}}
"""
Path('lib/features/game/data/firebase_game_source.heavy.part.dart').write_text(
    part,
    encoding='utf-8',
)

new_t = (
    t[:a_start]
    + """  @override
  Future<void> assignTaskByCategory({
    required String gameId,
    required String category,
  }) =>
      _fgsAssignTaskByCategory(this, gameId: gameId, category: category);

"""
    + t[a_end:pass_start]
    + """  @override
  Future<void> passTask({
    required String gameId,
    required String roomId,
    required String playerId,
    required int basePenalty,
  }) =>
      _fgsPassTask(
        this,
        gameId: gameId,
        roomId: roomId,
        playerId: playerId,
        basePenalty: basePenalty,
      );

"""
    + t[pass_end:]
)
needle = "import '../../../core/constants/game_constants.dart';\n\nclass"
replacement = (
    "import '../../../core/constants/game_constants.dart';\n\n"
    "part 'firebase_game_source.heavy.part.dart';\n\nclass"
)
new_t = new_t.replace(needle, replacement)
p.write_text(new_t, encoding='utf-8')
print('main', len(new_t.splitlines()), 'part', len(part.splitlines()))
