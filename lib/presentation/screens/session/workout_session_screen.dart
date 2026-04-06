import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_mate/core/theme/app_theme.dart';
import 'package:gym_mate/core/constants/app_constants.dart';
import 'package:gym_mate/core/utils/helpers.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/presentation/providers/providers.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const WorkoutSessionScreen({super.key, required this.sessionId});

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;
  int _expandedExercise = 0;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final notifier = ref.read(activeSessionProvider.notifier);
    await notifier.loadSession(widget.sessionId);
    final session = ref.read(activeSessionProvider);
    if (session != null && session.status == 'scheduled') {
      await notifier.startSession(session);
    }
    _startTimer();
  }

  void _startTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = ref.read(activeSessionProvider);
      if (session?.startedAt != null) {
        setState(() => _elapsed = DateTime.now().difference(session!.startedAt!));
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final session = ref.read(activeSessionProvider);
    if (session?.status == 'completed') return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Workout?'),
        content: const Text('Your progress will be saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(activeSessionProvider.notifier).saveProgress();
              Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
            child: const Text('End'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeSessionProvider);
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
    }

    final pct = session.completionPercentage;
    final isCompleted = session.status == 'completed';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canPop = await _onWillPop();
        if (canPop && context.mounted) context.pop();
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ─── Top Bar ───
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () async {
                        final canPop = await _onWillPop();
                        if (canPop && context.mounted) context.pop();
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.templateName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          Text(formatElapsedTime(_elapsed),
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    // Progress ring
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: pct,
                            strokeWidth: 3,
                            backgroundColor: AppTheme.cardBorder,
                            valueColor: AlwaysStoppedAnimation(isCompleted ? AppTheme.success : AppTheme.primary),
                          ),
                          Text('${(pct * 100).toInt()}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ─── Body ───
              Expanded(
                child: isCompleted
                    ? _CompletedView(session: session)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                        itemCount: session.exercises.length,
                        itemBuilder: (ctx, index) {
                          final exercise = session.exercises[index];
                          final isExpanded = _expandedExercise == index;
                          return _ExerciseCard3D(
                            exercise: exercise,
                            exerciseIndex: index,
                            isExpanded: isExpanded,
                            onToggle: () => setState(() => _expandedExercise = isExpanded ? -1 : index),
                            onSetComplete: (setIndex) {
                              HapticFeedback.mediumImpact();
                              ref.read(activeSessionProvider.notifier).toggleSetComplete(index, setIndex);
                            },
                            onUpdateSet: (setIndex, {int? reps, double? weight}) {
                              ref.read(activeSessionProvider.notifier).updateSet(index, setIndex, reps: reps, weight: weight);
                            },
                            onAddSet: () => ref.read(activeSessionProvider.notifier).addSet(index),
                          ).animate().fadeIn(delay: (40 * index).ms);
                        },
                      ),
              ),
            ],
          ),
        ),

        // ─── Bottom Bar ───
        bottomNavigationBar: isCompleted
            ? null
            : Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppTheme.background, AppTheme.background],
                  ),
                ),
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: pct > 0 ? _completeWorkout : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pct > 0 ? AppTheme.primary : AppTheme.card,
                      foregroundColor: pct > 0 ? Colors.black : AppTheme.textHint,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      'Complete Workout  ${(pct * 100).toInt()}%',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _completeWorkout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Workout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(activeSessionProvider.notifier).completeSession();
      _elapsedTimer?.cancel();
      final session = ref.read(activeSessionProvider);
      if (session != null) {
        final analyticsRepo = ref.read(analyticsRepositoryProvider);
        for (final exercise in session.exercises) {
          for (final set in exercise.sets) {
            if (set.isCompleted && set.actualWeight > 0) {
              await analyticsRepo.checkAndUpdatePersonalRecord(
                exercise.exerciseId, exercise.name, set.actualWeight, set.actualReps, DateTime.now());
            }
          }
        }
      }
    }
  }
}

// ─── 3D Exercise Card ───
class _ExerciseCard3D extends StatelessWidget {
  final SessionExerciseModel exercise;
  final int exerciseIndex;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<int> onSetComplete;
  final void Function(int setIndex, {int? reps, double? weight}) onUpdateSet;
  final VoidCallback onAddSet;

  const _ExerciseCard3D({
    required this.exercise,
    required this.exerciseIndex,
    required this.isExpanded,
    required this.onToggle,
    required this.onSetComplete,
    required this.onUpdateSet,
    required this.onAddSet,
  });

  @override
  Widget build(BuildContext context) {
    final done = exercise.sets.where((s) => s.isCompleted).length;
    final total = exercise.sets.length;
    final allDone = done == total && total > 0;
    final color = muscleGroupColor(exercise.muscleGroup);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: allDone ? AppTheme.card3DColored(AppTheme.success) : AppTheme.card3D,
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: allDone ? AppTheme.success.withValues(alpha: 0.15) : color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: allDone
                        ? const Icon(Icons.check_rounded, color: AppTheme.success, size: 22)
                        : Icon(muscleGroupIcon(exercise.muscleGroup), color: color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: AppTheme.tagDecoration(color),
                              child: Text(exercise.muscleGroup,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                            ),
                            const SizedBox(width: 8),
                            Text('$done/$total sets',
                                style: TextStyle(
                                    fontSize: 12, color: allDone ? AppTheme.success : AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.textHint),
                ],
              ),
            ),
          ),

          // Sets
          if (isExpanded) ...[
            Container(height: 0.5, color: AppTheme.cardBorder),
            // Column headers
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Row(
                children: const [
                  SizedBox(width: 32, child: Text('SET', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textHint, letterSpacing: 1))),
                  Expanded(flex: 3, child: Text('WEIGHT', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textHint, letterSpacing: 1))),
                  Expanded(flex: 3, child: Text('REPS', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textHint, letterSpacing: 1))),
                  SizedBox(width: 48),
                ],
              ),
            ),
            ...exercise.sets.asMap().entries.map((e) => _SetRow3D(
                  set: e.value,
                  setIndex: e.key,
                  onComplete: () => onSetComplete(e.key),
                  onUpdateReps: (r) => onUpdateSet(e.key, reps: r),
                  onUpdateWeight: (w) => onUpdateSet(e.key, weight: w),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: GestureDetector(
                onTap: onAddSet,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder, width: 0.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 16, color: AppTheme.textSecondary),
                      SizedBox(width: 6),
                      Text('Add Set', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
            // Exercise timer (for timed exercises like plank, cardio)
            if (exercise.timerSeconds > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _RestTimer3D(restSeconds: exercise.timerSeconds, label: 'Exercise Timer'),
              ),
            // Rest timer
            if (exercise.restSeconds > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: _RestTimer3D(restSeconds: exercise.restSeconds),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── 3D Set Row ───
class _SetRow3D extends StatelessWidget {
  final SessionSetModel set;
  final int setIndex;
  final VoidCallback onComplete;
  final ValueChanged<int> onUpdateReps;
  final ValueChanged<double> onUpdateWeight;

  const _SetRow3D({
    required this.set,
    required this.setIndex,
    required this.onComplete,
    required this.onUpdateReps,
    required this.onUpdateWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: set.isCompleted ? AppTheme.primary.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('${setIndex + 1}', textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14,
                    color: set.isCompleted ? AppTheme.primary : AppTheme.textSecondary)),
          ),
          Expanded(
            flex: 3,
            child: _Stepper3D(
              value: set.actualWeight,
              suffix: 'kg',
              step: AppConstants.weightIncrement,
              fastStep: AppConstants.weightFastIncrement,
              onChanged: onUpdateWeight,
              isDone: set.isCompleted,
            ),
          ),
          Expanded(
            flex: 3,
            child: _Stepper3D(
              value: set.actualReps.toDouble(),
              suffix: '',
              step: 1,
              fastStep: 5,
              onChanged: (v) => onUpdateReps(v.toInt()),
              isInt: true,
              isDone: set.isCompleted,
            ),
          ),
          GestureDetector(
            onTap: onComplete,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: set.isCompleted ? AppTheme.primary : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(13),
                border: set.isCompleted ? null : Border.all(color: AppTheme.cardBorder),
              ),
              child: set.isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.black, size: 20)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 3D Stepper ───
class _Stepper3D extends StatelessWidget {
  final double value;
  final String suffix;
  final double step;
  final double fastStep;
  final ValueChanged<double> onChanged;
  final bool isInt;
  final bool isDone;

  const _Stepper3D({
    required this.value,
    required this.suffix,
    required this.step,
    required this.fastStep,
    required this.onChanged,
    this.isInt = false,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final display = isInt
        ? '${value.toInt()}'
        : value == value.roundToDouble() ? '${value.toInt()}' : value.toStringAsFixed(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onChanged((value - step).clamp(0, 999)),
          onLongPress: () => onChanged((value - fastStep).clamp(0, 999)),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppTheme.cardBorder, width: 0.5),
            ),
            child: const Icon(Icons.remove, size: 14, color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            suffix.isNotEmpty ? '$display $suffix' : display,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDone ? AppTheme.primary : Colors.white,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(value + step),
          onLongPress: () => onChanged(value + fastStep),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 0.5),
            ),
            child: const Icon(Icons.add, size: 14, color: AppTheme.primary),
          ),
        ),
      ],
    );
  }
}

// ─── 3D Rest Timer ───
class _RestTimer3D extends StatefulWidget {
  final int restSeconds;
  final String label;
  const _RestTimer3D({required this.restSeconds, this.label = 'Rest'});

  @override
  State<_RestTimer3D> createState() => _RestTimer3DState();
}

class _RestTimer3DState extends State<_RestTimer3D> {
  Timer? _timer;
  int _remaining = 0;
  bool _isRunning = false;

  void _start() {
    setState(() { _remaining = widget.restSeconds; _isRunning = true; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining--;
        if (_remaining <= 0) { _isRunning = false; _timer?.cancel(); HapticFeedback.heavyImpact(); }
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_isRunning) {
      return GestureDetector(
        onTap: _start,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: AppTheme.textHint),
              const SizedBox(width: 6),
              Text('Start ${widget.restSeconds}s ${widget.label.toLowerCase()}', style: const TextStyle(color: AppTheme.textHint, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: AppTheme.card3DColored(AppTheme.primary),
      child: Row(
        children: [
          SizedBox(
            width: 36, height: 36,
            child: CircularProgressIndicator(
              value: _remaining / widget.restSeconds,
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              backgroundColor: AppTheme.cardBorder,
            ),
          ),
          const SizedBox(width: 14),
          Text(formatDuration(_remaining),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary)),
          const Spacer(),
          GestureDetector(
            onTap: () { _timer?.cancel(); setState(() => _isRunning = false); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Skip', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Completed View ───
class _CompletedView extends StatelessWidget {
  final SessionModel session;
  const _CompletedView({required this.session});

  @override
  Widget build(BuildContext context) {
    final duration = session.duration;
    final totalSets = session.exercises.fold<int>(0, (s, e) => s + e.sets.where((s) => s.isCompleted).length);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 50)],
              ),
              child: const Icon(Icons.emoji_events_rounded, size: 56, color: AppTheme.primary),
            ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms),
            const SizedBox(height: 28),
            const Text('Workout Complete!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))
                .animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.card3D,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CStat(icon: Icons.timer, label: 'Duration', value: duration != null ? formatElapsedTime(duration) : '--'),
                  Container(width: 0.5, height: 40, color: AppTheme.cardBorder),
                  _CStat(icon: Icons.fitness_center, label: 'Volume', value: '${session.totalVolume.toInt()} kg'),
                  Container(width: 0.5, height: 40, color: AppTheme.cardBorder),
                  _CStat(icon: Icons.check_circle, label: 'Sets', value: '$totalSets'),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(onPressed: () => context.go('/'), child: const Text('Back to Home')),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}

class _CStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _CStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}
