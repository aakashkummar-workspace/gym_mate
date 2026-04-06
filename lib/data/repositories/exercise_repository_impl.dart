import 'package:hive/hive.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/data/datasources/hive_service.dart';
import 'package:gym_mate/domain/repositories/exercise_repository.dart';
import 'package:gym_mate/core/constants/exercise_database.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  Box<ExerciseModel> get _box => Hive.box<ExerciseModel>(HiveService.exerciseBox);

  @override
  Future<List<ExerciseModel>> getAllExercises() async {
    final exercises = _box.values.toList();
    exercises.sort((a, b) => a.name.compareTo(b.name));
    return exercises;
  }

  @override
  Future<ExerciseModel?> getExerciseById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> addExercise(ExerciseModel exercise) async {
    await _box.put(exercise.id, exercise);
  }

  @override
  Future<void> updateExercise(ExerciseModel exercise) async {
    await _box.put(exercise.id, exercise);
  }

  @override
  Future<void> deleteExercise(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<ExerciseModel>> searchExercises(String query) async {
    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((e) =>
            e.name.toLowerCase().contains(lowerQuery) ||
            e.muscleGroup.toLowerCase().contains(lowerQuery) ||
            e.secondaryMuscleGroup.toLowerCase().contains(lowerQuery) ||
            e.equipment.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<List<ExerciseModel>> filterByMuscleGroup(String muscleGroup) async {
    return _box.values
        .where((e) => e.muscleGroup == muscleGroup || e.secondaryMuscleGroup == muscleGroup)
        .toList();
  }

  @override
  Future<List<ExerciseModel>> filterByEquipment(String equipment) async {
    return _box.values.where((e) => e.equipment == equipment).toList();
  }

  @override
  Future<List<ExerciseModel>> filterByDifficulty(String difficulty) async {
    return _box.values.where((e) => e.difficulty == difficulty).toList();
  }

  @override
  Future<void> seedDefaultExercises() async {
    // Re-seed if box is empty OR if exercises are missing new fields (difficulty/secondaryMuscle)
    final needsReseed = _box.isEmpty ||
        _box.values.any((e) => e.difficulty.isEmpty && !e.isCustom);
    if (!needsReseed) return;

    for (final data in ExerciseDatabase.defaultExercises) {
      final exercise = ExerciseModel(
        id: data['id'] as String,
        name: data['name'] as String,
        muscleGroup: data['muscleGroup'] as String,
        secondaryMuscleGroup: (data['secondaryMuscleGroup'] as String?) ?? '',
        equipment: data['equipment'] as String,
        difficulty: (data['difficulty'] as String?) ?? 'intermediate',
        defaultSets: data['defaultSets'] as int,
        defaultReps: data['defaultReps'] as int,
        defaultWeight: (data['defaultWeight'] as num).toDouble(),
        defaultTimerSeconds: (data['defaultTimerSeconds'] as int?) ?? 0,
        description: data['description'] as String,
      );
      await _box.put(exercise.id, exercise);
    }
  }
}
