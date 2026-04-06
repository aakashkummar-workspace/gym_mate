import 'package:gym_mate/data/models/models.dart';

abstract class AnalyticsRepository {
  Future<List<PersonalRecordModel>> getPersonalRecords(String exerciseId);
  Future<void> checkAndUpdatePersonalRecord(
      String exerciseId, String exerciseName, double weight, int reps, DateTime date);
  Future<Map<String, double>> getWeightProgression(String exerciseId, {int lastNSessions = 10});
  Future<Map<String, double>> getVolumeProgression(String exerciseId, {int lastNSessions = 10});
  Future<int> getWorkoutStreak();
  Future<Map<String, int>> getWorkoutFrequency({int lastNDays = 30});
  Future<double> getCompletionRate({int lastNDays = 30});
}
