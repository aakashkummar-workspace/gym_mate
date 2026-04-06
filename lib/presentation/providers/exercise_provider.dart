import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/domain/repositories/exercise_repository.dart';
import 'package:gym_mate/presentation/providers/repository_providers.dart';

class ExerciseListNotifier extends StateNotifier<AsyncValue<List<ExerciseModel>>> {
  final ExerciseRepository _repository;

  ExerciseListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExercises();
  }

  Future<void> loadExercises() async {
    try {
      state = const AsyncValue.loading();
      await _repository.seedDefaultExercises();
      final exercises = await _repository.getAllExercises();
      state = AsyncValue.data(exercises);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addExercise(ExerciseModel exercise) async {
    try {
      await _repository.addExercise(exercise);
      await loadExercises();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteExercise(String id) async {
    try {
      await _repository.deleteExercise(id);
      await loadExercises();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> searchExercises(String query) async {
    try {
      if (query.isEmpty) {
        final exercises = await _repository.getAllExercises();
        state = AsyncValue.data(exercises);
      } else {
        final exercises = await _repository.searchExercises(query);
        state = AsyncValue.data(exercises);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> filterByMuscleGroup(String? muscleGroup) async {
    try {
      if (muscleGroup == null) {
        final exercises = await _repository.getAllExercises();
        state = AsyncValue.data(exercises);
      } else {
        final exercises = await _repository.filterByMuscleGroup(muscleGroup);
        state = AsyncValue.data(exercises);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final exerciseListProvider =
    StateNotifierProvider<ExerciseListNotifier, AsyncValue<List<ExerciseModel>>>(
        (ref) {
  return ExerciseListNotifier(ref.watch(exerciseRepositoryProvider));
});

final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedMuscleGroupProvider = StateProvider<String?>((ref) => null);
final selectedEquipmentProvider = StateProvider<String?>((ref) => null);
