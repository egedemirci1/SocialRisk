import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/buttons/medieval_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/room_provider.dart';

/// Odaya katılma ekranı — Orta Çağ Temalı
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

  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _accentCrimson = Color(0xFF5C1616); // Bordo
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen 6 haneli kodu gir',
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _accentCrimson,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Oda bulunamadı: ${e.toString()}',
              style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
            ),
            backgroundColor: _accentCrimson,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          'Odaya Katıl',
          style: GoogleFonts.cinzelDecorative(
            fontWeight: FontWeight.w700,
            color: _textLight,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _accentGold),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arka Plan Resmi
          Image.asset(
            'assets/Loading-Screen-Background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          // Karartma (Overlay)
          Container(color: _bgColor.withOpacity(0.85)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      kToolbarHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // İkon (Orta Çağ stilize parşömen/mühür ikonuna benzetme)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _accentGold.withOpacity(0.1),
                          border: Border.all(
                            color: _accentGold.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _accentGold.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const SizedBox(
                          width: 80,
                          height: 80,
                          child: Center(
                            child: Icon(
                              Icons
                                  .key_rounded, // Anahtar ikonu odaya katılmaya daha uygun
                              color: _accentGold,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Oda Kodunu Gir',
                        style: GoogleFonts.cinzel(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _textLight,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Arkadaşının paylaştığı 6 haneli kodu gir',
                        style: GoogleFonts.cinzel(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // Kod giriş alanları
                      _buildCodeInputs(),

                      const SizedBox(height: 48),

                      // Katıl butonu
                      MedievalButton(
                        label: 'Odaya Katıl',
                        icon: Icons.login_rounded,
                        backgroundColor: _accentCrimson,
                        textColor: _textLight,
                        borderColor: _accentGold.withOpacity(0.6),
                        onPressed: _isCodeComplete ? _joinRoom : () {},
                        isLoading: _isJoining,
                      ),

                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
            right: index == 2 ? 16 : 0, // 3 + 3 gruplandırma
          ),
          child: SizedBox(
            width: 44,
            height: 60,
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
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textLight,
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: hasValue
                      ? _accentGold.withOpacity(0.15)
                      : Colors.black.withOpacity(0.4),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasValue ? _accentGold : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasValue
                          ? _accentGold.withOpacity(0.5)
                          : _accentGold.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: _accentGold,
                      width: 2.5,
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
