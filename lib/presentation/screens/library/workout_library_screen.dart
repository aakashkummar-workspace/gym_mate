import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym_mate/core/theme/app_theme.dart';
import 'package:gym_mate/core/constants/app_constants.dart';
import 'package:gym_mate/core/utils/helpers.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/presentation/providers/providers.dart';

final _selectedDifficultyProvider = StateProvider<String?>((ref) => null);

class WorkoutLibraryScreen extends ConsumerStatefulWidget {
  const WorkoutLibraryScreen({super.key});

  @override
  ConsumerState<WorkoutLibraryScreen> createState() => _WorkoutLibraryScreenState();
}

class _WorkoutLibraryScreenState extends ConsumerState<WorkoutLibraryScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExerciseModel> _applyFilters(
    List<ExerciseModel> exercises, {
    required String? muscleGroup,
    required String? equipment,
    required String? difficulty,
  }) {
    var filtered = exercises;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((e) =>
          e.name.toLowerCase().contains(q) ||
          e.muscleGroup.toLowerCase().contains(q) ||
          e.secondaryMuscleGroup.toLowerCase().contains(q) ||
          e.equipment.toLowerCase().contains(q)).toList();
    }
    if (muscleGroup != null) {
      filtered = filtered.where((e) => e.muscleGroup == muscleGroup || e.secondaryMuscleGroup == muscleGroup).toList();
    }
    if (equipment != null) {
      filtered = filtered.where((e) => e.equipment == equipment).toList();
    }
    if (difficulty != null) {
      filtered = filtered.where((e) => e.difficulty == difficulty).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseListProvider);
    final selectedGroup = ref.watch(selectedMuscleGroupProvider);
    final selectedEquip = ref.watch(selectedEquipmentProvider);
    final selectedDiff = ref.watch(_selectedDifficultyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (query) => setState(() => _searchQuery = query),
              ),
            ),
            crossFadeState: _showSearch ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          // Muscle group filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChipWidget(label: 'All', isSelected: selectedGroup == null, onTap: () {
                  ref.read(selectedMuscleGroupProvider.notifier).state = null;
                }),
                ...MuscleGroup.values.map((g) => _FilterChipWidget(
                  label: g.displayName,
                  isSelected: selectedGroup == g.displayName,
                  onTap: () {
                    ref.read(selectedMuscleGroupProvider.notifier).state =
                        selectedGroup == g.displayName ? null : g.displayName;
                  },
                )),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Equipment filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChipWidget(label: 'All Equip', isSelected: selectedEquip == null, color: AppTheme.accent, onTap: () {
                  ref.read(selectedEquipmentProvider.notifier).state = null;
                }),
                ...Equipment.values.map((e) => _FilterChipWidget(
                  label: e.displayName,
                  isSelected: selectedEquip == e.displayName,
                  color: AppTheme.accent,
                  onTap: () {
                    ref.read(selectedEquipmentProvider.notifier).state =
                        selectedEquip == e.displayName ? null : e.displayName;
                  },
                )),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Difficulty filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _DifficultyChip(label: 'Beginner', value: 'beginner', color: AppTheme.success, selected: selectedDiff, onTap: () {
                  ref.read(_selectedDifficultyProvider.notifier).state = selectedDiff == 'beginner' ? null : 'beginner';
                }),
                const SizedBox(width: 8),
                _DifficultyChip(label: 'Intermediate', value: 'intermediate', color: AppTheme.warning, selected: selectedDiff, onTap: () {
                  ref.read(_selectedDifficultyProvider.notifier).state = selectedDiff == 'intermediate' ? null : 'intermediate';
                }),
                const SizedBox(width: 8),
                _DifficultyChip(label: 'Advanced', value: 'advanced', color: AppTheme.error, selected: selectedDiff, onTap: () {
                  ref.read(_selectedDifficultyProvider.notifier).state = selectedDiff == 'advanced' ? null : 'advanced';
                }),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                final filtered = _applyFilters(exercises,
                    muscleGroup: selectedGroup,
                    equipment: selectedEquip,
                    difficulty: selectedDiff);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 56, color: AppTheme.textHint),
                        const SizedBox(height: 16),
                        const Text('No exercises found', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _ExerciseCard3D(exercise: filtered[index])
                        .animate().fadeIn(delay: (20 * index).ms, duration: 250.ms);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExerciseSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExerciseSheet(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedMuscle = MuscleGroup.chest.displayName;
    String selectedEquip = Equipment.barbell.displayName;
    String selectedDiff = 'intermediate';
    int sets = 3, reps = 10, timerSecs = 0;
    double weight = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Custom Exercise', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Exercise name')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedMuscle,
                  decoration: const InputDecoration(labelText: 'Muscle Group'),
                  items: MuscleGroup.values.map((g) => DropdownMenuItem(value: g.displayName, child: Text(g.displayName))).toList(),
                  onChanged: (v) => setModalState(() => selectedMuscle = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedEquip,
                  decoration: const InputDecoration(labelText: 'Equipment'),
                  items: Equipment.values.map((e) => DropdownMenuItem(value: e.displayName, child: Text(e.displayName))).toList(),
                  onChanged: (v) => setModalState(() => selectedEquip = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedDiff,
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  items: const [
                    DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  ],
                  onChanged: (v) => setModalState(() => selectedDiff = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _NumField(label: 'Sets', value: sets, onChanged: (v) => setModalState(() => sets = v))),
                    const SizedBox(width: 12),
                    Expanded(child: _NumField(label: 'Reps', value: reps, onChanged: (v) => setModalState(() => reps = v))),
                    const SizedBox(width: 12),
                    Expanded(child: _NumField(label: 'Weight', value: weight.toInt(), onChanged: (v) => setModalState(() => weight = v.toDouble()))),
                  ],
                ),
                const SizedBox(height: 12),
                _NumField(label: 'Timer (seconds, 0 = none)', value: timerSecs, onChanged: (v) => setModalState(() => timerSecs = v)),
                const SizedBox(height: 12),
                TextField(controller: descController, decoration: const InputDecoration(hintText: 'Description (optional)'), maxLines: 2),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      final exercise = ExerciseModel(
                        id: generateId(),
                        name: nameController.text,
                        muscleGroup: selectedMuscle,
                        equipment: selectedEquip,
                        difficulty: selectedDiff,
                        defaultSets: sets,
                        defaultReps: reps,
                        defaultWeight: weight,
                        defaultTimerSeconds: timerSecs,
                        description: descController.text,
                        isCustom: true,
                      );
                      ref.read(exerciseListProvider.notifier).addExercise(exercise);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Exercise'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChipWidget({required this.label, required this.isSelected, this.color = AppTheme.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : AppTheme.cardBorder, width: 0.5),
          ),
          child: Text(label, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : AppTheme.textSecondary,
          )),
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? selected;
  final VoidCallback onTap;
  const _DifficultyChip({required this.label, required this.value, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : AppTheme.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : AppTheme.cardBorder, width: isSelected ? 1 : 0.5),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: isSelected ? color : AppTheme.textHint,
          )),
        ),
      ),
    );
  }
}

class _ExerciseCard3D extends StatelessWidget {
  final ExerciseModel exercise;
  const _ExerciseCard3D({required this.exercise});

  Color get _difficultyColor {
    switch (exercise.difficulty) {
      case 'beginner': return AppTheme.success;
      case 'advanced': return AppTheme.error;
      default: return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = muscleGroupColor(exercise.muscleGroup);
    final subtitle = [
      exercise.muscleGroup,
      if (exercise.secondaryMuscleGroup.isNotEmpty) exercise.secondaryMuscleGroup,
      exercise.equipment,
    ].join(' · ');

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.card3D,
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(muscleGroupIcon(exercise.muscleGroup), color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: AppTheme.tagDecoration(_difficultyColor),
              child: Text(
                exercise.difficulty[0].toUpperCase() + exercise.difficulty.substring(1),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _difficultyColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(label: exercise.muscleGroup, color: muscleGroupColor(exercise.muscleGroup)),
                if (exercise.secondaryMuscleGroup.isNotEmpty)
                  _Badge(label: exercise.secondaryMuscleGroup, color: muscleGroupColor(exercise.secondaryMuscleGroup)),
                _Badge(label: exercise.equipment, color: AppTheme.accent),
                _Badge(label: exercise.difficulty, color: _difficultyColor),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${exercise.defaultSets} sets × ${exercise.defaultReps} reps @ ${formatWeight(exercise.defaultWeight)}',
              style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
            if (exercise.defaultTimerSeconds > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text('Timer: ${formatDuration(exercise.defaultTimerSeconds)}',
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
            if (exercise.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(exercise.description, style: const TextStyle(color: AppTheme.textSecondary)),
            ],
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 56,
              child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: AppTheme.tagDecoration(color),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _NumField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _NumField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Row(
          children: [
            GestureDetector(
              onTap: () => onChanged((value - 1).clamp(0, 9999)),
              child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.cardBorder)),
                child: const Icon(Icons.remove, size: 16, color: AppTheme.textSecondary)),
            ),
            Expanded(child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            GestureDetector(
              onTap: () => onChanged(value + 1),
              child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add, size: 16, color: AppTheme.primary)),
            ),
          ],
        ),
      ],
    );
  }
}
