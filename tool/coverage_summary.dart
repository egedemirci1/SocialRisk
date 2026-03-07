/// Coverage raporunu okur ve toplam / dosya bazlı yüzde gösterir.
/// Kullanım: dart run tool/coverage_summary.dart
/// Önce: flutter test test/unit test/widgets test/widget --coverage

import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('coverage/lcov.info bulunamadı.');
    print('Önce şunu çalıştır: flutter test test/unit test/widgets test/widget --coverage');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  int totalLF = 0;
  int totalLH = 0;
  String? currentSF;
  int? fileLF;
  int? fileLH;
  final perFile = <String, ({int hit, int found})>{};

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentSF = line.substring(3).replaceAll(r'\', '/');
      fileLF = null;
      fileLH = null;
    } else if (line.startsWith('LF:')) {
      fileLF = int.tryParse(line.substring(3)) ?? 0;
    } else if (line.startsWith('LH:')) {
      fileLH = int.tryParse(line.substring(3)) ?? 0;
    } else if (line == 'end_of_record' && currentSF != null && fileLF != null && fileLH != null) {
      totalLF += fileLF;
      totalLH += fileLH;
      if (!currentSF.contains('generated') && !currentSF.contains('.g.dart')) {
        perFile[currentSF] = (hit: fileLH, found: fileLF);
      }
      currentSF = null;
    }
  }

  final pct = totalLF > 0 ? (100.0 * totalLH / totalLF) : 0.0;
  print('═══════════════════════════════════════');
  print('  TOPLAM SATIR KAPSAMI');
  print('  $totalLH / $totalLF satır  →  ${pct.toStringAsFixed(1)}%');
  print('═══════════════════════════════════════');

  final libEntries = perFile.entries.where((e) => e.key.contains('lib/')).toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  print('\nDosya bazlı (lib/):\n');
  for (final e in libEntries) {
    final name = e.key.length > 60 ? '...${e.key.substring(e.key.length - 57)}' : e.key;
    final fpct = e.value.found > 0 ? (100.0 * e.value.hit / e.value.found) : 0.0;
    final bar = _bar(fpct);
    print('${fpct.toStringAsFixed(0).padLeft(3)}% $bar $name');
  }
}

String _bar(double pct) {
  const width = 12;
  final filled = (pct / 100 * width).round().clamp(0, width);
  final hashes = List.filled(filled, '#').join();
  return '[$hashes${' '.padRight(width - filled)}]';
}
