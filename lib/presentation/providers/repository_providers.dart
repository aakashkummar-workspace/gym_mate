import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_mate/domain/repositories/repositories.dart';
import 'package:gym_mate/data/repositories/repositories.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl();
});

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepositoryImpl();
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl();
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepositoryImpl();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl();
});
