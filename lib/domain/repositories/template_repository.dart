import 'package:gym_mate/data/models/models.dart';

abstract class TemplateRepository {
  Future<List<TemplateModel>> getAllTemplates();
  Future<TemplateModel?> getTemplateById(String id);
  Future<void> addTemplate(TemplateModel template);
  Future<void> updateTemplate(TemplateModel template);
  Future<void> deleteTemplate(String id);
  Future<TemplateModel> duplicateTemplate(String id);
  Future<void> renameTemplate(String id, String newName);
  Future<void> archiveTemplate(String id);
  Future<void> unarchiveTemplate(String id);
  Future<List<TemplateModel>> getArchivedTemplates();
}
