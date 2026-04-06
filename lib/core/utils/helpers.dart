import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String generateId() => _uuid.v4();

String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

String formatElapsedTime(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String formatWeight(double weight) {
  if (weight == weight.roundToDouble()) {
    return '${weight.toInt()} kg';
  }
  return '${weight.toStringAsFixed(1)} kg';
}

double calculateVolume(double weight, int sets, int reps) {
  return weight * sets * reps;
}

String getDayName(DateTime date) {
  return DateFormat('EEEE').format(date);
}

String getShortDayName(DateTime date) {
  return DateFormat('EEE').format(date);
}

String getRelativeDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  return DateFormat('EEE').format(date);
}

String formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

String formatDateShort(DateTime date) {
  return DateFormat('MMM d').format(date);
}

String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

IconData muscleGroupIcon(String muscleGroup) {
  switch (muscleGroup.toLowerCase()) {
    case 'chest':
      return Icons.airline_seat_flat;
    case 'back':
      return Icons.accessibility_new;
    case 'shoulders':
      return Icons.arrow_upward;
    case 'biceps':
      return Icons.fitness_center;
    case 'triceps':
      return Icons.fitness_center;
    case 'legs':
      return Icons.directions_walk;
    case 'core':
      return Icons.circle_outlined;
    case 'cardio':
      return Icons.favorite;
    case 'full body':
      return Icons.person;
    default:
      return Icons.fitness_center;
  }
}

Color muscleGroupColor(String muscleGroup) {
  switch (muscleGroup.toLowerCase()) {
    case 'chest':
      return const Color(0xFFFF6B6B);
    case 'back':
      return const Color(0xFF6C63FF);
    case 'shoulders':
      return const Color(0xFFFF9800);
    case 'biceps':
      return const Color(0xFF4CAF50);
    case 'triceps':
      return const Color(0xFF2196F3);
    case 'legs':
      return const Color(0xFFE91E63);
    case 'core':
      return const Color(0xFFFFC107);
    case 'cardio':
      return const Color(0xFFFF5252);
    case 'full body':
      return const Color(0xFF00BCD4);
    default:
      return const Color(0xFF9E9E9E);
  }
}
