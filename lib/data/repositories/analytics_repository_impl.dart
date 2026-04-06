import 'package:hive/hive.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/data/datasources/hive_service.dart';
import 'package:gym_mate/domain/repositories/analytics_repository.dart';
import 'package:gym_mate/core/utils/helpers.dart';
import 'package:intl/intl.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  Box<PersonalRecordModel> get _recordsBox =>
      Hive.box<PersonalRecordModel>(HiveService.recordsBox);
  Box<SessionModel> get _sessionsBox =>
      Hive.box<SessionModel>(HiveService.sessionBox);

  @override
  Future<List<PersonalRecordModel>> getPersonalRecords(String exerciseId) async {
    final records = _recordsBox.values
        .where((r) => r.exerciseId == exerciseId)
        .toList();
    records.sort((a, b) => b.weight.compareTo(a.weight));
    return records;
  }

  @override
  Future<void> checkAndUpdatePersonalRecord(
    String exerciseId,
    String exerciseName,
    double weight,
    int reps,
    DateTime date,
  ) async {
    final volume = weight * reps;
    final existingRecords = _recordsBox.values
        .where((r) => r.exerciseId == exerciseId)
        .toList();

    final isNewWeightPR =
        existingRecords.isEmpty || existingRecords.every((r) => r.weight < weight);

    if (isNewWeightPR) {
      final record = PersonalRecordModel(
        id: generateId(),
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        weight: weight,
        reps: reps,
        volume: volume,
        date: date,
      );
      await _recordsBox.put(record.id, record);
    }
  }

  @override
  Future<Map<String, double>> getWeightProgression(
    String exerciseId, {
    int lastNSessions = 10,
  }) async {
    final sessions = _sessionsBox.values
        .where((s) =>
            s.status == 'completed' &&
            s.exercises.any((e) => e.exerciseId == exerciseId))
        .toList();
    sessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    final recent = sessions.length > lastNSessions
        ? sessions.sublist(sessions.length - lastNSessions)
        : sessions;

    final result = <String, double>{};
    for (final session in recent) {
      final exercise = session.exercises.firstWhere(
        (e) => e.exerciseId == exerciseId,
      );
      final maxWeight = exercise.sets
          .where((s) => s.isCompleted)
          .fold<double>(0, (max, s) => s.actualWeight > max ? s.actualWeight : max);
      if (maxWeight > 0) {
        final key = DateFormat('MM/dd').format(session.scheduledDate);
        result[key] = maxWeight;
      }
    }
    return result;
  }

  @override
  Future<Map<String, double>> getVolumeProgression(
    String exerciseId, {
    int lastNSessions = 10,
  }) async {
    final sessions = _sessionsBox.values
        .where((s) =>
            s.status == 'completed' &&
            s.exercises.any((e) => e.exerciseId == exerciseId))
        .toList();
    sessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    final recent = sessions.length > lastNSessions
        ? sessions.sublist(sessions.length - lastNSessions)
        : sessions;

    final result = <String, double>{};
    for (final session in recent) {
      final exercise = session.exercises.firstWhere(
        (e) => e.exerciseId == exerciseId,
      );
      double volume = 0;
      for (final set in exercise.sets) {
        if (set.isCompleted) {
          volume += set.actualWeight * set.actualReps;
        }
      }
      if (volume > 0) {
        final key = DateFormat('MM/dd').format(session.scheduledDate);
        result[key] = volume;
      }
    }
    return result;
  }

  @override
  Future<int> getWorkoutStreak() async {
    final sessions = _sessionsBox.values
        .where((s) => s.status == 'completed')
        .toList();
    sessions.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    if (sessions.isEmpty) return 0;

    int streak = 0;
    var checkDate = DateTime.now();

    // If no workout today, start checking from yesterday
    if (!sessions.any((s) => isSameDay(s.scheduledDate, checkDate))) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final hasWorkout =
          sessions.any((s) => isSameDay(s.scheduledDate, checkDate));
      if (!hasWorkout) break;
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  @override
  Future<Map<String, int>> getWorkoutFrequency({int lastNDays = 30}) async {
    final start = DateTime.now().subtract(Duration(days: lastNDays));
    final sessions = _sessionsBox.values
        .where((s) =>
            s.status == 'completed' && s.scheduledDate.isAfter(start))
        .toList();

    final frequency = <String, int>{};
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (final name in dayNames) {
      frequency[name] = 0;
    }

    for (final session in sessions) {
      final dayName = dayNames[session.scheduledDate.weekday - 1];
      frequency[dayName] = (frequency[dayName] ?? 0) + 1;
    }

    return frequency;
  }

  @override
  Future<double> getCompletionRate({int lastNDays = 30}) async {
    final start = DateTime.now().subtract(Duration(days: lastNDays));
    final sessions =
        _sessionsBox.values.where((s) => s.scheduledDate.isAfter(start)).toList();

    if (sessions.isEmpty) return 0;

    final completed = sessions.where((s) => s.status == 'completed').length;
    return completed / sessions.length;
  }
}
