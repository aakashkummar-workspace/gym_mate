class ExerciseDatabase {
  ExerciseDatabase._();

  static const List<Map<String, dynamic>> defaultExercises = [
    // ── Chest ──
    {'id': 'ex_001', 'name': 'Barbell Bench Press', 'muscleGroup': 'Chest', 'secondaryMuscleGroup': 'Triceps', 'equipment': 'Barbell', 'difficulty': 'intermediate', 'defaultSets': 4, 'defaultReps': 8, 'defaultWeight': 60.0, 'description': 'Lie on bench, grip barbell slightly wider than shoulder width, lower to chest and press up.'},
    {'id': 'ex_002', 'name': 'Incline Dumbbell Press', 'muscleGroup': 'Chest', 'secondaryMuscleGroup': 'Shoulders', 'equipment': 'Dumbbell', 'difficulty': 'intermediate', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 20.0, 'description': 'Set bench to 30-45 degrees, press dumbbells from chest level upward.'},
    {'id': 'ex_003', 'name': 'Cable Fly', 'muscleGroup': 'Chest', 'secondaryMuscleGroup': '', 'equipment': 'Cable', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 15.0, 'description': 'Stand between cable towers, bring handles together in front of chest with slight elbow bend.'},
    {'id': 'ex_004', 'name': 'Push-Ups', 'muscleGroup': 'Chest', 'secondaryMuscleGroup': 'Triceps', 'equipment': 'Bodyweight', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 15, 'defaultWeight': 0.0, 'description': 'Classic push-up with hands shoulder-width apart.'},
    {'id': 'ex_005', 'name': 'Dumbbell Fly', 'muscleGroup': 'Chest', 'secondaryMuscleGroup': '', 'equipment': 'Dumbbell', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 12.0, 'description': 'Lie on flat bench, open arms wide with slight elbow bend, squeeze dumbbells together.'},

    // ── Back ──
    {'id': 'ex_006', 'name': 'Deadlift', 'muscleGroup': 'Back', 'secondaryMuscleGroup': 'Legs', 'equipment': 'Barbell', 'difficulty': 'advanced', 'defaultSets': 4, 'defaultReps': 5, 'defaultWeight': 80.0, 'description': 'Hinge at hips, grip barbell, drive through heels to stand. Keep back straight.'},
    {'id': 'ex_007', 'name': 'Barbell Row', 'muscleGroup': 'Back', 'secondaryMuscleGroup': 'Biceps', 'equipment': 'Barbell', 'difficulty': 'intermediate', 'defaultSets': 4, 'defaultReps': 8, 'defaultWeight': 50.0, 'description': 'Bend over with flat back, row barbell to lower chest.'},
    {'id': 'ex_008', 'name': 'Pull-Ups', 'muscleGroup': 'Back', 'secondaryMuscleGroup': 'Biceps', 'equipment': 'Bodyweight', 'difficulty': 'intermediate', 'defaultSets': 3, 'defaultReps': 8, 'defaultWeight': 0.0, 'description': 'Hang from bar with overhand grip, pull chin above bar.'},
    {'id': 'ex_009', 'name': 'Lat Pulldown', 'muscleGroup': 'Back', 'secondaryMuscleGroup': 'Biceps', 'equipment': 'Cable', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 50.0, 'description': 'Sit at lat pulldown machine, pull bar to upper chest with wide grip.'},
    {'id': 'ex_010', 'name': 'Seated Cable Row', 'muscleGroup': 'Back', 'secondaryMuscleGroup': 'Biceps', 'equipment': 'Cable', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 45.0, 'description': 'Sit with feet on platform, row cable handle to torso.'},

    // ── Shoulders ──
    {'id': 'ex_011', 'name': 'Overhead Press', 'muscleGroup': 'Shoulders', 'secondaryMuscleGroup': 'Triceps', 'equipment': 'Barbell', 'difficulty': 'intermediate', 'defaultSets': 4, 'defaultReps': 8, 'defaultWeight': 40.0, 'description': 'Press barbell overhead from shoulder level to full lockout.'},
    {'id': 'ex_012', 'name': 'Lateral Raise', 'muscleGroup': 'Shoulders', 'secondaryMuscleGroup': '', 'equipment': 'Dumbbell', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 15, 'defaultWeight': 8.0, 'description': 'Raise dumbbells out to sides until parallel with floor.'},
    {'id': 'ex_013', 'name': 'Front Raise', 'muscleGroup': 'Shoulders', 'secondaryMuscleGroup': '', 'equipment': 'Dumbbell', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 8.0, 'description': 'Raise dumbbells in front to shoulder height alternately.'},
    {'id': 'ex_014', 'name': 'Face Pull', 'muscleGroup': 'Shoulders', 'secondaryMuscleGroup': 'Back', 'equipment': 'Cable', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 15, 'defaultWeight': 20.0, 'description': 'Pull rope attachment to face level, squeezing rear delts.'},
    {'id': 'ex_015', 'name': 'Arnold Press', 'muscleGroup': 'Shoulders', 'secondaryMuscleGroup': 'Triceps', 'equipment': 'Dumbbell', 'difficulty': 'intermediate', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 14.0, 'description': 'Rotating dumbbell press starting with palms facing you.'},

    // ── Biceps ──
    {'id': 'ex_016', 'name': 'Barbell Curl', 'muscleGroup': 'Biceps', 'secondaryMuscleGroup': '', 'equipment': 'Barbell', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 25.0, 'description': 'Curl barbell with shoulder-width grip, keeping elbows at sides.'},
    {'id': 'ex_017', 'name': 'Dumbbell Curl', 'muscleGroup': 'Biceps', 'secondaryMuscleGroup': '', 'equipment': 'Dumbbell', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 12.0, 'description': 'Alternating dumbbell curls with supinated grip.'},
    {'id': 'ex_018', 'name': 'Hammer Curl', 'muscleGroup': 'Biceps', 'secondaryMuscleGroup': '', 'equipment': 'Dumbbell', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 12.0, 'description': 'Curl dumbbells with neutral grip (palms facing each other).'},
    {'id': 'ex_019', 'name': 'Cable Curl', 'muscleGroup': 'Biceps', 'secondaryMuscleGroup': '', 'equipment': 'Cable', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 20.0, 'description': 'Curl cable bar attachment with constant tension.'},

    // ── Triceps ──
    {'id': 'ex_020', 'name': 'Tricep Pushdown', 'muscleGroup': 'Triceps', 'secondaryMuscleGroup': '', 'equipment': 'Cable', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 25.0, 'description': 'Push cable bar down from chest level, extending arms fully.'},
    {'id': 'ex_021', 'name': 'Overhead Tricep Extension', 'muscleGroup': 'Triceps', 'secondaryMuscleGroup': '', 'equipment': 'Dumbbell', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 15.0, 'description': 'Hold dumbbell overhead with both hands, lower behind head and extend.'},
    {'id': 'ex_022', 'name': 'Close Grip Bench Press', 'muscleGroup': 'Triceps', 'secondaryMuscleGroup': 'Chest', 'equipment': 'Barbell', 'difficulty': 'intermediate', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 40.0, 'description': 'Bench press with narrow grip to target triceps.'},
    {'id': 'ex_023', 'name': 'Dips', 'muscleGroup': 'Triceps', 'secondaryMuscleGroup': 'Chest', 'equipment': 'Bodyweight', 'difficulty': 'intermediate', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 0.0, 'description': 'Lower body between parallel bars, push back up.'},

    // ── Legs ──
    {'id': 'ex_024', 'name': 'Barbell Squat', 'muscleGroup': 'Legs', 'secondaryMuscleGroup': 'Core', 'equipment': 'Barbell', 'difficulty': 'advanced', 'defaultSets': 4, 'defaultReps': 8, 'defaultWeight': 70.0, 'description': 'Bar on upper back, squat below parallel, drive up through heels.'},
    {'id': 'ex_025', 'name': 'Leg Press', 'muscleGroup': 'Legs', 'secondaryMuscleGroup': '', 'equipment': 'Machine', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 100.0, 'description': 'Push platform away with feet shoulder-width apart.'},
    {'id': 'ex_026', 'name': 'Romanian Deadlift', 'muscleGroup': 'Legs', 'secondaryMuscleGroup': 'Back', 'equipment': 'Barbell', 'difficulty': 'intermediate', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 50.0, 'description': 'Hinge at hips with slight knee bend, lower bar along shins.'},
    {'id': 'ex_027', 'name': 'Walking Lunges', 'muscleGroup': 'Legs', 'secondaryMuscleGroup': 'Core', 'equipment': 'Dumbbell', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 15.0, 'description': 'Step forward into lunge, alternating legs.'},
    {'id': 'ex_028', 'name': 'Leg Extension', 'muscleGroup': 'Legs', 'secondaryMuscleGroup': '', 'equipment': 'Machine', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 40.0, 'description': 'Extend legs from seated position on machine.'},
    {'id': 'ex_029', 'name': 'Leg Curl', 'muscleGroup': 'Legs', 'secondaryMuscleGroup': '', 'equipment': 'Machine', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 35.0, 'description': 'Curl legs from lying or seated position on machine.'},
    {'id': 'ex_030', 'name': 'Calf Raises', 'muscleGroup': 'Legs', 'secondaryMuscleGroup': '', 'equipment': 'Machine', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 15, 'defaultWeight': 50.0, 'description': 'Rise onto toes from standing position.'},
    {'id': 'ex_031', 'name': 'Bulgarian Split Squat', 'muscleGroup': 'Legs', 'secondaryMuscleGroup': 'Core', 'equipment': 'Dumbbell', 'difficulty': 'intermediate', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 12.0, 'description': 'Rear foot elevated on bench, squat on front leg.'},

    // ── Core ──
    {'id': 'ex_032', 'name': 'Plank', 'muscleGroup': 'Core', 'secondaryMuscleGroup': 'Shoulders', 'equipment': 'Bodyweight', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 1, 'defaultWeight': 0.0, 'defaultTimerSeconds': 60, 'description': 'Hold forearm plank position for 30-60 seconds per set.'},
    {'id': 'ex_033', 'name': 'Cable Crunch', 'muscleGroup': 'Core', 'secondaryMuscleGroup': '', 'equipment': 'Cable', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 15, 'defaultWeight': 30.0, 'description': 'Kneel facing cable, crunch downward against resistance.'},
    {'id': 'ex_034', 'name': 'Hanging Leg Raise', 'muscleGroup': 'Core', 'secondaryMuscleGroup': '', 'equipment': 'Bodyweight', 'difficulty': 'intermediate', 'defaultSets': 3, 'defaultReps': 12, 'defaultWeight': 0.0, 'description': 'Hang from bar, raise legs to 90 degrees.'},
    {'id': 'ex_035', 'name': 'Russian Twist', 'muscleGroup': 'Core', 'secondaryMuscleGroup': '', 'equipment': 'Bodyweight', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 20, 'defaultWeight': 0.0, 'description': 'Sit with feet elevated, rotate torso side to side.'},
    {'id': 'ex_036', 'name': 'Ab Wheel Rollout', 'muscleGroup': 'Core', 'secondaryMuscleGroup': 'Shoulders', 'equipment': 'Bodyweight', 'difficulty': 'intermediate', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 0.0, 'description': 'Roll ab wheel forward from kneeling, extend and return.'},

    // ── Cardio ──
    {'id': 'ex_037', 'name': 'Treadmill Run', 'muscleGroup': 'Cardio', 'secondaryMuscleGroup': 'Legs', 'equipment': 'Machine', 'difficulty': 'beginner', 'defaultSets': 1, 'defaultReps': 1, 'defaultWeight': 0.0, 'defaultTimerSeconds': 1200, 'description': 'Steady-state or interval running on treadmill.'},
    {'id': 'ex_038', 'name': 'Rowing Machine', 'muscleGroup': 'Cardio', 'secondaryMuscleGroup': 'Back', 'equipment': 'Machine', 'difficulty': 'beginner', 'defaultSets': 1, 'defaultReps': 1, 'defaultWeight': 0.0, 'defaultTimerSeconds': 600, 'description': 'Full-body cardio on rowing ergometer.'},
    {'id': 'ex_039', 'name': 'Jump Rope', 'muscleGroup': 'Cardio', 'secondaryMuscleGroup': 'Legs', 'equipment': 'Bodyweight', 'difficulty': 'beginner', 'defaultSets': 3, 'defaultReps': 1, 'defaultWeight': 0.0, 'defaultTimerSeconds': 120, 'description': 'Skip rope for 1-3 minutes per set.'},
    {'id': 'ex_040', 'name': 'Burpees', 'muscleGroup': 'Cardio', 'secondaryMuscleGroup': 'Full Body', 'equipment': 'Bodyweight', 'difficulty': 'intermediate', 'defaultSets': 3, 'defaultReps': 10, 'defaultWeight': 0.0, 'description': 'Full-body explosive movement: squat, plank, push-up, jump.'},
  ];
}
