import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/presentation/providers/repository_providers.dart';

final weightProgressionProvider =
    FutureProvider.family<Map<String, double>, String>((ref, exerciseId) async {
  return ref.watch(analyticsRepositoryProvider).getWeightProgression(exerciseId);
});

final volumeProgressionProvider =
    FutureProvider.family<Map<String, double>, String>((ref, exerciseId) async {
  return ref.watch(analyticsRepositoryProvider).getVolumeProgression(exerciseId);
});

final workoutStreakProvider = FutureProvider<int>((ref) async {
  return ref.watch(analyticsRepositoryProvider).getWorkoutStreak();
});

final completionRateProvider = FutureProvider<double>((ref) async {
  return ref.watch(analyticsRepositoryProvider).getCompletionRate();
});

final personalRecordsProvider =
    FutureProvider.family<List<PersonalRecordModel>, String>(
        (ref, exerciseId) async {
  return ref.watch(analyticsRepositoryProvider).getPersonalRecords(exerciseId);
});

final workoutFrequencyProvider =
    FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(analyticsRepositoryProvider).getWorkoutFrequency();
});
