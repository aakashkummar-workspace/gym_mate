import 'package:gym_mate/data/models/models.dart';

abstract class ExerciseRepository {
  Future<List<ExerciseModel>> getAllExercises();
  Future<ExerciseModel?> getExerciseById(String id);
  Future<void> addExercise(ExerciseModel exercise);
  Future<void> updateExercise(ExerciseModel exercise);
  Future<void> deleteExercise(String id);
  Future<List<ExerciseModel>> searchExercises(String query);
  Future<List<ExerciseModel>> filterByMuscleGroup(String muscleGroup);
  Future<List<ExerciseModel>> filterByEquipment(String equipment);
  Future<List<ExerciseModel>> filterByDifficulty(String difficulty);
  Future<void> seedDefaultExercises();
}
