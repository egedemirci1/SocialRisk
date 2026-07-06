import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/enums.dart';
import '../../auth/domain/user_entity.dart';
import '../../custom_decks/domain/user_task_entity.dart';
import '../../custom_decks/providers/user_task_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../premium/providers/premium_provider.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../core/constants/app_colors.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';
import 'package:social_risk/l10n/app_localizations.dart';

part 'custom_deck_editor_screen.dialog.part.dart';
part 'custom_deck_editor_screen.build.part.dart';

class CustomDeckEditorScreen extends ConsumerStatefulWidget {
  const CustomDeckEditorScreen({super.key});

  @override
  ConsumerState<CustomDeckEditorScreen> createState() =>
      _CustomDeckEditorScreenState();
}

class _CustomDeckEditorScreenState
    extends ConsumerState<CustomDeckEditorScreen> {
  // Keep legacy colors for card list (will be migrated separately)
  static const _bgColor = AppColors.background;
  static const _accentGold = AppColors.accent;
  static const _accentCrimson = AppColors.error;
  static const _textLight = Colors.white;
  static const _cardColor = AppColors.surface;

  AppLocalizations get l => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) => _buildEditorScreen();
}