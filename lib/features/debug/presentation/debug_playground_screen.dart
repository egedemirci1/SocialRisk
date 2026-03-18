import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/cards/game_card.dart';
import '../../../shared/widgets/score/leaderboard_tile.dart';

enum _DebugScene { task, difficulty, leaderboard, gameOver }

class DebugPlaygroundScreen extends StatefulWidget {
  const DebugPlaygroundScreen({super.key});

  @override
  State<DebugPlaygroundScreen> createState() => _DebugPlaygroundScreenState();
}

class _DebugPlaygroundScreenState extends State<DebugPlaygroundScreen> {
  _DebugScene _scene = _DebugScene.task;
  int _playerCount = 8;
  bool _useLongQuestion = true;
  bool _useLongNames = false;

  static const String _shortTask =
      'Takimca tek kelimelik ipuclari kullanarak gizli nesneyi bul.';
  static const String _longTask =
      'Grup arkadaslarin kendi aralarinda gizli bir "nesne" belirlesin. Toplam 8 ipucu hakkiniz var. Herkes sadece 1 kelimelik bir ipucu versin. Kelimeyi bilirsen kazanirsin.';

  List<_MockPlayer> get _players {
    final baseNames = _useLongNames
        ? const [
            'Aleyna Yildiz',
            'Berkay Uzunsoy',
            'Cansu Karaduman',
            'Deniz Ekinci',
            'Ece Nur Aydin',
            'Furkan Tuncer',
            'Gizem Nur Kaya',
            'Hasan Emre Demir',
          ]
        : const ['Ata', 'Reze', 'Mina', 'Can', 'Ece', 'Lara', 'Mert', 'Selin'];

    return List.generate(_playerCount, (index) {
      return _MockPlayer(
        name: baseNames[index % baseNames.length],
        score: max(10, 80 - (index * 7)),
        isCurrentPlayer: index == 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Debug Playground',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final controls = _buildControlsCard();
            final preview = _buildPreviewPanel();

            if (wide) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    SizedBox(width: 300, child: controls),
                    const SizedBox(width: 20),
                    Expanded(child: preview),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  controls,
                  const SizedBox(height: 12),
                  Expanded(child: preview),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlsCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Önizleme',
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu ekran sahte veriyle hizli responsive test yapmak icin var. Route: /debug-playground',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _DebugScene.values.map((scene) {
                final selected = _scene == scene;
                return ChoiceChip(
                  label: Text(_sceneLabel(scene)),
                  selected: selected,
                  onSelected: (_) => setState(() => _scene = scene),
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    color: selected ? AppColors.background : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.surfaceElevated,
                  side: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.25),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Oyuncu sayisi',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white54,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [2, 4, 6, 8].map((count) {
                final selected = _playerCount == count;
                return ChoiceChip(
                  label: Text('$count kişi'),
                  selected: selected,
                  onSelected: (_) => setState(() => _playerCount = count),
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    color: selected ? AppColors.background : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceElevated,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _useLongQuestion,
              onChanged: (value) => setState(() => _useLongQuestion = value),
              activeColor: AppColors.accent,
              title: Text(
                'Uzun görev metni',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              subtitle: Text(
                'Task ekraninda font sikismasini test et',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _useLongNames,
              onChanged: (value) => setState(() => _useLongNames = value),
              activeColor: AppColors.accent,
              title: Text(
                'Uzun oyuncu isimleri',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              subtitle: Text(
                'Leaderboard ve game over satirlarini test et',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
            if (_scene == _DebugScene.leaderboard) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: StageButton(
                  label: 'Bottom Sheet Ac',
                  icon: Icons.view_agenda_rounded,
                  backgroundColor: AppColors.accent,
                  textColor: AppColors.background,
                  borderColor: Colors.transparent,
                  compact: true,
                  onPressed: _showMockScoreboardSheet,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.background),
            child: switch (_scene) {
              _DebugScene.task => _TaskPreview(
                taskText: _useLongQuestion ? _longTask : _shortTask,
              ),
              _DebugScene.difficulty => const _DifficultyPreview(),
              _DebugScene.leaderboard => _LeaderboardPreview(players: _players),
              _DebugScene.gameOver => _GameOverPreview(players: _players),
            },
          ),
        ),
      ),
    );
  }

  void _showMockScoreboardSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MockScoreboardBottomSheet(players: _players),
    );
  }

  String _sceneLabel(_DebugScene scene) {
    switch (scene) {
      case _DebugScene.task:
        return 'Task';
      case _DebugScene.difficulty:
        return 'Difficulty';
      case _DebugScene.leaderboard:
        return 'Leaderboard';
      case _DebugScene.gameOver:
        return 'Game Over';
    }
  }
}

class _TaskPreview extends StatelessWidget {
  const _TaskPreview({required this.taskText});

  final String taskText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = _TaskPreviewMetrics.from(constraints);

          return Center(
            child: SizedBox(
              width: layout.contentWidth,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
                child: Column(
                  children: [
                    SizedBox(height: layout.topGap),
                    SizedBox(
                      height: layout.topBarHeight,
                      child: const Row(
                        children: [
                          _TopIconButton(icon: Icons.logout_rounded),
                          Spacer(),
                          _PillLabel(
                            label: '2. Tur (Hedef: 500 Puan)',
                            fontSize: 13,
                          ),
                          Spacer(),
                          _TopIconButton(icon: Icons.equalizer_rounded),
                        ],
                      ),
                    ),
                    SizedBox(height: layout.sectionGap),
                    _SectionCard(
                      header: 'PARTI BASLIYOR',
                      body: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: layout.innerPadding,
                          vertical: layout.innerPadding,
                        ),
                        child: Column(
                          children: [
                            _PillLabel(
                              label: 'Kategori: Zihinsel',
                              fontSize: layout.categoryFontSize,
                            ),
                            SizedBox(height: layout.innerGap),
                            _InnerInfoCard(fontSize: layout.infoFontSize),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: layout.sectionGap),
                    Expanded(
                      child: GameCard(
                        category: 'Zihinsel',
                        content: taskText,
                        points: 10,
                        compact: layout.compact,
                      ),
                    ),
                    SizedBox(height: layout.sectionGap),
                    SizedBox(
                      width: double.infinity,
                      child: StageButton(
                        label: 'Görevi Başlat',
                        backgroundColor: AppColors.accent,
                        textColor: AppColors.background,
                        borderColor: Colors.transparent,
                        onPressed: () {},
                        compact: layout.compact,
                      ),
                    ),
                    SizedBox(height: layout.buttonGap),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          foregroundColor: Colors.white70,
                          minimumSize: Size.fromHeight(
                            layout.compact ? 42 : 48,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Görevi Reddet (-50 Puan)',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: layout.bottomGap),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DifficultyPreview extends StatelessWidget {
  const _DifficultyPreview();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = _DifficultyPreviewMetrics.from(constraints);

          return Center(
            child: SizedBox(
              width: layout.contentWidth,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
                child: Column(
                  children: [
                    SizedBox(height: layout.topGap),
                    SizedBox(
                      height: layout.categoryHeight,
                      child: Center(
                        child: _PillLabel(
                          label: 'Kategori: Gorsel',
                          fontSize: layout.categoryFontSize,
                        ),
                      ),
                    ),
                    SizedBox(height: layout.sectionGap),
                    SizedBox(
                      height: layout.heroHeight,
                      child: _SectionCard(
                        header: 'Zorluk Seviyesi',
                        expandBody: true,
                        body: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: layout.heroPadding,
                            vertical: layout.heroPadding,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'RİSK VE ÖDÜL',
                                    style: AppTextStyles.titleLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: layout.heroTitleFontSize,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: layout.heroSubtitleGap),
                              Text(
                                'Performansının zorluğunu sen belirle...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white54,
                                  fontStyle: FontStyle.italic,
                                  fontSize: layout.heroSubtitleFontSize,
                                ),
                                maxLines: layout.heroSubtitleMaxLines,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: layout.cardGap),
                    const Expanded(
                      child: Column(
                        children: [
                          _DifficultyOptionCard(
                            title: 'AMATOR',
                            multiplier: '1x',
                            points: 'Tahmini Kazanç: 10 Puan',
                            color: Colors.green,
                          ),
                          SizedBox(height: 10),
                          _DifficultyOptionCard(
                            title: 'PROFESYONEL',
                            multiplier: '2x',
                            points: 'Tahmini Kazanç: 20 Puan',
                            color: Colors.orange,
                          ),
                          SizedBox(height: 10),
                          _DifficultyOptionCard(
                            title: 'DUAYEN',
                            multiplier: '3x',
                            points: 'Tahmini Kazanç: 30 Puan',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: layout.bottomGap),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LeaderboardPreview extends StatelessWidget {
  const _LeaderboardPreview({required this.players});

  final List<_MockPlayer> players;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420 || constraints.maxHeight < 740;
          final width = min(max(constraints.maxWidth * 0.92, 320.0), 620.0);

          return Center(
            child: SizedBox(
              width: width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 18),
                child: Column(
                  children: [
                    SizedBox(height: compact ? 10 : 18),
                    Text(
                      'Puan Durumu',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontSize: compact ? 24 : 30,
                      ),
                    ),
                    SizedBox(height: compact ? 12 : 18),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.only(bottom: compact ? 12 : 20),
                        itemCount: players.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: compact ? 8 : 10),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return LeaderboardTile(
                            rank: index + 1,
                            playerName: player.name,
                            score: player.score,
                            isCurrentPlayer: player.isCurrentPlayer,
                            compact: compact,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GameOverPreview extends StatelessWidget {
  const _GameOverPreview({required this.players});

  final List<_MockPlayer> players;

  @override
  Widget build(BuildContext context) {
    final winner = players.isNotEmpty ? players.first : null;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420 || constraints.maxHeight < 760;
          final width = min(max(constraints.maxWidth * 0.92, 320.0), 640.0);

          return Center(
            child: SizedBox(
              width: width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 18),
                child: Column(
                  children: [
                    SizedBox(height: compact ? 10 : 18),
                    Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.accent,
                      size: compact ? 54 : 72,
                    ),
                    SizedBox(height: compact ? 8 : 12),
                    Text(
                      'KAZANAN',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: compact ? 2 : 4,
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        winner?.name.toUpperCase() ?? '',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: Colors.white,
                          fontSize: compact ? 28 : 34,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 4 : 8),
                    Text(
                      '${winner?.score ?? 0} PUAN',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: compact ? 20 : 24,
                      ),
                    ),
                    SizedBox(height: compact ? 16 : 24),
                    Expanded(
                      child: ListView.separated(
                        itemCount: players.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: compact ? 8 : 10),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return LeaderboardTile(
                            rank: index + 1,
                            playerName: player.name,
                            score: player.score,
                            isCurrentPlayer: player.isCurrentPlayer,
                            compact: compact,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: compact ? 12 : 16),
                    SizedBox(
                      width: double.infinity,
                      child: StageButton(
                        label: 'Lobiye Dön',
                        icon: Icons.home_rounded,
                        backgroundColor: AppColors.surfaceElevated,
                        textColor: Colors.white,
                        borderColor: Colors.transparent,
                        onPressed: () {},
                        compact: compact,
                      ),
                    ),
                    SizedBox(height: compact ? 12 : 18),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MockScoreboardBottomSheet extends StatelessWidget {
  const _MockScoreboardBottomSheet({required this.players});

  final List<_MockPlayer> players;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.46,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact =
                    constraints.maxWidth < 390 || constraints.maxHeight < 620;
                final width = min(max(constraints.maxWidth * 0.92, 320.0), 560.0);

                return Center(
                  child: SizedBox(
                    width: width,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: compact ? 36 : 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        Text(
                          'Puan Durumu',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontSize: compact ? 22 : 26,
                          ),
                        ),
                        SizedBox(height: compact ? 12 : 18),
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            padding: EdgeInsets.fromLTRB(
                              compact ? 12 : 20,
                              0,
                              compact ? 12 : 20,
                              compact ? 18 : 24,
                            ),
                            itemCount: players.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: compact ? 8 : 10),
                            itemBuilder: (context, index) {
                              final player = players[index];
                              return LeaderboardTile(
                                rank: index + 1,
                                playerName: player.name,
                                score: player.score,
                                isCurrentPlayer: player.isCurrentPlayer,
                                compact: compact,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
      ),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, color: AppColors.accent, size: 18),
      ),
    );
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({
    required this.label,
    required this.fontSize,
  });

  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize > 15 ? 18 : 14,
        vertical: fontSize > 15 ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.header,
    required this.body,
    this.expandBody = false,
  });

  final String header;
  final Widget body;
  final bool expandBody;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Text(
              header,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (expandBody) Expanded(child: body) else body,
        ],
      ),
    );
  }
}

class _InnerInfoCard extends StatelessWidget {
  const _InnerInfoCard({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PillLabel(label: 'GÖREV', fontSize: max(11, fontSize - 2)),
            const SizedBox(height: 12),
            Text(
              'İçeriğin Burada:',
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyOptionCard extends StatelessWidget {
  const _DifficultyOptionCard({
    required this.title,
    required this.multiplier,
    required this.points,
    required this.color,
  });

  final String title;
  final String multiplier;
  final String points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 110 || constraints.maxWidth < 320;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 14 : 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(compact ? 14 : 18),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: compact ? 18 : 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 12 : 14,
                        vertical: compact ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        multiplier,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: compact ? 16 : 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 8 : 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    points,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 13 : 15,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TaskPreviewMetrics {
  const _TaskPreviewMetrics({
    required this.contentWidth,
    required this.horizontalPadding,
    required this.topGap,
    required this.topBarHeight,
    required this.sectionGap,
    required this.innerPadding,
    required this.innerGap,
    required this.infoFontSize,
    required this.categoryFontSize,
    required this.buttonGap,
    required this.bottomGap,
    required this.compact,
  });

  final double contentWidth;
  final double horizontalPadding;
  final double topGap;
  final double topBarHeight;
  final double sectionGap;
  final double innerPadding;
  final double innerGap;
  final double infoFontSize;
  final double categoryFontSize;
  final double buttonGap;
  final double bottomGap;
  final bool compact;

  factory _TaskPreviewMetrics.from(BoxConstraints constraints) {
    final compact = constraints.maxWidth < 390 || constraints.maxHeight < 760;

    return _TaskPreviewMetrics(
      contentWidth: min(max(constraints.maxWidth * 0.9, 320.0), 560.0),
      horizontalPadding: compact ? 10 : 18,
      topGap: compact ? 8 : 16,
      topBarHeight: 40,
      sectionGap: compact ? 10 : 16,
      innerPadding: compact ? 14 : 18,
      innerGap: compact ? 10 : 14,
      infoFontSize: compact ? 16 : 18,
      categoryFontSize: compact ? 12 : 14,
      buttonGap: compact ? 8 : 10,
      bottomGap: compact ? 12 : 18,
      compact: compact,
    );
  }
}

class _DifficultyPreviewMetrics {
  const _DifficultyPreviewMetrics({
    required this.contentWidth,
    required this.horizontalPadding,
    required this.topGap,
    required this.categoryHeight,
    required this.categoryFontSize,
    required this.sectionGap,
    required this.heroHeight,
    required this.heroPadding,
    required this.heroTitleFontSize,
    required this.heroSubtitleFontSize,
    required this.heroSubtitleGap,
    required this.heroSubtitleMaxLines,
    required this.cardGap,
    required this.bottomGap,
  });

  final double contentWidth;
  final double horizontalPadding;
  final double topGap;
  final double categoryHeight;
  final double categoryFontSize;
  final double sectionGap;
  final double heroHeight;
  final double heroPadding;
  final double heroTitleFontSize;
  final double heroSubtitleFontSize;
  final double heroSubtitleGap;
  final int heroSubtitleMaxLines;
  final double cardGap;
  final double bottomGap;

  factory _DifficultyPreviewMetrics.from(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final compact = width < 390 || height < 760;

    return _DifficultyPreviewMetrics(
      contentWidth: min(max(width * 0.88, 320.0), 560.0),
      horizontalPadding: compact ? 10 : 18,
      topGap: compact ? 8 : 16,
      categoryHeight: compact ? 52 : 64,
      categoryFontSize: compact ? 14 : 16,
      sectionGap: compact ? 10 : 16,
      heroHeight: compact ? min(180.0, height * 0.24) : min(220.0, height * 0.28),
      heroPadding: compact ? 14 : 18,
      heroTitleFontSize: compact ? 24 : 28,
      heroSubtitleFontSize: compact ? 12 : 14,
      heroSubtitleGap: compact ? 6 : 8,
      heroSubtitleMaxLines: compact ? 1 : 2,
      cardGap: compact ? 8 : 12,
      bottomGap: compact ? 12 : 18,
    );
  }
}

class _MockPlayer {
  const _MockPlayer({
    required this.name,
    required this.score,
    required this.isCurrentPlayer,
  });

  final String name;
  final int score;
  final bool isCurrentPlayer;
}
