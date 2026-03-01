import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/task_item_entity.dart';
import '../providers/admin_provider.dart';
import '../../../shared/models/enums.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  final TaskItemEntity? taskToEdit;

  const TaskEditorScreen({super.key, this.taskToEdit});

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _content;
  late String _category;
  late String _difficulty;
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

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskToEdit == null ? 'Görev Ekle' : 'Görev Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _content,
                decoration: const InputDecoration(
                  labelText: 'Görev Metni',
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Boş bırakılamaz' : null,
                onSaved: (v) => _content = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  filled: true,
                ),
                dropdownColor: Colors.grey[800],
                items:
                    [
                          'Cesaret',
                          'İtiraf',
                          'Taklit',
                          'Sosyal Medya',
                          'Fiziksel',
                          'Bilgi',
                        ]
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                decoration: const InputDecoration(
                  labelText: 'Zorluk',
                  filled: true,
                ),
                dropdownColor: Colors.grey[800],
                items: ['easy', 'medium', 'hard']
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(
                          d,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _difficulty = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Görev Tipi',
                  filled: true,
                ),
                dropdownColor: Colors.grey[800],
                items: TaskType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hangi Etiketlerde Çıksın?',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              Wrap(
                spacing: 8,
                children: _allTags
                    .map(
                      (p) => ChoiceChip(
                        label: Text(p),
                        selected: _tags.contains(p),
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
