import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _isJoining = false;

  String get _roomCode => _controllers.map((c) => c.text).join().toUpperCase();
  bool get _isCodeComplete => _roomCode.length == _codeLength;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (i) {
      final node = FocusNode();
      node.addListener(() {
        if (node.hasFocus && _controllers[i].text.isNotEmpty) {
          // Auto-select the character when box gains focus
          _controllers[i].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[i].text.length,
          );
        }
        setState(() {});
      });
      return node;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

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
                            style: AppTextStyles.displayMedium.copyWith(fontWeight: FontWeight.w900,
                              fontSize: 24,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              shadows: const [
                                Shadow(offset: Offset(0, 4), color: Colors.black26, blurRadius: 4),
                              ],),
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
                            'Arkadaşlarının paylaştığı 6 haneli parti kodunu girerek eğlenceye dahil ol.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white54,
                              fontSize: 12.5,
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
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_codeLength, (index) {
          final hasText = _controllers[index].text.isNotEmpty;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: index == 3 ? 6 : 3),
            child: SizedBox(
              width: 42,
              height: 54,
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is! KeyDownEvent) return;
                  
                  if (event.logicalKey == LogicalKeyboardKey.backspace &&
                      _controllers[index].text.isEmpty &&
                      index > 0) {
                    _controllers[index - 1].clear();
                    _focusNodes[index - 1].requestFocus();
                    setState(() {});
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowRight && index < _codeLength - 1) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  autocorrect: false,
                  enableSuggestions: false,
                  showCursor: false,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.visiblePassword,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.accent,
                    fontSize: 28,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: hasText
                            ? AppColors.accent.withValues(alpha: 0.5)
                            : Colors.white12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Always select entire text on tap
                    if (_controllers[index].text.isNotEmpty) {
                      _controllers[index].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _controllers[index].text.length,
                      );
                    }
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty && index < _codeLength - 1) {
                      _focusNodes[index + 1].requestFocus();
                    }
                    setState(() {});
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
