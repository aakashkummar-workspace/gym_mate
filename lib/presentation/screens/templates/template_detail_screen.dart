import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_mate/core/theme/app_theme.dart';
import 'package:gym_mate/core/utils/helpers.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/presentation/providers/providers.dart';

class TemplateDetailScreen extends ConsumerWidget {
  final String templateId;
  const TemplateDetailScreen({super.key, required this.templateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templateListProvider);

    return templatesAsync.when(
      data: (templates) {
        final template = templates.where((t) => t.id == templateId).firstOrNull;
        if (template == null) return const Scaffold(body: Center(child: Text('Template not found')));
        return _build(context, ref, template);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primary))),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _build(BuildContext context, WidgetRef ref, TemplateModel template) {
    final color = AppTheme.templateColors[template.colorIndex % AppTheme.templateColors.length];

    return Scaffold(
      appBar: AppBar(
        title: Text(template.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => context.push('/templates/${template.id}/edit')),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'duplicate') { ref.read(templateListProvider.notifier).duplicateTemplate(template.id); context.pop(); }
              else if (v == 'delete') { ref.read(templateListProvider.notifier).deleteTemplate(template.id); context.pop(); }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
              PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.error))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Color strip
          Container(height: 3, decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0)]),
          )),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (template.description.isNotEmpty) ...[
                  Text(template.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                  const SizedBox(height: 16),
                ],
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.card3D,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(icon: Icons.fitness_center, value: '${template.exercises.length}', label: 'Exercises'),
                      Container(width: 0.5, height: 36, color: AppTheme.cardBorder),
                      _Stat(icon: Icons.timer_outlined, value: '~${template.exercises.length * 5}', label: 'Minutes'),
                      Container(width: 0.5, height: 36, color: AppTheme.cardBorder),
                      _Stat(icon: Icons.repeat, value: '${template.exercises.fold<int>(0, (s, e) => s + e.sets)}', label: 'Total Sets'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('EXERCISES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                ...template.exercises.asMap().entries.map((entry) {
                  final ex = entry.value;
                  final exColor = muscleGroupColor(ex.muscleGroup);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.card3D,
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: exColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(muscleGroupIcon(ex.muscleGroup), color: exColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text('${ex.sets} sets  ×  ${ex.reps} reps  @  ${formatWeight(ex.weight)}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: AppTheme.tagDecoration(exColor),
                              child: Text('${ex.restSeconds}s rest', style: TextStyle(fontSize: 11, color: exColor, fontWeight: FontWeight.w600)),
                            ),
                            if (ex.timerSeconds > 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: AppTheme.tagDecoration(AppTheme.primary),
                                child: Text('${ex.timerSeconds}s timer', style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (40 * entry.key).ms);
                }),
                const SizedBox(height: 80),
              ],
            ),
          ),
          // Bottom buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(height: 56, child: OutlinedButton(
                      onPressed: () => context.push('/calendar'),
                      child: const Text('Schedule'),
                    )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(height: 56, child: ElevatedButton(
                      onPressed: () async {
                        final session = await ref.read(sessionRepositoryProvider)
                            .createSessionFromTemplate(template, DateTime.now());
                        if (context.mounted) context.push('/session/${session.id}');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 22),
                          SizedBox(width: 6),
                          Text('Start Workout'),
                        ],
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}
