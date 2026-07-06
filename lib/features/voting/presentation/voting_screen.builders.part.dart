part of 'voting_screen.dart';

extension _VotingScreenBuilders on _VotingScreenState {
  Widget _buildProcessingIndicator() {
    return Column(
      children: [
        const AppLoadingIndicator(),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.countingVotes,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.accent,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingForOthers() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          AppLocalizations.of(context)!.waitingForEvaluation,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white38,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildVotedStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.evaluated,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}