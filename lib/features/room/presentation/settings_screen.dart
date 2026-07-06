import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_locale_options.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import 'package:social_risk/l10n/app_localizations.dart';

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

  void _showDeveloperTeamDialog() {
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D1538),
        title: Text(
          l.developerTeamTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ata Dinmezer',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l.developerRole,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              'Mehmet Ege Demirci',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l.developerRole,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              'İhsan Eken',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l.artDirectorRole,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }

  void _showAboutDialogCustom() {
    final l = AppLocalizations.of(context)!;
    final appName = l.appTitle;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D1538),
        title: Text(appName, style: const TextStyle(color: Colors.white)),
        content: Text(
          l.allRightsReserved,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.close),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDeveloperTeamDialog();
            },
            child: Text(l.developerTeamTitle),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final audio = ref.read(audioServiceProvider);
    _musicEnabled = audio.musicEnabled;
    _sfxEnabled = audio.sfxEnabled;
    _musicVolume = audio.musicVolume;
    _sfxVolume = audio.sfxVolume;
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
          AppLocalizations.of(context)!.settingsTitle,
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
                    title: AppLocalizations.of(context)!.menuMusic,
                    enabled: _musicEnabled,
                    volume: _musicVolume,
                    onToggle: (value) async {
                      setState(() => _musicEnabled = value);
                      await audio.setMusicEnabled(value);
                      if (value) {
                        await audio.ensureMenuMusic();
                      }
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
                    title: AppLocalizations.of(context)!.soundEffects,
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
                  const SizedBox(height: 14),
                  _buildLanguageCard(),
                  const SizedBox(height: 14),
                  _buildLegalCard(context),
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
            activeThumbColor: AppColors.accent,
            title: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              enabled ? AppLocalizations.of(context)!.on : AppLocalizations.of(context)!.off,
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

  Widget _buildLanguageCard() {
    final currentLocale = ref.watch(appLocaleProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF130D26).withValues(alpha: 0.85),
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
          Text(
            AppLocalizations.of(context)!.languageSelection,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(_localeValue(currentLocale)),
            initialValue: _localeValue(currentLocale),
            isExpanded: true,
            dropdownColor: const Color(0xFF1D1538),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.accent.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.accent.withValues(alpha: 0.2),
                ),
              ),
            ),
            style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
            items: kAppLocaleOptions.map((o) {
              final value = _localeValue(o.locale);
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  '${o.flag} ${o.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              );
            }).toList(growable: false),
            onChanged: (value) {
              if (value == null) return;
              final selected = kAppLocaleOptions.firstWhere(
                (o) => _localeValue(o.locale) == value,
              );
              ref.read(appLocaleProvider.notifier).setLocale(selected.locale);
            },
          ),
        ],
      ),
    );
  }

  String _localeValue(Locale locale) =>
      '${locale.languageCode}_${locale.countryCode ?? ''}';

  Widget _buildLegalCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF130D26).withValues(alpha: 0.85),
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
          Text(
            AppLocalizations.of(context)!.info,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.accent),
            title: Text(
              AppLocalizations.of(context)!.about,
              style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.appAndTeamInfo,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white54),
            ),
            onTap: () {
              _showAboutDialogCustom();
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.gavel_rounded, color: AppColors.accent),
            title: Text(
              AppLocalizations.of(context)!.termsOfUse,
              style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.legalTermsAndConditions,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white54),
            ),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1D1538),
                  title: Text(AppLocalizations.of(context)!.termsOfUse, style: const TextStyle(color: Colors.white)),
                  content: SingleChildScrollView(
                    child: Text(
                      AppLocalizations.of(context)!.termsOfUseContent,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(AppLocalizations.of(context)!.close),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
