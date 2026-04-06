import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gym_mate/core/theme/app_theme.dart';
import 'package:gym_mate/core/utils/helpers.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/presentation/providers/providers.dart';

enum CalendarView { month, week, day }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();
  CalendarView _view = CalendarView.month;

  @override
  Widget build(BuildContext context) {
    final selectedNorm = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final sessionsAsync = ref.watch(sessionsForDateProvider(selectedNorm));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          // View toggle
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.cardBorder, width: 0.5)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: CalendarView.values.map((v) {
                final isActive = _view == v;
                final label = v == CalendarView.month ? 'M' : v == CalendarView.week ? 'W' : 'D';
                return GestureDetector(
                  onTap: () => setState(() => _view = v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isActive ? Colors.black : AppTheme.textHint)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar section
          if (_view == CalendarView.month) _MonthView(
            currentMonth: _currentMonth,
            selectedDate: _selectedDate,
            onMonthChange: (m) => setState(() => _currentMonth = m),
            onDateSelect: (d) => setState(() => _selectedDate = d),
          ),
          if (_view == CalendarView.week) _WeekView(
            selectedDate: _selectedDate,
            onDateSelect: (d) => setState(() => _selectedDate = d),
          ),
          if (_view == CalendarView.day) _DayHeader(date: _selectedDate, onDateChange: (d) => setState(() => _selectedDate = d)),

          const Divider(height: 1),
          const SizedBox(height: 8),

          // Selected date info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(DateFormat('EEEE, MMMM d').format(_selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showScheduleSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: Colors.black),
                        SizedBox(width: 4),
                        Text('Add', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Sessions list
          Expanded(
            child: sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: 48, color: AppTheme.textHint),
                        SizedBox(height: 12),
                        Text('No workouts scheduled', style: TextStyle(color: AppTheme.textSecondary)),
                        SizedBox(height: 4),
                        Text('Tap + to add a workout', style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sessions.length,
                  itemBuilder: (ctx, i) {
                    final session = sessions[i];
                    final isDone = session.status == 'completed';
                    return GestureDetector(
                      onTap: () => context.push('/session/${session.id}'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: isDone ? AppTheme.card3DColored(AppTheme.success) : AppTheme.card3D,
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: isDone ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(isDone ? Icons.check_rounded : Icons.fitness_center, color: isDone ? AppTheme.success : AppTheme.primary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(session.templateName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  Text('${session.exercises.length} exercises · ${isDone ? "Completed" : session.status}',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppTheme.textHint, size: 20),
                          ],
                        ),
                      ).animate().fadeIn(delay: (50 * i).ms),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleSheet(BuildContext context) {
    final templatesAsync = ref.read(templateListProvider);
    String recurrenceType = 'once';
    TemplateModel? selectedTemplate;
    List<int> customDays = [];
    int everyXDays = 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Schedule Workout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              const Text('TEMPLATE', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, letterSpacing: 1)),
              const SizedBox(height: 8),
              templatesAsync.when(
                data: (templates) {
                  if (templates.isEmpty) return const Text('No templates. Create one first.', style: TextStyle(color: AppTheme.textHint));
                  return DropdownButtonFormField<TemplateModel>(
                    hint: const Text('Select template'),
                    items: templates.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                    onChanged: (t) => ss(() => selectedTemplate = t),
                  );
                },
                loading: () => const LinearProgressIndicator(color: AppTheme.primary),
                error: (e, _) => Text('$e'),
              ),
              const SizedBox(height: 16),
              const Text('RECURRENCE', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, letterSpacing: 1)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  _RecurrenceChip(label: 'One Time', value: 'once', selected: recurrenceType, onTap: () => ss(() => recurrenceType = 'once')),
                  _RecurrenceChip(label: 'Weekly', value: 'weekly', selected: recurrenceType, onTap: () => ss(() => recurrenceType = 'weekly')),
                  _RecurrenceChip(label: 'Every X Days', value: 'everyXDays', selected: recurrenceType, onTap: () => ss(() => recurrenceType = 'everyXDays')),
                  _RecurrenceChip(label: 'Custom', value: 'custom', selected: recurrenceType, onTap: () => ss(() => recurrenceType = 'custom')),
                ],
              ),
              if (recurrenceType == 'everyXDays') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Every ', style: TextStyle(color: AppTheme.textSecondary)),
                    GestureDetector(
                      onTap: () => ss(() { if (everyXDays > 2) everyXDays--; }),
                      child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.cardBorder)),
                        child: const Icon(Icons.remove, size: 14, color: AppTheme.textSecondary)),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('$everyXDays', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                    GestureDetector(
                      onTap: () => ss(() => everyXDays++),
                      child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add, size: 14, color: AppTheme.primary)),
                    ),
                    const Text(' days', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ],
              if (recurrenceType == 'custom') ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: List.generate(7, (i) {
                  final dayNum = i + 1;
                  final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final isSel = customDays.contains(dayNum);
                  return GestureDetector(
                    onTap: () => ss(() { isSel ? customDays.remove(dayNum) : customDays.add(dayNum); }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? AppTheme.primary : AppTheme.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSel ? AppTheme.primary : AppTheme.cardBorder),
                      ),
                      child: Text(names[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSel ? Colors.black : AppTheme.textSecondary)),
                    ),
                  );
                })),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: selectedTemplate == null ? null : () async {
                    final schedule = ScheduleModel(
                      id: generateId(),
                      templateId: selectedTemplate!.id,
                      templateName: selectedTemplate!.name,
                      dayOfWeek: recurrenceType == 'weekly' ? _selectedDate.weekday : null,
                      specificDate: _selectedDate,
                      recurrenceType: recurrenceType,
                      customDays: customDays,
                      repeatEveryXDays: everyXDays,
                    );
                    ref.read(scheduleListProvider.notifier).addSchedule(schedule);
                    await ref.read(sessionRepositoryProvider).createSessionFromTemplate(selectedTemplate!, _selectedDate);
                    ref.invalidate(sessionsForDateProvider(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)));
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Schedule'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Month View ───
class _MonthView extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onMonthChange;
  final ValueChanged<DateTime> onDateSelect;

  const _MonthView({required this.currentMonth, required this.selectedDate, required this.onMonthChange, required this.onDateSelect});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday;
    final today = DateTime.now();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => onMonthChange(DateTime(currentMonth.year, currentMonth.month - 1))),
              Text(DateFormat('MMMM yyyy').format(currentMonth), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => onMonthChange(DateTime(currentMonth.year, currentMonth.month + 1))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(color: AppTheme.textHint, fontSize: 12, fontWeight: FontWeight.w600)))))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            childAspectRatio: 1,
            children: [
              for (int i = 1; i < startWeekday; i++) const SizedBox(),
              for (int day = 1; day <= lastDay.day; day++)
                _buildDayCell(day, today),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(int day, DateTime today) {
    final date = DateTime(currentMonth.year, currentMonth.month, day);
    final isToday = isSameDay(date, today);
    final isSelected = isSameDay(date, selectedDate);

    return GestureDetector(
      onTap: () => onDateSelect(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isToday && !isSelected ? Border.all(color: AppTheme.primary, width: 1.5) : null,
        ),
        child: Center(
          child: Text('$day', style: TextStyle(
            fontSize: 14,
            fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? Colors.black : isToday ? AppTheme.primary : AppTheme.textPrimary,
          )),
        ),
      ),
    );
  }
}

// ─── Week View ───
class _WeekView extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelect;

  const _WeekView({required this.selectedDate, required this.onDateSelect});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Get Monday of current week
    final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => onDateSelect(selectedDate.subtract(const Duration(days: 7)))),
              Text('${DateFormat('MMM d').format(monday)} - ${DateFormat('MMM d').format(monday.add(const Duration(days: 6)))}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => onDateSelect(selectedDate.add(const Duration(days: 7)))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: List.generate(7, (i) {
              final date = monday.add(Duration(days: i));
              final isToday = isSameDay(date, today);
              final isSelected = isSameDay(date, selectedDate);
              final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDateSelect(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : isToday ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border: isToday && !isSelected ? Border.all(color: AppTheme.primary, width: 1) : Border.all(color: isSelected ? AppTheme.primary : AppTheme.cardBorder, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        Text(dayNames[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.black : AppTheme.textHint)),
                        const SizedBox(height: 6),
                        Text('${date.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isSelected ? Colors.black : AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Day Header ───
class _DayHeader extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateChange;

  const _DayHeader({required this.date, required this.onDateChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => onDateChange(date.subtract(const Duration(days: 1)))),
          Column(
            children: [
              Text(DateFormat('EEEE').format(date), style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              Text(DateFormat('MMMM d, yyyy').format(date), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              if (isSameDay(date, DateTime.now()))
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                  child: const Text('TODAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black)),
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => onDateChange(date.add(const Duration(days: 1)))),
        ],
      ),
    );
  }
}

// ─── Recurrence Chip ───
class _RecurrenceChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;
  const _RecurrenceChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSel = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? AppTheme.primary : AppTheme.cardBorder),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSel ? Colors.black : AppTheme.textSecondary)),
      ),
    );
  }
}
