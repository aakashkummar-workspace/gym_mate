import 'package:hive/hive.dart';

class ScheduleModel extends HiveObject {
  final String id;
  final String templateId;
  final String templateName;
  final int? dayOfWeek; // 1=Mon, 7=Sun (for weekly)
  final DateTime? specificDate; // for one-time
  final String recurrenceType; // 'once', 'weekly', 'alternateDay', 'everyXDays', 'custom'
  final List<int> customDays; // list of dayOfWeek values for custom
  final int repeatEveryXDays; // for 'everyXDays' type
  final bool isActive;
  final DateTime createdAt;

  ScheduleModel({
    required this.id,
    required this.templateId,
    required this.templateName,
    this.dayOfWeek,
    this.specificDate,
    this.recurrenceType = 'once',
    List<int>? customDays,
    this.repeatEveryXDays = 2,
    this.isActive = true,
    DateTime? createdAt,
  })  : customDays = customDays ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool appliesTo(DateTime date) {
    if (!isActive) return false;
    switch (recurrenceType) {
      case 'once':
        if (specificDate == null) return false;
        return specificDate!.year == date.year &&
            specificDate!.month == date.month &&
            specificDate!.day == date.day;
      case 'weekly':
        return dayOfWeek == date.weekday;
      case 'alternateDay':
        if (specificDate == null) return false;
        final diff = date.difference(specificDate!).inDays;
        return diff >= 0 && diff % 2 == 0;
      case 'everyXDays':
        if (specificDate == null || repeatEveryXDays <= 0) return false;
        final diff = date.difference(specificDate!).inDays;
        return diff >= 0 && diff % repeatEveryXDays == 0;
      case 'custom':
        return customDays.contains(date.weekday);
      default:
        return false;
    }
  }

  ScheduleModel copyWith({
    String? id,
    String? templateId,
    String? templateName,
    int? dayOfWeek,
    DateTime? specificDate,
    String? recurrenceType,
    List<int>? customDays,
    int? repeatEveryXDays,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      specificDate: specificDate ?? this.specificDate,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      customDays: customDays ?? this.customDays,
      repeatEveryXDays: repeatEveryXDays ?? this.repeatEveryXDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ScheduleModelAdapter extends TypeAdapter<ScheduleModel> {
  @override
  final int typeId = 6;

  @override
  ScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ScheduleModel(
      id: fields[0] as String,
      templateId: fields[1] as String,
      templateName: fields[2] as String,
      dayOfWeek: fields[3] as int?,
      specificDate: fields[4] as DateTime?,
      recurrenceType: fields[5] as String,
      customDays: (fields[6] as List).cast<int>(),
      isActive: fields[7] as bool,
      createdAt: fields[8] as DateTime,
      repeatEveryXDays: fields.containsKey(9) ? fields[9] as int : 2,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.templateId)
      ..writeByte(2)..write(obj.templateName)
      ..writeByte(3)..write(obj.dayOfWeek)
      ..writeByte(4)..write(obj.specificDate)
      ..writeByte(5)..write(obj.recurrenceType)
      ..writeByte(6)..write(obj.customDays)
      ..writeByte(7)..write(obj.isActive)
      ..writeByte(8)..write(obj.createdAt)
      ..writeByte(9)..write(obj.repeatEveryXDays);
  }
}
