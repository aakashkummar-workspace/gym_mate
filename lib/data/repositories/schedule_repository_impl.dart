import 'package:hive/hive.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/data/datasources/hive_service.dart';
import 'package:gym_mate/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  Box<ScheduleModel> get _box => Hive.box<ScheduleModel>(HiveService.scheduleBox);

  @override
  Future<List<ScheduleModel>> getAllSchedules() async {
    return _box.values.toList();
  }

  @override
  Future<void> addSchedule(ScheduleModel schedule) async {
    await _box.put(schedule.id, schedule);
  }

  @override
  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _box.put(schedule.id, schedule);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<ScheduleModel>> getSchedulesForDay(int dayOfWeek) async {
    return _box.values.where((s) {
      if (!s.isActive) return false;
      if (s.recurrenceType == 'weekly') return s.dayOfWeek == dayOfWeek;
      if (s.recurrenceType == 'custom') return s.customDays.contains(dayOfWeek);
      return false;
    }).toList();
  }

  @override
  Future<List<ScheduleModel>> getSchedulesForDate(DateTime date) async {
    return _box.values.where((s) => s.appliesTo(date)).toList();
  }
}
