import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_locale_options.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/locale_provider.dart';
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
                    title: 'Menü Müziği',
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
                    title: 'Ses Efektleri',
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
            'Dil Seçimi',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _localeValue(currentLocale),
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
            'Bilgilendirme',
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
              'Credits / Hakkinda',
              style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
            ),
            subtitle: Text(
              'Uygulama ve ekip bilgileri',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white54),
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Social Risk',
                applicationVersion: '1.0.0',
                applicationLegalese: '2026 Social Risk Team',
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.gavel_rounded, color: AppColors.accent),
            title: Text(
              'Kullanim Kosullari',
              style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
            ),
            subtitle: Text(
              'Yasal sartlar ve kosullar',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white54),
            ),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1D1538),
                  title: const Text('Kullanim Kosullari', style: TextStyle(color: Colors.white)),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Son guncelleme: 2026\n\n'
                      '1) Kabul ve Kapsam\n'
                      'Bu uygulamayi kullanarak, burada belirtilen Kullanim Kosullari\'ni kabul etmis sayilirsiniz. '
                      'Kosullari kabul etmiyorsaniz uygulamayi kullanmayiniz.\n\n'
                      '2) Uygun Kullanim\n'
                      'Kullanici; hile, taciz, nefret soylemi, tehdit, yasa disi icerik paylasimi, hesap guvenligini ihlal etme '
                      've hizmeti bozacak otomasyon araclari kullanmama yukumlulugundedir.\n\n'
                      '3) Hesap ve Guvenlik\n'
                      'Hesabinizla yapilan islemlerden sorumlusunuz. Supheli erisim veya guvenlik ihlalini gecikmeden bildirmeniz gerekir.\n\n'
                      '4) Icerik ve Topluluk Kurallari\n'
                      'Kullanici tarafindan olusturulan icerikler (metin, gorsel vb.) topluluk kurallarina uygun olmalidir. '
                      'Kurallari ihlal eden icerikler bildirimsiz kaldirilabilir, hesaplara gecici veya kalici kisit uygulanabilir.\n\n'
                      '5) Fikri Mulkiyet\n'
                      'Uygulama arayuzu, marka ogeleri ve yazilim bilesenleri ilgili hak sahiplerine aittir. '
                      'Izinsiz kopyalama, dagitma veya tersine muhendislik yasaktir.\n\n'
                      '6) Hizmette Degisiklik ve Kesinti\n'
                      'Hizmet, teknik bakim, guvenlik veya is gereksinimleri nedeniyle degistirilebilir, kisitlanabilir veya gecici olarak durdurulabilir.\n\n'
                      '7) Sorumlulugun Sinirlandirilmasi\n'
                      'Uygulama \"oldugu gibi\" sunulur. Mevzuatin izin verdigi olcude, dolayli veya arizi zararlardan sorumluluk kabul edilmez.\n\n'
                      '8) Hesap Sonlandirma\n'
                      'Kullanim kosullari veya topluluk kurallarinin ihlali durumunda erisiminiz askiya alinabilir veya sonlandirilabilir.\n\n'
                      '9) Kosullarin Guncellenmesi\n'
                      'Kullanim Kosullari zaman zaman guncellenebilir. Guncel metin uygulama icinde yayimlandigi andan itibaren gecerlidir.\n\n'
                      '10) Iletisim\n'
                      'Yasal bildirimler ve destek talepleri icin uygulama ici iletisim kanallari kullanilmalidir.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Kapat'),
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
