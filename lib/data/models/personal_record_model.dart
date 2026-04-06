import 'package:hive/hive.dart';

class PersonalRecordModel extends HiveObject {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final double volume;
  final DateTime date;

  PersonalRecordModel({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.volume,
    required this.date,
  });

  PersonalRecordModel copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    double? weight,
    int? reps,
    double? volume,
    DateTime? date,
  }) {
    return PersonalRecordModel(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      volume: volume ?? this.volume,
      date: date ?? this.date,
    );
  }
}

class PersonalRecordModelAdapter extends TypeAdapter<PersonalRecordModel> {
  @override
  final int typeId = 8;

  @override
  PersonalRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return PersonalRecordModel(
      id: fields[0] as String,
      exerciseId: fields[1] as String,
      exerciseName: fields[2] as String,
      weight: fields[3] as double,
      reps: fields[4] as int,
      volume: fields[5] as double,
      date: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalRecordModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.exerciseId)
      ..writeByte(2)..write(obj.exerciseName)
      ..writeByte(3)..write(obj.weight)
      ..writeByte(4)..write(obj.reps)
      ..writeByte(5)..write(obj.volume)
      ..writeByte(6)..write(obj.date);
  }
}
