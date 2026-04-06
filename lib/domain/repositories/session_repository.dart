import 'package:gym_mate/data/models/models.dart';

abstract class SessionRepository {
  Future<List<SessionModel>> getAllSessions();
  Future<SessionModel?> getSessionById(String id);
  Future<SessionModel> createSessionFromTemplate(TemplateModel template, DateTime scheduledDate);
  Future<void> updateSession(SessionModel session);
  Future<void> deleteSession(String id);
  Future<List<SessionModel>> getSessionsByDate(DateTime date);
  Future<List<SessionModel>> getSessionsInRange(DateTime start, DateTime end);
  Future<List<SessionModel>> getCompletedSessions();
  Future<List<SessionModel>> getSessionsByExercise(String exerciseId);
}
