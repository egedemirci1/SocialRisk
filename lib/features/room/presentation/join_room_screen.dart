import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/room_provider.dart';
import '../../../core/constants/app_colors.dart';

/// Sahneye Katılma Ekranı — Tiyatro Temalı
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

  String get _roomCode => _controllers.map((c) => c.text).join().toUpperCase();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen 6 haneli kodu gir')));
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
        playerName: user.displayName ?? 'Aktör',
        playerAvatarUrl: userProfile?.avatarUrl,
      );

      if (mounted) context.push('/lobby', extra: _roomCode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sahne bulunamadı: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Gösteriye Katıl',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.accent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 60),
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
                    blurRadius: 40,
                    spreadRadius: 5,
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
              'Sahne Kodunu Gir',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Yönetmenin paylaştığı 6 haneli kodu girerek\nperformansa dahil ol.',
              style: GoogleFonts.libreBaskerville(
                color: Colors.white54,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildCodeInputs(),
            const SizedBox(height: 60),
            StageButton(
              label: 'Gösteriye Katıl',
              icon: Icons.login_rounded,
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              borderColor: AppColors.accent,
              onPressed: _isCodeComplete ? _joinRoom : () {},
              isLoading: _isJoining,
            ),
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
          padding: EdgeInsets.symmetric(horizontal: index == 3 ? 8 : 2),
          child: SizedBox(
            width: 40, // Reduced from 44
            height: 56, // Reduced from 60
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
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: hasValue
                          ? AppColors.accent.withValues(alpha: 0.5)
                          : Colors.white12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
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
