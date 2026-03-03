import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/enums.dart';
import '../../custom_decks/domain/user_task_entity.dart';
import '../../custom_decks/providers/user_task_provider.dart';
import '../../auth/providers/auth_provider.dart';

class CustomDeckEditorScreen extends ConsumerStatefulWidget {
  const CustomDeckEditorScreen({super.key});

  @override
  ConsumerState<CustomDeckEditorScreen> createState() =>
      _CustomDeckEditorScreenState();
}

class _CustomDeckEditorScreenState
    extends ConsumerState<CustomDeckEditorScreen> {
  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _accentCrimson = Color(0xFF5C1616); // Bordo
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu

  void _showAddTaskDialog(String uid) {
    final contentController = TextEditingController();
    String selectedCategory = 'Cesaret';
    String selectedDifficulty = 'easy';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _accentGold.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              title: Text(
                'Kendi Sorunu Ekle',
                style: GoogleFonts.cinzelDecorative(
                  color: _textLight,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      labelText: 'Görev Metni',
                      labelStyle: GoogleFonts.cinzel(color: _accentGold),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.4),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _accentGold.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _accentGold),
                      ),
                    ),
                    style: GoogleFonts.cinzel(color: _textLight),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: _cardColor,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      labelStyle: GoogleFonts.cinzel(color: _accentGold),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.4),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _accentGold.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _accentGold),
                      ),
                    ),
                    items: ['Cesaret', 'İtiraf', 'Taklit']
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: GoogleFonts.cinzel(color: _textLight),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDifficulty,
                    dropdownColor: _cardColor,
                    decoration: InputDecoration(
                      labelText: 'Zorluk',
                      labelStyle: GoogleFonts.cinzel(color: _accentGold),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.4),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _accentGold.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _accentGold),
                      ),
                    ),
                    items: ['easy', 'medium', 'hard']
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              d,
                              style: GoogleFonts.cinzel(color: _textLight),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedDifficulty = v!),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'İptal',
                    style: GoogleFonts.cinzel(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentCrimson,
                    foregroundColor: _textLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _accentGold.withValues(alpha: 0.5),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    final content = contentController.text.trim();
                    if (content.isNotEmpty) {
                      final newTask = UserTaskEntity(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        category: selectedCategory,
                        content: content,
                        difficulty: selectedDifficulty,
                        type: TaskType.action,
                        tags: const ['custom'],
                        isActive: true,
                      );
                      ref
                          .read(customTaskControllerProvider.notifier)
                          .addTask(uid: uid, task: newTask);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Ekle',
                    style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _accentGold)),
      );
    }

    final isAnonymous = user.isAnonymous;
    final customTasksAsync = ref.watch(watchCustomTasksProvider(user.uid));

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          'Senin Soruların',
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
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isAnonymous
                  ? Icons.lock_outline_rounded
                  : Icons.add_circle_outline_rounded,
              color: isAnonymous ? Colors.grey.shade600 : _accentGold,
              size: 28,
            ),
            onPressed: isAnonymous ? null : () => _showAddTaskDialog(user.uid),
            tooltip: isAnonymous ? 'Hesap gerekli' : 'Soru Ekle',
          ),
        ],
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
          Container(color: _bgColor.withValues(alpha: 0.85)),

          SafeArea(
            child: Stack(
              children: [
                customTasksAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: _accentGold),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Bir hata oluştu: $err',
                      style: GoogleFonts.cinzel(color: _accentCrimson),
                    ),
                  ),
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isAnonymous)
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 64,
                                  color: _accentGold.withValues(alpha: 0.8),
                                ),
                              if (isAnonymous) const SizedBox(height: 16),
                              Text(
                                isAnonymous
                                    ? 'Custom deck kullanmak için\nhesap oluşturmalısın'
                                    : 'Henüz efsanelere konu olacak sorular girmedin.\nSağ üstten yeni soru ekle!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cinzel(
                                  color: _textLight.withValues(alpha: 0.7),
                                  fontSize: 18,
                                  height: 1.5,
                                ),
                              ),
                              if (isAnonymous) const SizedBox(height: 8),
                              if (isAnonymous)
                                Text(
                                  'Google veya Apple ile giriş yap',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cinzel(
                                    color: _textLight.withValues(alpha: 0.5),
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 80,
                      ),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        return Stack(
                          children: [
                            Card(
                              color: _cardColor.withValues(alpha: 0.9),
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: _accentGold.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kalem / Tüy İkonu
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _accentGold.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _accentGold.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.history_edu_rounded,
                                        color: isAnonymous
                                            ? Colors.grey.shade600
                                            : _accentGold,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.content,
                                            style: GoogleFonts.cinzel(
                                              color: isAnonymous
                                                  ? _textLight.withValues(
                                                      alpha: 0.5,
                                                    )
                                                  : _textLight,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black45,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: _accentGold
                                                        .withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  task.category,
                                                  style: GoogleFonts.cinzel(
                                                    color: isAnonymous
                                                        ? Colors.grey.shade600
                                                        : _accentGold,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black45,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  task.difficulty.toUpperCase(),
                                                  style: GoogleFonts.cinzel(
                                                    color: Colors.grey.shade400,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: isAnonymous
                                            ? Colors.grey.shade600
                                            : _accentCrimson,
                                      ),
                                      onPressed: isAnonymous
                                          ? null
                                          : () {
                                              ref
                                                  .read(
                                                    customTaskControllerProvider
                                                        .notifier,
                                                  )
                                                  .deleteTask(
                                                    uid: user.uid,
                                                    taskId: task.id,
                                                  );
                                            },
                                      tooltip: isAnonymous ? 'Kilitli' : 'Sil',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Kilit overlay (anonim kullanıcılar için)
                            if (isAnonymous)
                              Positioned.fill(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.lock_outline_rounded,
                                      color: Colors.grey.shade400,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
                // Üst overlay (anonim kullanıcılar için)
                if (isAnonymous)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
