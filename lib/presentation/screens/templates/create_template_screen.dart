import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_mate/core/theme/app_theme.dart';
import 'package:gym_mate/core/utils/helpers.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/presentation/providers/providers.dart';

class CreateTemplateScreen extends ConsumerStatefulWidget {
  final String? templateId;
  const CreateTemplateScreen({super.key, this.templateId});

  @override
  ConsumerState<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends ConsumerState<CreateTemplateScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int _colorIndex = 0;
  List<TemplateExerciseModel> _exercises = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) {
      _isEditing = true;
      _loadTemplate();
    }
  }

  Future<void> _loadTemplate() async {
    final repo = ref.read(templateRepositoryProvider);
    final template = await repo.getTemplateById(widget.templateId!);
    if (template != null && mounted) {
      setState(() {
        _nameController.text = template.name;
        _descController.text = template.description;
        _colorIndex = template.colorIndex;
        _exercises = List.from(template.exercises);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a template name')),
      );
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise')),
      );
      return;
    }

    final orderedExercises = _exercises.asMap().entries.map((e) {
      return e.value.copyWith(order: e.key);
    }).toList();

    final template = TemplateModel(
      id: _isEditing ? widget.templateId! : generateId(),
      name: _nameController.text,
      description: _descController.text,
      exercises: orderedExercises,
      colorIndex: _colorIndex,
    );

    if (_isEditing) {
      ref.read(templateListProvider.notifier).updateTemplate(template);
    } else {
      ref.read(templateListProvider.notifier).addTemplate(template);
    }

    context.pop();
  }

  void _addExerciseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ExercisePicker(
        onSelect: (exercise) {
          setState(() {
            _exercises.add(TemplateExerciseModel(
              exerciseId: exercise.id,
              name: exercise.name,
              muscleGroup: exercise.muscleGroup,
              equipment: exercise.equipment,
              sets: exercise.defaultSets,
              reps: exercise.defaultReps,
              weight: exercise.defaultWeight,
              timerSeconds: exercise.defaultTimerSeconds,
              order: _exercises.length,
            ));
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Template' : 'Create Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template name
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: 'Template Name',
                hintStyle: TextStyle(color: AppTheme.textHint),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Color picker
            const Text('Color', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: AppTheme.templateColors.asMap().entries.map((entry) {
                final isSelected = _colorIndex == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => _colorIndex = entry.key),
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Exercises header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exercises (${_exercises.length})',
                    style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: _addExerciseSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Exercise list
            if (_exercises.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.textHint.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.fitness_center, size: 40, color: AppTheme.textHint),
                    SizedBox(height: 8),
                    Text('No exercises added',
                        style: TextStyle(color: AppTheme.textHint)),
                  ],
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _exercises.removeAt(oldIndex);
                    _exercises.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  return _TemplateExerciseCard(
                    key: ValueKey('${_exercises[index].exerciseId}_$index'),
                    exercise: _exercises[index],
                    onUpdate: (updated) {
                      setState(() => _exercises[index] = updated);
                    },
                    onDelete: () {
                      setState(() => _exercises.removeAt(index));
                    },
                  );
                },
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save Changes' : 'Create Template'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateExerciseCard extends StatelessWidget {
  final TemplateExerciseModel exercise;
  final ValueChanged<TemplateExerciseModel> onUpdate;
  final VoidCallback onDelete;

  const _TemplateExerciseCard({
    super.key,
    required this.exercise,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.drag_handle, color: AppTheme.textHint, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(exercise.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.error, size: 20),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _IncrementControl(
                  label: 'Sets',
                  value: exercise.sets,
                  onDecrement: () =>
                      onUpdate(exercise.copyWith(sets: (exercise.sets - 1).clamp(1, 20))),
                  onIncrement: () =>
                      onUpdate(exercise.copyWith(sets: exercise.sets + 1)),
                ),
                const SizedBox(width: 12),
                _IncrementControl(
                  label: 'Reps',
                  value: exercise.reps,
                  onDecrement: () =>
                      onUpdate(exercise.copyWith(reps: (exercise.reps - 1).clamp(1, 100))),
                  onIncrement: () =>
                      onUpdate(exercise.copyWith(reps: exercise.reps + 1)),
                ),
                const SizedBox(width: 12),
                _IncrementControl(
                  label: 'Weight',
                  value: exercise.weight,
                  suffix: 'kg',
                  step: 2.5,
                  onDecrement: () => onUpdate(
                      exercise.copyWith(weight: (exercise.weight - 2.5).clamp(0, 500))),
                  onIncrement: () =>
                      onUpdate(exercise.copyWith(weight: exercise.weight + 2.5)),
                ),
                const SizedBox(width: 12),
                _IncrementControl(
                  label: 'Rest',
                  value: exercise.restSeconds,
                  suffix: 's',
                  onDecrement: () => onUpdate(exercise.copyWith(
                      restSeconds: (exercise.restSeconds - 15).clamp(0, 600))),
                  onIncrement: () => onUpdate(
                      exercise.copyWith(restSeconds: exercise.restSeconds + 15)),
                ),
              ],
            ),
            if (exercise.timerSeconds > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _IncrementControl(
                    label: 'Timer',
                    value: exercise.timerSeconds,
                    suffix: 's',
                    onDecrement: () => onUpdate(exercise.copyWith(
                        timerSeconds: (exercise.timerSeconds - 15).clamp(0, 3600))),
                    onIncrement: () => onUpdate(
                        exercise.copyWith(timerSeconds: exercise.timerSeconds + 15)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IncrementControl extends StatelessWidget {
  final String label;
  final num value;
  final String suffix;
  final double step;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _IncrementControl({
    required this.label,
    required this.value,
    this.suffix = '',
    this.step = 1,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value is double
        ? (value as double).toStringAsFixed(value == (value as double).roundToDouble() ? 0 : 1)
        : '$value';

    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onDecrement,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.remove, size: 14, color: AppTheme.textSecondary),
                ),
              ),
              Expanded(
                child: Text(
                  '$displayValue$suffix',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: onIncrement,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, size: 14, color: AppTheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExercisePicker extends ConsumerStatefulWidget {
  final ValueChanged<ExerciseModel> onSelect;
  const _ExercisePicker({required this.onSelect});

  @override
  ConsumerState<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends ConsumerState<_ExercisePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                final filtered = _query.isEmpty
                    ? exercises
                    : exercises
                        .where((e) =>
                            e.name.toLowerCase().contains(_query.toLowerCase()) ||
                            e.muscleGroup.toLowerCase().contains(_query.toLowerCase()))
                        .toList();
                return ListView.builder(
                  controller: scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final ex = filtered[i];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: muscleGroupColor(ex.muscleGroup).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(muscleGroupIcon(ex.muscleGroup),
                            color: muscleGroupColor(ex.muscleGroup), size: 20),
                      ),
                      title: Text(ex.name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${ex.muscleGroup} · ${ex.equipment}',
                          style: const TextStyle(fontSize: 12)),
                      onTap: () => widget.onSelect(ex),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }
}
