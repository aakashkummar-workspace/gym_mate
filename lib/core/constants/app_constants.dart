class AppConstants {
  AppConstants._();

  // Defaults
  static const int defaultSets = 3;
  static const int defaultReps = 10;
  static const double defaultWeight = 0;
  static const int defaultRestSeconds = 90;

  // Weight increments
  static const double weightIncrement = 2.5;
  static const double weightFastIncrement = 5.0;
  static const int repsFastIncrement = 5;
  static const int restIncrement = 15;

  // Hive Box Names
  static const String exerciseBox = 'exercises';
  static const String templateBox = 'templates';
  static const String sessionBox = 'sessions';
  static const String scheduleBox = 'schedules';
  static const String userBox = 'user';
  static const String recordsBox = 'records';

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}

enum MuscleGroup {
  chest('Chest'),
  back('Back'),
  shoulders('Shoulders'),
  biceps('Biceps'),
  triceps('Triceps'),
  legs('Legs'),
  core('Core'),
  cardio('Cardio'),
  fullBody('Full Body');

  final String displayName;
  const MuscleGroup(this.displayName);
}

enum Equipment {
  barbell('Barbell'),
  dumbbell('Dumbbell'),
  machine('Machine'),
  cable('Cable'),
  bodyweight('Bodyweight'),
  kettlebell('Kettlebell'),
  bands('Bands');

  final String displayName;
  const Equipment(this.displayName);
}

enum Difficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  final String displayName;
  const Difficulty(this.displayName);
}

enum FitnessGoal {
  muscleGain('Muscle Gain'),
  fatLoss('Fat Loss'),
  strength('Strength'),
  endurance('Endurance');

  final String displayName;
  const FitnessGoal(this.displayName);
}

enum SplitType {
  ppl('Push/Pull/Legs'),
  broSplit('Bro Split'),
  upperLower('Upper/Lower'),
  fullBody('Full Body'),
  custom('Custom');

  final String displayName;
  const SplitType(this.displayName);
}
