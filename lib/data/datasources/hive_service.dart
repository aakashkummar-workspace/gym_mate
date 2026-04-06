import 'package:hive_flutter/hive_flutter.dart';
import 'package:gym_mate/data/models/models.dart';

class HiveService {
  static const String exerciseBox = 'exercises';
  static const String templateBox = 'templates';
  static const String sessionBox = 'sessions';
  static const String scheduleBox = 'schedules';
  static const String userBox = 'user';
  static const String recordsBox = 'records';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ExerciseModelAdapter());
    Hive.registerAdapter(TemplateExerciseModelAdapter());
    Hive.registerAdapter(TemplateModelAdapter());
    Hive.registerAdapter(SessionSetModelAdapter());
    Hive.registerAdapter(SessionExerciseModelAdapter());
    Hive.registerAdapter(SessionModelAdapter());
    Hive.registerAdapter(ScheduleModelAdapter());
    Hive.registerAdapter(UserProfileModelAdapter());
    Hive.registerAdapter(PersonalRecordModelAdapter());

    await Hive.openBox<ExerciseModel>(exerciseBox);
    await Hive.openBox<TemplateModel>(templateBox);
    await Hive.openBox<SessionModel>(sessionBox);
    await Hive.openBox<ScheduleModel>(scheduleBox);
    await Hive.openBox<UserProfileModel>(userBox);
    await Hive.openBox<PersonalRecordModel>(recordsBox);
  }
}
