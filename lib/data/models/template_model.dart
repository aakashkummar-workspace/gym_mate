import 'package:hive/hive.dart';
import 'package:gym_mate/data/models/template_exercise_model.dart';

class TemplateModel extends HiveObject {
  final String id;
  final String name;
  final String description;
  final List<TemplateExerciseModel> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int colorIndex;
  final bool isArchived;

  TemplateModel({
    required this.id,
    required this.name,
    this.description = '',
    List<TemplateExerciseModel>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.colorIndex = 0,
    this.isArchived = false,
  })  : exercises = exercises ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    List<TemplateExerciseModel>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? colorIndex,
    bool? isArchived,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      colorIndex: colorIndex ?? this.colorIndex,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class TemplateModelAdapter extends TypeAdapter<TemplateModel> {
  @override
  final int typeId = 2;

  @override
  TemplateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TemplateModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      exercises: (fields[3] as List).cast<TemplateExerciseModel>(),
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      colorIndex: fields[6] as int,
      isArchived: fields.containsKey(7) ? fields[7] as bool : false,
    );
  }

  @override
  void write(BinaryWriter writer, TemplateModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.description)
      ..writeByte(3)..write(obj.exercises)
      ..writeByte(4)..write(obj.createdAt)
      ..writeByte(5)..write(obj.updatedAt)
      ..writeByte(6)..write(obj.colorIndex)
      ..writeByte(7)..write(obj.isArchived);
  }
}
