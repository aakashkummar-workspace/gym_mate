import 'package:gym_mate/data/models/models.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleModel>> getAllSchedules();
  Future<void> addSchedule(ScheduleModel schedule);
  Future<void> updateSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(String id);
  Future<List<ScheduleModel>> getSchedulesForDay(int dayOfWeek);
  Future<List<ScheduleModel>> getSchedulesForDate(DateTime date);
}
