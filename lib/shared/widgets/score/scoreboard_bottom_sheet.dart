import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/room/providers/room_provider.dart';
import '../../../features/auth/providers/user_provider.dart';
import '../../../features/economy/providers/economy_provider.dart';
import '../common/player_avatar.dart';

class ScoreboardBottomSheet extends ConsumerWidget {
  const ScoreboardBottomSheet({super.key, required this.roomCode});

  final String roomCode;

  static void show(BuildContext context, String roomCode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ScoreboardBottomSheet(roomCode: roomCode),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(watchPlayersProvider(roomCode));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final layout = _ScoreboardLayoutMetrics.from(constraints);

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Center(
                  child: SizedBox(
                    width: layout.contentWidth,
                    child: Column(
                      children: [
                        SizedBox(height: layout.topGap),
                        Container(
                          width: layout.handleWidth,
                          height: layout.handleHeight,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        SizedBox(height: layout.headerGap),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.leaderboard_rounded,
                                color: AppColors.primary,
                                size: layout.headerIconSize,
                              ),
                              SizedBox(width: layout.headerIconGap),
                              Flexible(
                                child: Text(
                                  'Puan Durumu',
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: layout.headerFontSize,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: layout.listTopGap),
                        Expanded(
                          child: playersAsync.when(
                            data: (players) {
                              final sortedPlayers = List.of(players)
                                ..sort((a, b) => b.score.compareTo(a.score));
                              return ListView.separated(
                                controller: scrollController,
                                padding: EdgeInsets.fromLTRB(
                                  layout.horizontalPadding,
                                  0,
                                  layout.horizontalPadding,
                                  layout.bottomPadding,
                                ),
                                itemCount: sortedPlayers.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: layout.tileGap),
                                itemBuilder: (context, index) {
                                  final player = sortedPlayers[index];
                                  return _ScoreTile(
                                    rank: index + 1,
                                    name: player.name,
                                    score: player.score,
                                    avatarUrl: player.avatarUrl,
                                    activeFrame: player.activeFrame,
                                    playerId: player.id,
                                    layout: layout,
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, _) => Center(child: Text('Hata: $e')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ScoreTile extends ConsumerWidget {
  const _ScoreTile({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatarUrl,
    this.activeFrame,
    this.playerId,
    required this.layout,
  });

  final int rank;
  final String name;
  final int score;
  final String? avatarUrl;
  final String? activeFrame;
  final String? playerId;
  final _ScoreboardLayoutMetrics layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = Colors.white38;
    }

    // Canlı profil — ünvan
    final profile = playerId != null
        ? ref.watch(watchUserProfileProvider(playerId!)).value
        : null;
    final cosmetics = ref.watch(fetchCosmeticsProvider).value ?? [];
    final titleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(layout.tileRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(layout.tilePadding),
        child: Row(
          children: [
            SizedBox(
              width: layout.rankWidth,
              child: Text(
                '#$rank',
                style: AppTextStyles.titleLarge.copyWith(
                  color: rankColor,
                  fontWeight: FontWeight.w800,
                  fontSize: layout.rankFontSize,
                ),
              ),
            ),
            SizedBox(width: layout.inlineGap),
            PlayerAvatar(
              displayName: name,
              avatarUrl: avatarUrl,
              score: score,
              frameId: activeFrame,
              uid: playerId,
              radius: layout.avatarRadius,
            ),
            SizedBox(width: layout.inlineGapLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: layout.nameFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (titleItem != null)
                    Text(
                      '${titleItem.imageUrl} ${titleItem.name}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFFD4AF37),
                        fontSize: layout.titleFontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(layout.scoreRadius),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: layout.scoreHorizontalPadding,
                  vertical: layout.scoreVerticalPadding,
                ),
                child: Text(
                  '$score',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: layout.scoreFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreboardLayoutMetrics {
  const _ScoreboardLayoutMetrics({
    required this.contentWidth,
    required this.horizontalPadding,
    required this.topGap,
    required this.handleWidth,
    required this.handleHeight,
    required this.headerGap,
    required this.headerIconSize,
    required this.headerIconGap,
    required this.headerFontSize,
    required this.listTopGap,
    required this.bottomPadding,
    required this.tileGap,
    required this.tileRadius,
    required this.tilePadding,
    required this.rankWidth,
    required this.rankFontSize,
    required this.avatarRadius,
    required this.inlineGap,
    required this.inlineGapLarge,
    required this.nameFontSize,
    required this.titleFontSize,
    required this.scoreRadius,
    required this.scoreHorizontalPadding,
    required this.scoreVerticalPadding,
    required this.scoreFontSize,
  });

  final double contentWidth;
  final double horizontalPadding;
  final double topGap;
  final double handleWidth;
  final double handleHeight;
  final double headerGap;
  final double headerIconSize;
  final double headerIconGap;
  final double headerFontSize;
  final double listTopGap;
  final double bottomPadding;
  final double tileGap;
  final double tileRadius;
  final double tilePadding;
  final double rankWidth;
  final double rankFontSize;
  final double avatarRadius;
  final double inlineGap;
  final double inlineGapLarge;
  final double nameFontSize;
  final double titleFontSize;
  final double scoreRadius;
  final double scoreHorizontalPadding;
  final double scoreVerticalPadding;
  final double scoreFontSize;

  factory _ScoreboardLayoutMetrics.from(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final compact = width < 390;

    return _ScoreboardLayoutMetrics(
      contentWidth: min(max(width * 0.92, 320.0), 560.0),
      horizontalPadding: compact ? 14 : 20,
      topGap: compact ? 10 : 12,
      handleWidth: compact ? 36 : 40,
      handleHeight: 4,
      headerGap: compact ? 12 : 16,
      headerIconSize: compact ? 24 : 28,
      headerIconGap: compact ? 10 : 12,
      headerFontSize: compact ? 22 : 26,
      listTopGap: compact ? 16 : 24,
      bottomPadding: compact ? 18 : 24,
      tileGap: compact ? 10 : 12,
      tileRadius: compact ? 14 : 16,
      tilePadding: compact ? 12 : 16,
      rankWidth: compact ? 28 : 32,
      rankFontSize: compact ? 18 : 22,
      avatarRadius: compact ? 16 : 18,
      inlineGap: compact ? 6 : 8,
      inlineGapLarge: compact ? 12 : 16,
      nameFontSize: compact ? 14 : 16,
      titleFontSize: compact ? 9 : 10,
      scoreRadius: 8,
      scoreHorizontalPadding: compact ? 10 : 12,
      scoreVerticalPadding: compact ? 5 : 6,
      scoreFontSize: compact ? 14 : 16,
    );
  }
}
