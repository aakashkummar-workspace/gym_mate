import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/domain/repositories/user_repository.dart';
import 'package:gym_mate/domain/repositories/template_repository.dart';
import 'package:gym_mate/presentation/providers/repository_providers.dart';
import 'package:gym_mate/core/utils/helpers.dart';

final userProfileProvider = FutureProvider<UserProfileModel?>((ref) async {
  return ref.watch(userRepositoryProvider).getUserProfile();
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(userRepositoryProvider).isOnboardingCompleted();
});

class OnboardingState {
  final int currentStep;
  final String? selectedGoal;
  final String? selectedLevel;
  final String? selectedSplit;
  final String userName;

  const OnboardingState({
    this.currentStep = 0,
    this.selectedGoal,
    this.selectedLevel,
    this.selectedSplit,
    this.userName = '',
  });

  OnboardingState copyWith({
    int? currentStep,
    String? selectedGoal,
    String? selectedLevel,
    String? selectedSplit,
    String? userName,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      selectedSplit: selectedSplit ?? this.selectedSplit,
      userName: userName ?? this.userName,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final UserRepository _repository;
  final TemplateRepository _templateRepository;

  OnboardingNotifier(this._repository, this._templateRepository) : super(const OnboardingState());

  void setGoal(String goal) => state = state.copyWith(selectedGoal: goal);
  void setLevel(String level) => state = state.copyWith(selectedLevel: level);
  void setSplit(String split) => state = state.copyWith(selectedSplit: split);
  void setName(String name) => state = state.copyWith(userName: name);

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void prevStep() {
    if (state.currentStep > 0) state = state.copyWith(currentStep: state.currentStep - 1);
  }

  Future<void> completeOnboarding() async {
    final profile = UserProfileModel(
      id: generateId(),
      name: state.userName,
      goal: state.selectedGoal ?? '',
      experienceLevel: state.selectedLevel ?? '',
      splitPreference: state.selectedSplit ?? '',
      onboardingCompleted: true,
    );
    await _repository.saveUserProfile(profile);

    // Auto-generate starter templates based on split preference
    await _generateStarterTemplates(state.selectedSplit ?? '');
  }

  Future<void> _generateStarterTemplates(String split) async {
    switch (split) {
      case 'ppl':
        await _createTemplate('Push Day', 0, [
          _te('ex_001', 'Barbell Bench Press', 'Chest', 'Barbell', 4, 8, 60),
          _te('ex_002', 'Incline Dumbbell Press', 'Chest', 'Dumbbell', 3, 10, 20),
          _te('ex_011', 'Overhead Press', 'Shoulders', 'Barbell', 4, 8, 40),
          _te('ex_012', 'Lateral Raise', 'Shoulders', 'Dumbbell', 3, 15, 8),
          _te('ex_020', 'Tricep Pushdown', 'Triceps', 'Cable', 3, 12, 25),
          _te('ex_023', 'Dips', 'Triceps', 'Bodyweight', 3, 10, 0),
        ]);
        await _createTemplate('Pull Day', 1, [
          _te('ex_007', 'Barbell Row', 'Back', 'Barbell', 4, 8, 50),
          _te('ex_009', 'Lat Pulldown', 'Back', 'Cable', 3, 10, 50),
          _te('ex_010', 'Seated Cable Row', 'Back', 'Cable', 3, 10, 45),
          _te('ex_014', 'Face Pull', 'Shoulders', 'Cable', 3, 15, 20),
          _te('ex_016', 'Barbell Curl', 'Biceps', 'Barbell', 3, 10, 25),
          _te('ex_018', 'Hammer Curl', 'Biceps', 'Dumbbell', 3, 12, 12),
        ]);
        await _createTemplate('Leg Day', 3, [
          _te('ex_024', 'Barbell Squat', 'Legs', 'Barbell', 4, 8, 70),
          _te('ex_025', 'Leg Press', 'Legs', 'Machine', 3, 10, 100),
          _te('ex_026', 'Romanian Deadlift', 'Legs', 'Barbell', 3, 10, 50),
          _te('ex_028', 'Leg Extension', 'Legs', 'Machine', 3, 12, 40),
          _te('ex_029', 'Leg Curl', 'Legs', 'Machine', 3, 12, 35),
          _te('ex_030', 'Calf Raises', 'Legs', 'Machine', 3, 15, 50),
        ]);
        break;

      case 'broSplit':
        await _createTemplate('Chest Day', 1, [
          _te('ex_001', 'Barbell Bench Press', 'Chest', 'Barbell', 4, 8, 60),
          _te('ex_002', 'Incline Dumbbell Press', 'Chest', 'Dumbbell', 3, 10, 20),
          _te('ex_003', 'Cable Fly', 'Chest', 'Cable', 3, 12, 15),
          _te('ex_005', 'Dumbbell Fly', 'Chest', 'Dumbbell', 3, 12, 12),
          _te('ex_004', 'Push-Ups', 'Chest', 'Bodyweight', 3, 15, 0),
        ]);
        await _createTemplate('Back Day', 2, [
          _te('ex_006', 'Deadlift', 'Back', 'Barbell', 4, 5, 80),
          _te('ex_007', 'Barbell Row', 'Back', 'Barbell', 4, 8, 50),
          _te('ex_008', 'Pull-Ups', 'Back', 'Bodyweight', 3, 8, 0),
          _te('ex_009', 'Lat Pulldown', 'Back', 'Cable', 3, 10, 50),
          _te('ex_010', 'Seated Cable Row', 'Back', 'Cable', 3, 10, 45),
        ]);
        await _createTemplate('Shoulder Day', 3, [
          _te('ex_011', 'Overhead Press', 'Shoulders', 'Barbell', 4, 8, 40),
          _te('ex_012', 'Lateral Raise', 'Shoulders', 'Dumbbell', 3, 15, 8),
          _te('ex_013', 'Front Raise', 'Shoulders', 'Dumbbell', 3, 12, 8),
          _te('ex_015', 'Arnold Press', 'Shoulders', 'Dumbbell', 3, 10, 14),
          _te('ex_014', 'Face Pull', 'Shoulders', 'Cable', 3, 15, 20),
        ]);
        await _createTemplate('Arm Day', 0, [
          _te('ex_016', 'Barbell Curl', 'Biceps', 'Barbell', 3, 10, 25),
          _te('ex_018', 'Hammer Curl', 'Biceps', 'Dumbbell', 3, 12, 12),
          _te('ex_020', 'Tricep Pushdown', 'Triceps', 'Cable', 3, 12, 25),
          _te('ex_021', 'Overhead Tricep Extension', 'Triceps', 'Dumbbell', 3, 10, 15),
          _te('ex_023', 'Dips', 'Triceps', 'Bodyweight', 3, 10, 0),
        ]);
        await _createTemplate('Leg Day', 5, [
          _te('ex_024', 'Barbell Squat', 'Legs', 'Barbell', 4, 8, 70),
          _te('ex_025', 'Leg Press', 'Legs', 'Machine', 3, 10, 100),
          _te('ex_026', 'Romanian Deadlift', 'Legs', 'Barbell', 3, 10, 50),
          _te('ex_028', 'Leg Extension', 'Legs', 'Machine', 3, 12, 40),
          _te('ex_030', 'Calf Raises', 'Legs', 'Machine', 3, 15, 50),
        ]);
        break;

      case 'upperLower':
        await _createTemplate('Upper Body', 4, [
          _te('ex_001', 'Barbell Bench Press', 'Chest', 'Barbell', 4, 8, 60),
          _te('ex_007', 'Barbell Row', 'Back', 'Barbell', 4, 8, 50),
          _te('ex_011', 'Overhead Press', 'Shoulders', 'Barbell', 3, 10, 40),
          _te('ex_009', 'Lat Pulldown', 'Back', 'Cable', 3, 10, 50),
          _te('ex_016', 'Barbell Curl', 'Biceps', 'Barbell', 3, 10, 25),
          _te('ex_020', 'Tricep Pushdown', 'Triceps', 'Cable', 3, 12, 25),
        ]);
        await _createTemplate('Lower Body', 5, [
          _te('ex_024', 'Barbell Squat', 'Legs', 'Barbell', 4, 8, 70),
          _te('ex_026', 'Romanian Deadlift', 'Legs', 'Barbell', 3, 10, 50),
          _te('ex_025', 'Leg Press', 'Legs', 'Machine', 3, 10, 100),
          _te('ex_028', 'Leg Extension', 'Legs', 'Machine', 3, 12, 40),
          _te('ex_029', 'Leg Curl', 'Legs', 'Machine', 3, 12, 35),
          _te('ex_030', 'Calf Raises', 'Legs', 'Machine', 3, 15, 50),
        ]);
        break;

      case 'fullBody':
        await _createTemplate('Full Body A', 0, [
          _te('ex_024', 'Barbell Squat', 'Legs', 'Barbell', 4, 8, 70),
          _te('ex_001', 'Barbell Bench Press', 'Chest', 'Barbell', 4, 8, 60),
          _te('ex_007', 'Barbell Row', 'Back', 'Barbell', 3, 10, 50),
          _te('ex_011', 'Overhead Press', 'Shoulders', 'Barbell', 3, 10, 40),
          _te('ex_016', 'Barbell Curl', 'Biceps', 'Barbell', 3, 10, 25),
        ]);
        await _createTemplate('Full Body B', 6, [
          _te('ex_006', 'Deadlift', 'Back', 'Barbell', 4, 5, 80),
          _te('ex_002', 'Incline Dumbbell Press', 'Chest', 'Dumbbell', 3, 10, 20),
          _te('ex_008', 'Pull-Ups', 'Back', 'Bodyweight', 3, 8, 0),
          _te('ex_012', 'Lateral Raise', 'Shoulders', 'Dumbbell', 3, 15, 8),
          _te('ex_020', 'Tricep Pushdown', 'Triceps', 'Cable', 3, 12, 25),
        ]);
        break;
    }
  }

  Future<void> _createTemplate(String name, int colorIndex, List<TemplateExerciseModel> exercises) async {
    final template = TemplateModel(
      id: generateId(),
      name: name,
      exercises: exercises.asMap().entries.map((e) => e.value.copyWith(order: e.key)).toList(),
      colorIndex: colorIndex,
    );
    await _templateRepository.addTemplate(template);
  }

  TemplateExerciseModel _te(String id, String name, String muscle, String equip, int sets, int reps, double weight) {
    return TemplateExerciseModel(
      exerciseId: id,
      name: name,
      muscleGroup: muscle,
      equipment: equip,
      sets: sets,
      reps: reps,
      weight: weight,
    );
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(
    ref.watch(userRepositoryProvider),
    ref.watch(templateRepositoryProvider),
  );
});
