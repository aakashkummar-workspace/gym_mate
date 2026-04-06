import 'package:hive/hive.dart';

class TemplateExerciseModel extends HiveObject {
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final String equipment;
  final int sets;
  final int reps;
  final double weight;
  final int restSeconds;
  final int timerSeconds; // per-exercise duration timer
  final int order;
  final String notes;

  TemplateExerciseModel({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    this.sets = 3,
    this.reps = 10,
    this.weight = 0,
    this.restSeconds = 90,
    this.timerSeconds = 0,
    this.order = 0,
    this.notes = '',
  });

  TemplateExerciseModel copyWith({
    String? exerciseId,
    String? name,
    String? muscleGroup,
    String? equipment,
    int? sets,
    int? reps,
    double? weight,
    int? restSeconds,
    int? timerSeconds,
    int? order,
    String? notes,
  }) {
    return TemplateExerciseModel(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restSeconds: restSeconds ?? this.restSeconds,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      order: order ?? this.order,
      notes: notes ?? this.notes,
    );
  }
}

class TemplateExerciseModelAdapter extends TypeAdapter<TemplateExerciseModel> {
  @override
  final int typeId = 1;

  @override
  TemplateExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TemplateExerciseModel(
      exerciseId: fields[0] as String,
      name: fields[1] as String,
      muscleGroup: fields[2] as String,
      equipment: fields[3] as String,
      sets: fields[4] as int,
      reps: fields[5] as int,
      weight: fields[6] as double,
      restSeconds: fields[7] as int,
      order: fields[8] as int,
      notes: fields[9] as String,
      timerSeconds: fields.containsKey(10) ? fields[10] as int : 0,
    );
  }

  @override
  void write(BinaryWriter writer, TemplateExerciseModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)..write(obj.exerciseId)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.muscleGroup)
      ..writeByte(3)..write(obj.equipment)
      ..writeByte(4)..write(obj.sets)
      ..writeByte(5)..write(obj.reps)
      ..writeByte(6)..write(obj.weight)
      ..writeByte(7)..write(obj.restSeconds)
      ..writeByte(8)..write(obj.order)
      ..writeByte(9)..write(obj.notes)
      ..writeByte(10)..write(obj.timerSeconds);
  }
}
