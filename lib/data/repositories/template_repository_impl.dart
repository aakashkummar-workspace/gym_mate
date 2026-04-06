import 'package:hive/hive.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/data/datasources/hive_service.dart';
import 'package:gym_mate/domain/repositories/template_repository.dart';
import 'package:gym_mate/core/utils/helpers.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  Box<TemplateModel> get _box => Hive.box<TemplateModel>(HiveService.templateBox);

  @override
  Future<List<TemplateModel>> getAllTemplates() async {
    final templates = _box.values.where((t) => !t.isArchived).toList();
    templates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return templates;
  }

  @override
  Future<TemplateModel?> getTemplateById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> addTemplate(TemplateModel template) async {
    await _box.put(template.id, template);
  }

  @override
  Future<void> updateTemplate(TemplateModel template) async {
    await _box.put(template.id, template.copyWith(updatedAt: DateTime.now()));
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _box.delete(id);
  }

  @override
  Future<TemplateModel> duplicateTemplate(String id) async {
    final original = _box.get(id);
    if (original == null) throw Exception('Template not found');

    final duplicate = TemplateModel(
      id: generateId(),
      name: '${original.name} (Copy)',
      description: original.description,
      exercises: original.exercises
          .map((e) => TemplateExerciseModel(
                exerciseId: e.exerciseId,
                name: e.name,
                muscleGroup: e.muscleGroup,
                equipment: e.equipment,
                sets: e.sets,
                reps: e.reps,
                weight: e.weight,
                restSeconds: e.restSeconds,
                timerSeconds: e.timerSeconds,
                order: e.order,
                notes: e.notes,
              ))
          .toList(),
      colorIndex: original.colorIndex,
    );

    await _box.put(duplicate.id, duplicate);
    return duplicate;
  }

  @override
  Future<void> renameTemplate(String id, String newName) async {
    final template = _box.get(id);
    if (template == null) return;
    await _box.put(id, template.copyWith(name: newName));
  }

  @override
  Future<void> archiveTemplate(String id) async {
    final template = _box.get(id);
    if (template == null) return;
    await _box.put(id, template.copyWith(isArchived: true));
  }

  @override
  Future<void> unarchiveTemplate(String id) async {
    final template = _box.get(id);
    if (template == null) return;
    await _box.put(id, template.copyWith(isArchived: false));
  }

  @override
  Future<List<TemplateModel>> getArchivedTemplates() async {
    return _box.values.where((t) => t.isArchived).toList();
  }
}
