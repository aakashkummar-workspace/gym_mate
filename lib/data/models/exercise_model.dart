import 'package:hive/hive.dart';

class ExerciseModel extends HiveObject {
  final String id;
  final String name;
  final String muscleGroup;
  final String secondaryMuscleGroup;
  final String equipment;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final int defaultSets;
  final int defaultReps;
  final double defaultWeight;
  final int defaultTimerSeconds; // per-exercise duration timer
  final String description;
  final bool isCustom;
  final DateTime createdAt;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscleGroup = '',
    required this.equipment,
    this.difficulty = 'intermediate',
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.defaultWeight = 0,
    this.defaultTimerSeconds = 0,
    this.description = '',
    this.isCustom = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    String? secondaryMuscleGroup,
    String? equipment,
    String? difficulty,
    int? defaultSets,
    int? defaultReps,
    double? defaultWeight,
    int? defaultTimerSeconds,
    String? description,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup ?? this.secondaryMuscleGroup,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      defaultTimerSeconds: defaultTimerSeconds ?? this.defaultTimerSeconds,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ExerciseModelAdapter extends TypeAdapter<ExerciseModel> {
  @override
  final int typeId = 0;

  @override
  ExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ExerciseModel(
      id: fields[0] as String,
      name: fields[1] as String,
      muscleGroup: fields[2] as String,
      equipment: fields[3] as String,
      defaultSets: fields[4] as int,
      defaultReps: fields[5] as int,
      defaultWeight: fields[6] as double,
      description: fields[7] as String,
      isCustom: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      secondaryMuscleGroup: fields.containsKey(10) ? fields[10] as String : '',
      difficulty: fields.containsKey(11) ? fields[11] as String : 'intermediate',
      defaultTimerSeconds: fields.containsKey(12) ? fields[12] as int : 0,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.muscleGroup)
      ..writeByte(3)..write(obj.equipment)
      ..writeByte(4)..write(obj.defaultSets)
      ..writeByte(5)..write(obj.defaultReps)
      ..writeByte(6)..write(obj.defaultWeight)
      ..writeByte(7)..write(obj.description)
      ..writeByte(8)..write(obj.isCustom)
      ..writeByte(9)..write(obj.createdAt)
      ..writeByte(10)..write(obj.secondaryMuscleGroup)
      ..writeByte(11)..write(obj.difficulty)
      ..writeByte(12)..write(obj.defaultTimerSeconds);
  }
}
