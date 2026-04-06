import 'package:hive/hive.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/data/datasources/hive_service.dart';
import 'package:gym_mate/domain/repositories/session_repository.dart';
import 'package:gym_mate/core/utils/helpers.dart';

class SessionRepositoryImpl implements SessionRepository {
  Box<SessionModel> get _box => Hive.box<SessionModel>(HiveService.sessionBox);

  @override
  Future<List<SessionModel>> getAllSessions() async {
    final sessions = _box.values.toList();
    sessions.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    return sessions;
  }

  @override
  Future<SessionModel?> getSessionById(String id) async {
    return _box.get(id);
  }

  @override
  Future<SessionModel> createSessionFromTemplate(
      TemplateModel template, DateTime scheduledDate) async {
    final sessionExercises = template.exercises.map((te) {
      final sets = List.generate(
        te.sets,
        (i) => SessionSetModel(
          setNumber: i + 1,
          targetReps: te.reps,
          targetWeight: te.weight,
        ),
      );
      return SessionExerciseModel(
        exerciseId: te.exerciseId,
        name: te.name,
        muscleGroup: te.muscleGroup,
        equipment: te.equipment,
        sets: sets,
        restSeconds: te.restSeconds,
        timerSeconds: te.timerSeconds,
        order: te.order,
        notes: te.notes,
      );
    }).toList();

    final session = SessionModel(
      id: generateId(),
      templateId: template.id,
      templateName: template.name,
      scheduledDate: scheduledDate,
      exercises: sessionExercises,
    );

    await _box.put(session.id, session);
    return session;
  }

  @override
  Future<void> updateSession(SessionModel session) async {
    await _box.put(session.id, session);
  }

  @override
  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<SessionModel>> getSessionsByDate(DateTime date) async {
    return _box.values
        .where((s) => isSameDay(s.scheduledDate, date))
        .toList();
  }

  @override
  Future<List<SessionModel>> getSessionsInRange(
      DateTime start, DateTime end) async {
    return _box.values.where((s) {
      final d = s.scheduledDate;
      return (d.isAfter(start) || isSameDay(d, start)) &&
          (d.isBefore(end) || isSameDay(d, end));
    }).toList();
  }

  @override
  Future<List<SessionModel>> getCompletedSessions() async {
    final sessions =
        _box.values.where((s) => s.status == 'completed').toList();
    sessions.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    return sessions;
  }

  @override
  Future<List<SessionModel>> getSessionsByExercise(String exerciseId) async {
    return _box.values
        .where(
            (s) => s.exercises.any((e) => e.exerciseId == exerciseId))
        .toList();
  }
}
