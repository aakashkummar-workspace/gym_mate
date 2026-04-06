import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_mate/core/theme/app_theme.dart';
import 'package:gym_mate/core/utils/helpers.dart';
import 'package:gym_mate/presentation/providers/providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String? _selectedExerciseId;

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(workoutStreakProvider);
    final rate = ref.watch(completionRateProvider);
    final completedSessions = ref.watch(completedSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(
            children: [
              _SummaryCard(
                icon: Icons.local_fire_department,
                iconColor: AppTheme.secondary,
                title: 'Streak',
                value: streak.when(
                  data: (s) => '$s days',
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                icon: Icons.pie_chart,
                iconColor: AppTheme.success,
                title: 'Completion',
                value: rate.when(
                  data: (r) => '${(r * 100).toInt()}%',
                  loading: () => '...',
                  error: (_, __) => '0%',
                ),
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                icon: Icons.fitness_center,
                iconColor: AppTheme.primary,
                title: 'Workouts',
                value: completedSessions.when(
                  data: (s) => '${s.length}',
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // Exercise selector
          const Text('Track Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _ExerciseSelector(
            selectedId: _selectedExerciseId,
            onSelect: (id) {
              setState(() {
                _selectedExerciseId = id;
              });
            },
          ),

          if (_selectedExerciseId != null) ...[
            const SizedBox(height: 24),
            // Weight progression chart
            _ChartSection(
              title: 'Weight Progression',
              exerciseId: _selectedExerciseId!,
              isWeight: true,
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 24),
            // Volume chart
            _ChartSection(
              title: 'Volume Progression',
              exerciseId: _selectedExerciseId!,
              isWeight: false,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),
            // Personal records
            _PersonalRecordsSection(exerciseId: _selectedExerciseId!)
                .animate()
                .fadeIn(delay: 300.ms),
          ] else ...[
            const SizedBox(height: 64),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: AppTheme.textHint),
                  SizedBox(height: 12),
                  Text('Select an exercise to view progress',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Workout frequency chart
          _WorkoutFrequencyChart().animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Muscle group heat map
          _MuscleGroupHeatMap().animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 24),

          // Recent workouts
          const Text('Recent Workouts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          completedSessions.when(
            data: (sessions) {
              final recent = sessions.take(10).toList();
              if (recent.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No completed workouts yet',
                        style: TextStyle(color: AppTheme.textHint)),
                  ),
                );
              }
              return Column(
                children: recent.asMap().entries.map((entry) {
                  final session = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.check, color: AppTheme.success),
                      ),
                      title: Text(session.templateName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${formatDate(session.scheduledDate)} · ${session.totalVolume.toInt()} kg volume',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: session.duration != null
                          ? Text(formatElapsedTime(session.duration!),
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12))
                          : null,
                    ),
                  ).animate().fadeIn(delay: (50 * entry.key).ms);
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSelector extends ConsumerWidget {
  final String? selectedId;
  final void Function(String id) onSelect;

  const _ExerciseSelector({required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exerciseListProvider);

    return exercisesAsync.when(
      data: (exercises) => DropdownButtonFormField<String>(
        initialValue: selectedId,
        hint: const Text('Select exercise'),
        items: exercises
            .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
            .toList(),
        onChanged: (id) {
          if (id != null) {
            onSelect(id);
          }
        },
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('$e'),
    );
  }
}

class _ChartSection extends ConsumerWidget {
  final String title;
  final String exerciseId;
  final bool isWeight;

  const _ChartSection({
    required this.title,
    required this.exerciseId,
    required this.isWeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = isWeight
        ? ref.watch(weightProgressionProvider(exerciseId))
        : ref.watch(volumeProgressionProvider(exerciseId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: dataAsync.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(
                  child: Text('No data yet',
                      style: TextStyle(color: AppTheme.textHint)),
                );
              }
              return _buildChart(data);
            },
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(Map<String, double> data) {
    final entries = data.entries.toList();
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final color = isWeight ? AppTheme.primary : AppTheme.secondary;

    if (isWeight) {
      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(entries[idx].key,
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textHint)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textHint),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.card,
            ),
          ),
        ),
      );
    }

    // Bar chart for volume
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(entries[idx].key,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textHint)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: const TextStyle(fontSize: 10, color: AppTheme.textHint),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: color,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _PersonalRecordsSection extends ConsumerWidget {
  final String exerciseId;
  const _PersonalRecordsSection({required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(personalRecordsProvider(exerciseId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.emoji_events, color: AppTheme.warning, size: 22),
            SizedBox(width: 8),
            Text('Personal Records',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        recordsAsync.when(
          data: (records) {
            if (records.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No records yet. Complete workouts to set PRs!',
                    style: TextStyle(color: AppTheme.textHint),
                    textAlign: TextAlign.center),
              );
            }
            return Column(
              children: records.take(5).map((record) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events,
                        color: AppTheme.warning),
                    title: Text(
                      '${formatWeight(record.weight)} × ${record.reps} reps',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(formatDate(record.date),
                        style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      '${record.volume.toInt()} kg vol',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Text('$e'),
        ),
      ],
    );
  }
}

// ─── Workout Frequency Bar Chart ───
class _WorkoutFrequencyChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final freqAsync = ref.watch(workoutFrequencyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Workout Frequency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Last 30 days', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.card3D,
          child: freqAsync.when(
            data: (freq) {
              if (freq.values.every((v) => v == 0)) {
                return const Center(child: Text('No workout data yet', style: TextStyle(color: AppTheme.textHint)));
              }
              final entries = freq.entries.toList();
              return BarChart(
                BarChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(color: Colors.white10, strokeWidth: 0.5)),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx >= 0 && idx < entries.length) {
                          return Padding(padding: const EdgeInsets.only(top: 8),
                            child: Text(entries[idx].key, style: const TextStyle(fontSize: 10, color: AppTheme.textHint)));
                        }
                        return const SizedBox();
                      })),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: AppTheme.textHint)))),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: entries.asMap().entries.map((e) {
                    return BarChartGroupData(x: e.key, barRods: [
                      BarChartRodData(
                        toY: e.value.value.toDouble(),
                        color: AppTheme.primary,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ]);
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ),
      ],
    );
  }
}

// ─── Muscle Group Heat Map ───
class _MuscleGroupHeatMap extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(completedSessionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Muscle Group Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Based on completed workouts', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
        const SizedBox(height: 12),
        sessionsAsync.when(
          data: (sessions) {
            // Count muscle group frequency
            final counts = <String, int>{};
            for (final session in sessions) {
              for (final exercise in session.exercises) {
                counts[exercise.muscleGroup] = (counts[exercise.muscleGroup] ?? 0) + 1;
              }
            }

            if (counts.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: AppTheme.card3D,
                child: const Text('Complete workouts to see muscle activity', style: TextStyle(color: AppTheme.textHint), textAlign: TextAlign.center),
              );
            }

            final maxCount = counts.values.reduce((a, b) => a > b ? a : b);
            final groups = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: groups.map((entry) {
                final intensity = (entry.value / maxCount).clamp(0.2, 1.0);
                final color = muscleGroupColor(entry.key);
                return Container(
                  width: (MediaQuery.of(context).size.width - 48) / 3 - 6,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: intensity * 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: intensity * 0.4), width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Icon(muscleGroupIcon(entry.key), color: color.withValues(alpha: intensity), size: 24),
                      const SizedBox(height: 6),
                      Text(entry.key, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withValues(alpha: intensity))),
                      Text('${entry.value}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color.withValues(alpha: intensity))),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
          error: (e, _) => Text('$e'),
        ),
      ],
    );
  }
}
