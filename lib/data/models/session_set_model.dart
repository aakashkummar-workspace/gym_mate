import 'package:hive/hive.dart';

class SessionSetModel extends HiveObject {
  final int setNumber;
  final int targetReps;
  int actualReps;
  final double targetWeight;
  double actualWeight;
  bool isCompleted;
  DateTime? completedAt;

  SessionSetModel({
    required this.setNumber,
    required this.targetReps,
    int? actualReps,
    required this.targetWeight,
    double? actualWeight,
    this.isCompleted = false,
    this.completedAt,
  })  : actualReps = actualReps ?? targetReps,
        actualWeight = actualWeight ?? targetWeight;

  SessionSetModel copyWith({
    int? setNumber,
    int? targetReps,
    int? actualReps,
    double? targetWeight,
    double? actualWeight,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return SessionSetModel(
      setNumber: setNumber ?? this.setNumber,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      targetWeight: targetWeight ?? this.targetWeight,
      actualWeight: actualWeight ?? this.actualWeight,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class SessionSetModelAdapter extends TypeAdapter<SessionSetModel> {
  @override
  final int typeId = 3;

  @override
  SessionSetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SessionSetModel(
      setNumber: fields[0] as int,
      targetReps: fields[1] as int,
      actualReps: fields[2] as int,
      targetWeight: fields[3] as double,
      actualWeight: fields[4] as double,
      isCompleted: fields[5] as bool,
      completedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SessionSetModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.setNumber)
      ..writeByte(1)..write(obj.targetReps)
      ..writeByte(2)..write(obj.actualReps)
      ..writeByte(3)..write(obj.targetWeight)
      ..writeByte(4)..write(obj.actualWeight)
      ..writeByte(5)..write(obj.isCompleted)
      ..writeByte(6)..write(obj.completedAt);
  }
}
