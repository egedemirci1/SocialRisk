import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../buttons/exit_room_button.dart';
import 'async_error_view.dart';

/// Oyun akışı ekranları için standart hata iskeleti.
class GameErrorScaffold extends StatelessWidget {
  const GameErrorScaffold({
    super.key,
    required this.roomCode,
    required this.message,
    this.detail,
    this.onRetry,
    this.onGoHome,
    this.goHomeLabel,
  });

  final String roomCode;
  final String message;
  final String? detail;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;
  final String? goHomeLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ExitRoomButton(roomCode: roomCode),
      ),
      body: Center(
        child: AsyncErrorView(
          message: message,
          detail: detail,
          onRetry: onRetry,
          secondaryLabel: goHomeLabel,
          onSecondary: onGoHome,
        ),
      ),
    );
  }
}
