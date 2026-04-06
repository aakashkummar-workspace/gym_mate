import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/domain/repositories/template_repository.dart';
import 'package:gym_mate/presentation/providers/repository_providers.dart';

class TemplateListNotifier extends StateNotifier<AsyncValue<List<TemplateModel>>> {
  final TemplateRepository _repository;

  TemplateListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    try {
      state = const AsyncValue.loading();
      final templates = await _repository.getAllTemplates();
      state = AsyncValue.data(templates);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTemplate(TemplateModel template) async {
    try {
      await _repository.addTemplate(template);
      await loadTemplates();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTemplate(TemplateModel template) async {
    try {
      await _repository.updateTemplate(template);
      await loadTemplates();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _repository.deleteTemplate(id);
      await loadTemplates();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> duplicateTemplate(String id) async {
    try {
      await _repository.duplicateTemplate(id);
      await loadTemplates();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> renameTemplate(String id, String newName) async {
    try {
      await _repository.renameTemplate(id, newName);
      await loadTemplates();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> archiveTemplate(String id) async {
    try {
      await _repository.archiveTemplate(id);
      await loadTemplates();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unarchiveTemplate(String id) async {
    try {
      await _repository.unarchiveTemplate(id);
      await loadTemplates();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final templateListProvider =
    StateNotifierProvider<TemplateListNotifier, AsyncValue<List<TemplateModel>>>(
        (ref) {
  return TemplateListNotifier(ref.watch(templateRepositoryProvider));
});

final selectedTemplateProvider = StateProvider<TemplateModel?>((ref) => null);
