import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../guards/room_exit_guard.dart';

class ExitRoomButton extends ConsumerWidget {
  final String roomCode;

  const ExitRoomButton({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Tooltip(
      message: l.leavePartyTitle,
      child: IconButton(
        icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.primary),
        onPressed: () => showLeaveRoomDialog(
          context,
          ref,
          roomCode,
          mode: LeaveRoomMode.inGame,
        ),
      ),
    );
  }
}
