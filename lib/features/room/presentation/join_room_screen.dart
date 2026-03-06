import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/loading_overlay.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/room_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';

/// Partiye Katılma Ekranı — Parti Temalı
class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  static const _codeLength = 6;
  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _isJoining = false;

  String get _roomCode => _codeController.text.toUpperCase().replaceAll(' ', '');
  bool get _isCodeComplete => _roomCode.length == _codeLength;

  Future<void> _joinRoom() async {
    if (!_isCodeComplete) {
      ToastUtils.showWarning(context, 'Lütfen 6 haneli kodu gir');
      return;
    }

    setState(() => _isJoining = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final userProfile = await ref
          .read(userRepositoryProvider)
          .getUserProfile(user.uid);
      final repo = ref.read(roomRepositoryProvider);

      await repo.joinRoom(
        roomCode: _roomCode,
        playerId: user.uid,
        playerName: user.displayName ?? 'Oyuncu',
        playerAvatarUrl: userProfile?.avatarUrl,
      );

      if (mounted) context.push('/lobby', extra: _roomCode);
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Parti bulunamadı: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isJoining,
      message: 'Partiye bağlanılıyor...',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.accent,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: AnimatedMeshBackground(),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: ResponsiveWrapper(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF130D26).withValues(alpha: 0.85), // Very dark plum/indigo
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.15), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Partiye Katıl',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              shadows: const [
                                Shadow(offset: Offset(0, 4), color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.key_rounded,
                              color: AppColors.accent,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Parti Kodunu Gir',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Arkadaşlarının paylaştığı 6 haneli parti kodunu girerek\neğlenceye dahil ol.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          _buildCodeInputs(),
                          const SizedBox(height: 60),
                          StageButton(
                            label: 'Partiye Katıl',
                            icon: Icons.login_rounded,
                            backgroundColor: AppColors.primary,
                            textColor: AppColors.background,
                            borderColor: Colors.transparent,
                            onPressed: _isCodeComplete ? _joinRoom : () {},
                            isLoading: _isJoining,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInputs() {
    return GestureDetector(
      onTap: () => _codeFocusNode.requestFocus(),
      child: Stack(
        children: [
          // Hidden real TextField that handles input
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _codeController,
              focusNode: _codeFocusNode,
              maxLength: _codeLength,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
              ],
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Visual display boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_codeLength, (index) {
              final code = _roomCode;
              final char = index < code.length ? code[index] : '';
              final isFocused = _codeFocusNode.hasFocus && index == (code.length < _codeLength ? code.length : _codeLength - 1);
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 3 ? 8 : 4),
                child: Container(
                  width: 44,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isFocused
                          ? AppColors.accent
                          : char.isNotEmpty
                              ? AppColors.accent.withValues(alpha: 0.5)
                              : Colors.white12,
                      width: isFocused ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      char,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
