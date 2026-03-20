import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _musicEnabled;
  late bool _sfxEnabled;
  late double _musicVolume;
  late double _sfxVolume;

  @override
  void initState() {
    super.initState();
    final audio = ref.read(audioServiceProvider);
    _musicEnabled = audio.musicEnabled;
    _sfxEnabled = audio.sfxEnabled;
    _musicVolume = audio.musicVolume;
    _sfxVolume = audio.sfxVolume;
    audio.playMenuLoop();
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.read(audioServiceProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
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
        title: Text(
          'Ayarlar',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.accent),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedMeshBackground()),
          SafeArea(
            child: ResponsiveWrapper(
              maxWidth: 700,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  _buildCard(
                    title: 'Menu Music',
                    enabled: _musicEnabled,
                    volume: _musicVolume,
                    onToggle: (value) async {
                      setState(() => _musicEnabled = value);
                      await audio.setMusicEnabled(value);
                    },
                    onVolume: _musicEnabled
                        ? (value) async {
                            setState(() => _musicVolume = value);
                            await audio.setMusicVolume(value);
                          }
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _buildCard(
                    title: 'SFX',
                    enabled: _sfxEnabled,
                    volume: _sfxVolume,
                    onToggle: (value) async {
                      setState(() => _sfxEnabled = value);
                      await audio.setSfxEnabled(value);
                    },
                    onVolume: _sfxEnabled
                        ? (value) async {
                            setState(() => _sfxVolume = value);
                            await audio.setSfxVolume(value);
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required bool enabled,
    required double volume,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double>? onVolume,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF130D26).withValues(alpha: 0.85), // Very dark plum/indigo
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.accent,
            title: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              enabled ? 'Açık' : 'Kapalı',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white54),
            ),
            value: enabled,
            onChanged: onToggle,
          ),
          Slider(
            value: volume,
            min: 0,
            max: 1,
            divisions: 20,
            label: '${(volume * 100).round()}%',
            onChanged: onVolume,
          ),
        ],
      ),
    );
  }
}
