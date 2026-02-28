import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/room_provider.dart';

/// Odaya katılma ekranı — 6 haneli oda kodu girişi.
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
  bool _isJoining = false;

  String get _roomCode =>
      _controllers.map((c) => c.text).join().toUpperCase();

  bool get _isCodeComplete => _roomCode.length == _codeLength;

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

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  Future<void> _joinRoom() async {
    if (!_isCodeComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen 6 haneli kodu gir')),
      );
      return;
    }

    setState(() => _isJoining = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      await ref.read(roomControllerProvider.notifier).joinRoom(
        roomCode: _roomCode,
        playerId: user.uid,
        playerName: user.displayName ?? 'Oyuncu',
      );

      if (mounted) context.push('/lobby', extra: _roomCode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oda bulunamadı: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odaya Katıl'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // İkon
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.1),
              ),
              child: const SizedBox(
                width: 80,
                height: 80,
                child: Center(
                  child: Icon(
                    Icons.qr_code_rounded,
                    color: AppColors.accent,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Oda Kodunu Gir',
              style: AppTextStyles.displayMedium.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arkadaşının paylaştığı 6 haneli kodu gir',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Kod giriş alanları
            _buildCodeInputs(),

            const SizedBox(height: 32),

            // Katıl butonu
            PrimaryButton(
              label: 'Odaya Katıl',
              icon: Icons.login_rounded,
              onPressed: _isCodeComplete ? _joinRoom : null,
              isLoading: _isJoining,
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_codeLength, (index) {
        final hasValue = _controllers[index].text.isNotEmpty;

        return Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? 0 : 8,
            right: index == 3 ? 12 : 0, // 3 + 3 gruplandırma
          ),
          child: SizedBox(
            width: 44,
            height: 56,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  _onBackspace(index);
                }
              },
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                maxLength: 1,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: hasValue
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasValue ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasValue
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) => _onCodeChanged(index, value),
              ),
            ),
          ),
        );
      }),
    );
  }
}
