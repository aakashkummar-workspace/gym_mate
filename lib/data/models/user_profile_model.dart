import 'package:hive/hive.dart';

class UserProfileModel extends HiveObject {
  final String id;
  final String name;
  final String goal;
  final String experienceLevel;
  final String splitPreference;
  final bool onboardingCompleted;
  final DateTime createdAt;

  UserProfileModel({
    required this.id,
    this.name = '',
    this.goal = '',
    this.experienceLevel = '',
    this.splitPreference = '',
    this.onboardingCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? goal,
    String? experienceLevel,
    String? splitPreference,
    bool? onboardingCompleted,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      splitPreference: splitPreference ?? this.splitPreference,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 7;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return UserProfileModel(
      id: fields[0] as String,
      name: fields[1] as String,
      goal: fields[2] as String,
      experienceLevel: fields[3] as String,
      splitPreference: fields[4] as String,
      onboardingCompleted: fields[5] as bool,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.goal)
      ..writeByte(3)..write(obj.experienceLevel)
      ..writeByte(4)..write(obj.splitPreference)
      ..writeByte(5)..write(obj.onboardingCompleted)
      ..writeByte(6)..write(obj.createdAt);
  }
}
