import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_mate/core/theme/app_theme.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/presentation/providers/providers.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templateListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Templates'),
        actions: [
          TextButton.icon(
            onPressed: () => _showArchivedSheet(context, ref),
            icon: const Icon(Icons.archive_outlined, size: 18),
            label: const Text('Archived', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.cardBorder)),
                    child: const Icon(Icons.dashboard_customize_rounded, size: 36, color: AppTheme.textHint),
                  ),
                  const SizedBox(height: 20),
                  const Text('No templates yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Create your first workout template', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 28),
                  SizedBox(width: 220, height: 52, child: ElevatedButton.icon(
                    onPressed: () => context.push('/templates/create'),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create Template'),
                  )),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              return _TemplateCard3D(template: templates[index])
                  .animate().fadeIn(delay: (50 * index).ms, duration: 300.ms);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/templates/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showArchivedSheet(BuildContext context, WidgetRef ref) async {
    final archived = await ref.read(templateRepositoryProvider).getArchivedTemplates();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Archived Templates', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (archived.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No archived templates', style: TextStyle(color: AppTheme.textHint))),
              )
            else
              ...archived.map((t) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.card3D,
                child: Row(
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${t.exercises.length} exercises', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    )),
                    TextButton(
                      onPressed: () {
                        ref.read(templateListProvider.notifier).unarchiveTemplate(t.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template restored')));
                      },
                      child: const Text('Unarchive'),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard3D extends ConsumerWidget {
  final TemplateModel template;
  const _TemplateCard3D({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppTheme.templateColors[template.colorIndex % AppTheme.templateColors.length];
    final muscleGroups = template.exercises.map((e) => e.muscleGroup).toSet();

    return GestureDetector(
      onTap: () => context.push('/templates/${template.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.card3DColored(color),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.fitness_center_rounded, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: AppTheme.tagDecoration(color),
                        child: Text('${template.exercises.length} exercises', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                      ),
                      const SizedBox(width: 6),
                      ...muscleGroups.take(2).map((g) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: AppTheme.tagDecoration(AppTheme.textSecondary),
                          child: Text(g, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.textHint, size: 20),
              onSelected: (value) {
                switch (value) {
                  case 'edit': context.push('/templates/${template.id}/edit');
                  case 'rename': _showRenameDialog(context, ref);
                  case 'duplicate': ref.read(templateListProvider.notifier).duplicateTemplate(template.id);
                  case 'archive':
                    ref.read(templateListProvider.notifier).archiveTemplate(template.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template archived')));
                  case 'delete': _showDeleteDialog(context, ref);
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'rename', child: Text('Rename')),
                PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                PopupMenuItem(value: 'archive', child: Text('Archive')),
                PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.error))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: template.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Template'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Template name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(templateListProvider.notifier).renameTemplate(template.id, controller.text);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Template?'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { ref.read(templateListProvider.notifier).deleteTemplate(template.id); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, minimumSize: const Size(100, 44)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
