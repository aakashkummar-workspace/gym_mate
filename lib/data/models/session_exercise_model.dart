import 'package:hive/hive.dart';
import 'package:gym_mate/data/models/session_set_model.dart';

class SessionExerciseModel extends HiveObject {
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final String equipment;
  final List<SessionSetModel> sets;
  final int restSeconds;
  final int timerSeconds;
  final int order;
  final String notes;
  bool isCompleted;

  SessionExerciseModel({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    List<SessionSetModel>? sets,
    this.restSeconds = 90,
    this.timerSeconds = 0,
    this.order = 0,
    this.notes = '',
    this.isCompleted = false,
  }) : sets = sets ?? [];

  SessionExerciseModel copyWith({
    String? exerciseId,
    String? name,
    String? muscleGroup,
    String? equipment,
    List<SessionSetModel>? sets,
    int? restSeconds,
    int? timerSeconds,
    int? order,
    String? notes,
    bool? isCompleted,
  }) {
    return SessionExerciseModel(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      sets: sets ?? this.sets,
      restSeconds: restSeconds ?? this.restSeconds,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      order: order ?? this.order,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class SessionExerciseModelAdapter extends TypeAdapter<SessionExerciseModel> {
  @override
  final int typeId = 4;

  @override
  SessionExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SessionExerciseModel(
      exerciseId: fields[0] as String,
      name: fields[1] as String,
      muscleGroup: fields[2] as String,
      equipment: fields[3] as String,
      sets: (fields[4] as List).cast<SessionSetModel>(),
      restSeconds: fields[5] as int,
      order: fields[6] as int,
      notes: fields[7] as String,
      isCompleted: fields[8] as bool,
      timerSeconds: fields.containsKey(9) ? fields[9] as int : 0,
    );
  }

  @override
  void write(BinaryWriter writer, SessionExerciseModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)..write(obj.exerciseId)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.muscleGroup)
      ..writeByte(3)..write(obj.equipment)
      ..writeByte(4)..write(obj.sets)
      ..writeByte(5)..write(obj.restSeconds)
      ..writeByte(6)..write(obj.order)
      ..writeByte(7)..write(obj.notes)
      ..writeByte(8)..write(obj.isCompleted)
      ..writeByte(9)..write(obj.timerSeconds);
  }
}
