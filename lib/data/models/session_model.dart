import 'package:hive/hive.dart';
import 'package:gym_mate/data/models/session_exercise_model.dart';

class SessionModel extends HiveObject {
  final String id;
  final String templateId;
  final String templateName;
  final DateTime scheduledDate;
  DateTime? startedAt;
  DateTime? completedAt;
  final List<SessionExerciseModel> exercises;
  String status; // 'scheduled', 'inProgress', 'completed', 'skipped'
  String notes;

  SessionModel({
    required this.id,
    required this.templateId,
    required this.templateName,
    required this.scheduledDate,
    this.startedAt,
    this.completedAt,
    List<SessionExerciseModel>? exercises,
    this.status = 'scheduled',
    this.notes = '',
  }) : exercises = exercises ?? [];

  double get completionPercentage {
    if (exercises.isEmpty) return 0;
    final totalSets = exercises.fold<int>(0, (sum, e) => sum + e.sets.length);
    if (totalSets == 0) return 0;
    final completedSets =
        exercises.fold<int>(0, (sum, e) => sum + e.sets.where((s) => s.isCompleted).length);
    return completedSets / totalSets;
  }

  double get totalVolume {
    double volume = 0;
    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted) {
          volume += set.actualWeight * set.actualReps;
        }
      }
    }
    return volume;
  }

  Duration? get duration {
    if (startedAt == null) return null;
    final end = completedAt ?? DateTime.now();
    return end.difference(startedAt!);
  }

  SessionModel copyWith({
    String? id,
    String? templateId,
    String? templateName,
    DateTime? scheduledDate,
    DateTime? startedAt,
    DateTime? completedAt,
    List<SessionExerciseModel>? exercises,
    String? status,
    String? notes,
  }) {
    return SessionModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      exercises: exercises ?? this.exercises,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

class SessionModelAdapter extends TypeAdapter<SessionModel> {
  @override
  final int typeId = 5;

  @override
  SessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SessionModel(
      id: fields[0] as String,
      templateId: fields[1] as String,
      templateName: fields[2] as String,
      scheduledDate: fields[3] as DateTime,
      startedAt: fields[4] as DateTime?,
      completedAt: fields[5] as DateTime?,
      exercises: (fields[6] as List).cast<SessionExerciseModel>(),
      status: fields[7] as String,
      notes: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SessionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.templateId)
      ..writeByte(2)..write(obj.templateName)
      ..writeByte(3)..write(obj.scheduledDate)
      ..writeByte(4)..write(obj.startedAt)
      ..writeByte(5)..write(obj.completedAt)
      ..writeByte(6)..write(obj.exercises)
      ..writeByte(7)..write(obj.status)
      ..writeByte(8)..write(obj.notes);
  }
}
