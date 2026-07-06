import re
from pathlib import Path

path = Path('lib/features/game/data/firebase_game_source.dart')
text = path.read_text(encoding='utf-8')
marker = '  @override\n  Future<void> setRoundResult'
idx = text.index(marker)
head = text[:idx].rstrip() + '\n'
tail = text[idx:]

chunks = tail.split('  @override\n')[1:]  # skip empty first
methods = ['  @override\n' + c for c in chunks]
# last chunk includes closing `}` of class - trim
methods[-1] = methods[-1].rsplit('\n}', 1)[0]

fn_parts = []
wrapper_parts = []

for block in methods:
    name_m = re.search(
        r'(?:Future<[^>]+>|bool) (\w+)\(', block
    )
    if not name_m:
        raise SystemExit(f'Cannot parse: {block[:120]}...')
    name = name_m.group(1)
    fn_name = '_fgs' + name[0].upper() + name[1:]

    async_idx = block.index(' async {')
    sig = block[: async_idx + len(' async')]
    body = block[async_idx + len(' async {'):].rstrip()

    ret_line = [ln.strip() for ln in sig.splitlines() if ln.strip() and not ln.strip().startswith('@')][0]
    ret = ret_line.rsplit(name, 1)[0].strip()
    params = sig.split(name, 1)[1].strip()
    sig_fn = f'{ret} {fn_name}(FirebaseGameSource source{params}'

    body = (
        body.replace('_gameDoc(', 'source._gameDoc(')
        .replace('_firestore', 'source._firestore')
        .replace('_random', 'source._random')
        .replace('_gamesRef', 'source._gamesRef')
        .replace('_pickEconomyHotCategory(', 'source._pickEconomyHotCategory(')
    )
    fn_parts.append(f'{sig_fn} {{\n{body}\n}}\n')

    call_params = params[1:-1].strip()  # inside parens
    if call_params.startswith('{'):
        wrapper_parts.append(
            f'  @override\n  {ret} {name}{params} async =>\n      {fn_name}(this, {call_params});'
        )
    else:
        wrapper_parts.append(
            f'  @override\n  {ret} {name}{params} async =>\n      {fn_name}(this, {call_params});'
        )

part_path = path.parent / 'firebase_game_source.round.part.dart'
part_path.write_text(
    "part of 'firebase_game_source.dart';\n\n" + '\n'.join(fn_parts),
    encoding='utf-8',
)

new_main = head + '\n'.join(wrapper_parts) + '\n}\n'
new_main = new_main.replace(
    "import '../../../core/constants/game_constants.dart';\n\nclass",
    "import '../../../core/constants/game_constants.dart';\n\npart 'firebase_game_source.round.part.dart';\n\nclass",
)
path.write_text(new_main, encoding='utf-8')
names = [re.search(r'(?:Future<[^>]+>|bool) (\w+)', m).group(1) for m in methods]
print(f'Split {len(methods)} methods: {names}')
