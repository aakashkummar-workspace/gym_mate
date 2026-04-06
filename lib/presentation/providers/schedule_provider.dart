import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/domain/repositories/schedule_repository.dart';
import 'package:gym_mate/presentation/providers/repository_providers.dart';

class ScheduleNotifier extends StateNotifier<AsyncValue<List<ScheduleModel>>> {
  final ScheduleRepository _repository;

  ScheduleNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    try {
      state = const AsyncValue.loading();
      final schedules = await _repository.getAllSchedules();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      await _repository.addSchedule(schedule);
      await loadSchedules();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await _repository.deleteSchedule(id);
      await loadSchedules();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<ScheduleModel>> getSchedulesForDate(DateTime date) async {
    return _repository.getSchedulesForDate(date);
  }
}

final scheduleListProvider =
    StateNotifierProvider<ScheduleNotifier, AsyncValue<List<ScheduleModel>>>(
        (ref) {
  return ScheduleNotifier(ref.watch(scheduleRepositoryProvider));
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
