import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/domain/repositories/session_repository.dart';
import 'package:gym_mate/presentation/providers/repository_providers.dart';

class ActiveSessionNotifier extends StateNotifier<SessionModel?> {
  final SessionRepository _repository;

  ActiveSessionNotifier(this._repository) : super(null);

  Future<void> loadSession(String id) async {
    state = await _repository.getSessionById(id);
  }

  Future<void> startSession(SessionModel session) async {
    final started = session.copyWith(
      status: 'inProgress',
      startedAt: DateTime.now(),
    );
    await _repository.updateSession(started);
    state = started;
  }

  void updateSet(int exerciseIndex, int setIndex, {int? reps, double? weight}) {
    if (state == null) return;
    final exercises = List<SessionExerciseModel>.from(state!.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<SessionSetModel>.from(exercise.sets);
    final currentSet = sets[setIndex];

    sets[setIndex] = currentSet.copyWith(
      actualReps: reps ?? currentSet.actualReps,
      actualWeight: weight ?? currentSet.actualWeight,
    );

    exercises[exerciseIndex] = exercise.copyWith(sets: sets);
    state = state!.copyWith(exercises: exercises);
  }

  void toggleSetComplete(int exerciseIndex, int setIndex) {
    if (state == null) return;
    final exercises = List<SessionExerciseModel>.from(state!.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<SessionSetModel>.from(exercise.sets);
    final currentSet = sets[setIndex];

    sets[setIndex] = currentSet.copyWith(
      isCompleted: !currentSet.isCompleted,
      completedAt: !currentSet.isCompleted ? DateTime.now() : null,
    );

    exercises[exerciseIndex] = exercise.copyWith(sets: sets);

    // Check if all sets in exercise are completed
    final allSetsComplete = sets.every((s) => s.isCompleted);
    if (allSetsComplete) {
      exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(isCompleted: true);
    }

    state = state!.copyWith(exercises: exercises);
    _repository.updateSession(state!);
  }

  void addSet(int exerciseIndex) {
    if (state == null) return;
    final exercises = List<SessionExerciseModel>.from(state!.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<SessionSetModel>.from(exercise.sets);

    final lastSet = sets.isNotEmpty ? sets.last : null;
    sets.add(SessionSetModel(
      setNumber: sets.length + 1,
      targetReps: lastSet?.targetReps ?? 10,
      actualReps: lastSet?.actualReps ?? 10,
      targetWeight: lastSet?.targetWeight ?? 0,
      actualWeight: lastSet?.actualWeight ?? 0,
    ));

    exercises[exerciseIndex] = exercise.copyWith(sets: sets);
    state = state!.copyWith(exercises: exercises);
  }

  Future<void> completeSession() async {
    if (state == null) return;
    final completed = state!.copyWith(
      status: 'completed',
      completedAt: DateTime.now(),
    );
    await _repository.updateSession(completed);
    state = completed;
  }

  double getCompletionPercentage() {
    return state?.completionPercentage ?? 0;
  }

  Future<void> saveProgress() async {
    if (state != null) {
      await _repository.updateSession(state!);
    }
  }
}

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, SessionModel?>((ref) {
  return ActiveSessionNotifier(ref.watch(sessionRepositoryProvider));
});

final sessionsForDateProvider =
    FutureProvider.family<List<SessionModel>, DateTime>((ref, date) async {
  return ref.watch(sessionRepositoryProvider).getSessionsByDate(date);
});

final allSessionsProvider = FutureProvider<List<SessionModel>>((ref) async {
  return ref.watch(sessionRepositoryProvider).getAllSessions();
});

final completedSessionsProvider =
    FutureProvider<List<SessionModel>>((ref) async {
  return ref.watch(sessionRepositoryProvider).getCompletedSessions();
});
