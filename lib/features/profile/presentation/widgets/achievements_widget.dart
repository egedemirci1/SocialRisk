import 'package:flutter/material.dart';
import '../../../auth/domain/user_entity.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';

/// Achievement tier thresholds per category.
class _AchievementDef {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<int> tiers; // values at which tier 1..4 are completed
  final int Function(UserEntity user) getValue;

  const _AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tiers,
    required this.getValue,
  });
}

final List<_AchievementDef> _achievements = [
  _AchievementDef(
    id: 'games_played',
    title: 'Parti Canavarı',
    description: 'Oynanan oyun sayısı',
    icon: Icons.sports_esports_rounded,
    tiers: [1, 10, 25, 50],
    getValue: (u) => u.stats['games_played'] ?? 0,
  ),
  _AchievementDef(
    id: 'votes_given',
    title: 'Halkın Sesi',
    description: 'Verilen oy sayısı',
    icon: Icons.how_to_vote_rounded,
    tiers: [5, 20, 50, 100],
    getValue: (u) => u.stats['votes_given'] ?? 0,
  ),
  _AchievementDef(
    id: 'wallet',
    title: 'VIP',
    description: 'Sahip olunan bakiye',
    icon: Icons.monetization_on_rounded,
    tiers: [100, 500, 1000, 5000],
    getValue: (u) => u.walletPoints,
  ),
  _AchievementDef(
    id: 'cosmetics',
    title: 'Sosyal İkon',
    description: 'Sahip olunan eşya sayısı',
    icon: Icons.diamond_rounded,
    tiers: [1, 3, 5, 10],
    getValue: (u) => u.ownedCosmetics.length,
  ),
  _AchievementDef(
    id: 'custom_tasks',
    title: 'Oyun Kurucu',
    description: 'Eklenen özel görev sayısı',
    icon: Icons.edit_note_rounded,
    tiers: [1, 5, 20, 50],
    getValue: (u) => u.stats['custom_tasks'] ?? 0,
  ),
];

/// Returns how many tiers (0-4) are completed for this achievement + a [0,1] progress to next tier.
({int completedTiers, double progressToNext, int current, int next}) _evalAchievement(
  _AchievementDef def,
  UserEntity user,
) {
  final value = def.getValue(user);
  int completed = 0;
  for (final t in def.tiers) {
    if (value >= t) completed++;
  }
  final progressToNext = completed < def.tiers.length
      ? (value - (completed == 0 ? 0 : def.tiers[completed - 1])) /
          (def.tiers[completed] - (completed == 0 ? 0 : def.tiers[completed - 1]))
      : 1.0;
  final current = value;
  final next = completed < def.tiers.length ? def.tiers[completed] : def.tiers.last;
  return (
    completedTiers: completed,
    progressToNext: progressToNext.clamp(0.0, 1.0),
    current: current,
    next: next,
  );
}

class AchievementsWidget extends StatelessWidget {
  final UserEntity user;
  const AchievementsWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 18),
            const SizedBox(width: 8),
            Text(
              'Başarımlar',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white10),
        const SizedBox(height: 8),
        ...(_achievements.map((def) => _AchievementRow(def: def, user: user))),
      ],
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final _AchievementDef def;
  final UserEntity user;
  const _AchievementRow({required this.def, required this.user});

  @override
  Widget build(BuildContext context) {
    final eval = _evalAchievement(def, user);
    final completed = eval.completedTiers;
    final progress = eval.progressToNext;
    final isMaxed = completed >= def.tiers.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMaxed ? AppColors.accent.withValues(alpha: 0.4) : AppColors.accent.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(def.icon, color: AppColors.accent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  def.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              // Tier dots
              Row(
                children: List.generate(def.tiers.length, (i) {
                  final filled = i < completed;
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.accent : Colors.white12,
                      border: Border.all(
                        color: filled ? AppColors.accent : Colors.white24,
                        width: 1,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isMaxed ? AppColors.accent : AppColors.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                def.description,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white38, fontSize: 11),
              ),
              Text(
                isMaxed ? 'TAMAMLANDI ✓' : '${eval.current} / ${eval.next}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isMaxed ? AppColors.accent : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
