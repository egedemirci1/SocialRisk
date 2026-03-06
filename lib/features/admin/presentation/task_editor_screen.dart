import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/task_item_entity.dart';
import '../providers/admin_provider.dart';
import '../../../shared/models/enums.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/utils/toast_utils.dart';

/// Senaryo Editörü — Tiyatro Temalı
class TaskEditorScreen extends ConsumerStatefulWidget {
  final TaskItemEntity? taskToEdit;
  const TaskEditorScreen({super.key, this.taskToEdit});

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _content, _category, _difficulty;
  late TaskType _type;
  late List<String> _tags;
  bool _isSaving = false;
  final List<String> _allTags = ['classic', 'family', 'couple', 'adult'];

  @override
  void initState() {
    super.initState();
    final t = widget.taskToEdit;
    _content = t?.content ?? '';
    _category = t?.category ?? 'Cesaret';
    _difficulty = t?.difficulty ?? 'easy';
    _type = t?.type ?? TaskType.action;
    _tags = t?.tags != null ? List.from(t!.tags) : ['classic', 'adult'];
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSaving = true);
    try {
      final task = TaskItemEntity(
        id: widget.taskToEdit?.id ?? '',
        category: _category,
        content: _content,
        difficulty: _difficulty,
        type: _type,
        tags: _tags,
        likes: widget.taskToEdit?.likes ?? 0,
        dislikes: widget.taskToEdit?.dislikes ?? 0,
        isActive: widget.taskToEdit?.isActive ?? true,
        createdAt: widget.taskToEdit?.createdAt ?? DateTime.now(),
      );
      final notifier = ref.read(adminControllerProvider.notifier);
      if (widget.taskToEdit == null) {
        await notifier.addTask(task);
      } else {
        await notifier.updateTask(task);
      }
      if (mounted) {
        ToastUtils.showSuccess(context, widget.taskToEdit == null ? 'Senaryo eklendi!' : 'Senaryo güncellendi!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Hata: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.taskToEdit == null ? 'YENİ SENARYO' : 'SENARYOYU DÜZENLE',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('SENARYO REPLİĞİ'),
              TextFormField(
                initialValue: _content,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  fillColor: AppColors.surface,
                  filled: true,
                  counterStyle: GoogleFonts.libreBaskerville(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.libreBaskerville(
                  color: Colors.white,
                  fontSize: 16,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Boş bırakılamaz' : null,
                onSaved: (v) => _content = v!,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('TÜR'),
                        _buildDropdown(
                          [
                            'Cesaret',
                            'İtiraf',
                            'Taklit',
                            'Sosyal Medya',
                            'Fiziksel',
                            'Bilgi',
                          ],
                          _category,
                          (v) => setState(() => _category = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('ZORLUK'),
                        _buildDropdown(
                          ['easy', 'medium', 'hard'],
                          _difficulty,
                          (v) => setState(() => _difficulty = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildLabel('ETİKETLER'),
              Wrap(
                spacing: 8,
                children: _allTags
                    .map(
                      (p) => ChoiceChip(
                        label: Text(
                          p.toUpperCase(),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: _tags.contains(p)
                                ? Colors.white
                                : Colors.white54,
                          ),
                        ),
                        selected: _tags.contains(p),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _tags.add(p);
                            } else {
                              _tags.remove(p);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'REPERTUARA EKLE',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.playfairDisplay(
          color: AppColors.accent,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    i.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
