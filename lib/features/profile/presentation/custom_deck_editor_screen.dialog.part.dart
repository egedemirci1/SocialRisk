part of 'custom_deck_editor_screen.dart';

extension _CustomDeckEditorDialog on _CustomDeckEditorScreenState {
  void _showTaskDialog(UserEntity user, {UserTaskEntity? editingTask}) {
    final uid = user.uid;
    final formKey = GlobalKey<FormState>();
    final contentController = TextEditingController(
      text: editingTask?.content ?? '',
    );
    String selectedDifficulty = editingTask?.difficulty ?? 'easy';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Consumer(
              builder: (context, ref, _) {
                final controllerState = ref.watch(customTaskControllerProvider);
                final isLoading = controllerState.isLoading;
                
                ref.listen(customTaskControllerProvider, (prev, next) {
                  if (next is AsyncError) {
                    ToastUtils.showError(context, l.error(ErrorMessageUtils.formatUserError(next.error!, l)));
                  } else if (prev?.isLoading == true &&
                      !next.isLoading &&
                      !next.hasError) {
                    ToastUtils.showSuccess(context, editingTask == null ? l.contentAdded : l.contentUpdated);
                    Navigator.pop(context);
                  }
                });
                
                return AlertDialog(
              backgroundColor: _CustomDeckEditorScreenState._cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _CustomDeckEditorScreenState._accentGold.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              title: Text(
                editingTask == null ? l.createContent : l.editContent,
                style: AppTextStyles.titleLarge.copyWith(color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,),
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 320),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    TextFormField(
                      controller: contentController,
                      enabled: !isLoading,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l.pleaseWriteContent
                          : null,
                      maxLines: 3,
                      minLines: 1,
                      maxLength: 120,
                      style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: l.contentText,
                        labelStyle: AppTextStyles.titleSmall.copyWith(color: AppColors.accent),
                        counterStyle: AppTextStyles.titleSmall.copyWith(color: Colors.white38),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDifficulty,
                      dropdownColor: _CustomDeckEditorScreenState._cardColor,
                      decoration: InputDecoration(
                        labelText: l.difficultyLabel,
                        labelStyle: AppTextStyles.titleSmall.copyWith(color: _CustomDeckEditorScreenState._accentGold),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.4),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _CustomDeckEditorScreenState._accentGold.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _CustomDeckEditorScreenState._accentGold),
                        ),
                      ),
                      items:
                          [
                                DropdownMenuItem(
                                  value: 'easy',
                                  child: Text(l.easyDifficulty),
                                ),
                                DropdownMenuItem(
                                  value: 'medium',
                                  child: Text(l.mediumDifficulty),
                                ),
                                DropdownMenuItem(
                                  value: 'hard',
                                  child: Text(l.hardDifficulty),
                                ),
                              ]
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item.value,
                                  child: Text(
                                    (item.child as Text).data!,
                                    style: AppTextStyles.titleSmall.copyWith(color: _CustomDeckEditorScreenState._textLight,),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedDifficulty = v!),
                    ),
                  ],
                ),
              ),
            ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              actions: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
                    foregroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(l.cancel, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (!formKey.currentState!.validate()) return;

                          final content = contentController.text.trim();
                          final task = UserTaskEntity(
                            id:
                                editingTask?.id ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            category: 'Özel',
                            content: content,
                            difficulty: selectedDifficulty,
                            type: TaskType.action,
                            tags: const ['custom'],
                            isActive: true,
                          );

                          final notifier = ref.read(
                            customTaskControllerProvider.notifier,
                          );
                          if (editingTask == null) {
                            notifier.addTask(uid: uid, task: task);
                          } else {
                            notifier.updateTask(uid: uid, task: task);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          editingTask == null ? l.addContent : l.update,
                          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800,),
                        ),
                ),
              ],
                );
              },
            );
          },
        );
      },
    );
  }
}