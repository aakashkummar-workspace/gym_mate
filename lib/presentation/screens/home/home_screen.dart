import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_mate/core/theme/app_theme.dart';
import 'package:gym_mate/core/utils/helpers.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/presentation/providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _pageController;
  final int _daysRange = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.82,
      initialPage: _daysRange,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _dateForIndex(int index) {
    return DateTime.now().add(Duration(days: index - _daysRange));
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final streak = ref.watch(workoutStreakProvider);
    final rate = ref.watch(completionRateProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ─── Top Bar ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGreeting(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        userProfile.when(
                          data: (profile) => Text(
                            profile?.name.isNotEmpty == true ? profile!.name : 'Athlete',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          loading: () => const SizedBox(height: 32),
                          error: (_, __) => const Text('Athlete',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                  // Profile avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.cardBorder, width: 0.5),
                    ),
                    child: const Icon(Icons.person_rounded, color: AppTheme.textHint, size: 22),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // ─── Stats Row ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _StatCard3D(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFF9500),
                    value: streak.when(data: (s) => '$s', loading: () => '-', error: (_, __) => '0'),
                    label: 'Day Streak',
                    glowColor: const Color(0xFFFF9500),
                  ),
                  const SizedBox(width: 12),
                  _StatCard3D(
                    icon: Icons.check_circle_rounded,
                    iconColor: AppTheme.primary,
                    value: rate.when(data: (r) => '${(r * 100).toInt()}%', loading: () => '-', error: (_, __) => '0%'),
                    label: 'Complete',
                    glowColor: AppTheme.primary,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 28),

            // ─── Section Header ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    'YOUR WEEK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Divider(color: AppTheme.cardBorder)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Swipeable Day Cards ───
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _daysRange * 2 + 1,
                itemBuilder: (context, index) {
                  final date = _dateForIndex(index);
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double scale = 1.0;
                      double opacity = 1.0;
                      if (_pageController.position.haveDimensions) {
                        double page = _pageController.page ?? _daysRange.toDouble();
                        final diff = (page - index).abs();
                        scale = (1 - diff * 0.08).clamp(0.88, 1.0);
                        opacity = (1 - diff * 0.3).clamp(0.5, 1.0);
                      }
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(opacity: opacity, child: child),
                      );
                    },
                    child: _DayCard3D(
                      date: date,
                      isToday: index == _daysRange,
                    ),
                  );
                },
              ),
            ),

            // ─── Quick Actions ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              child: Row(
                children: [
                  _QuickAction3D(
                    icon: Icons.bolt_rounded,
                    label: 'Quick Start',
                    color: AppTheme.primary,
                    onTap: () => context.push('/templates'),
                  ),
                  const SizedBox(width: 10),
                  _QuickAction3D(
                    icon: Icons.dashboard_customize_rounded,
                    label: 'Templates',
                    color: AppTheme.accent,
                    onTap: () => context.push('/templates'),
                  ),
                  const SizedBox(width: 10),
                  _QuickAction3D(
                    icon: Icons.history_rounded,
                    label: 'History',
                    color: AppTheme.secondary,
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

// ─── 3D Stat Card ───
class _StatCard3D extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color glowColor;

  const _StatCard3D({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.card3DColored(glowColor),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text(label,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 3D Day Card ───
class _DayCard3D extends ConsumerWidget {
  final DateTime date;
  final bool isToday;

  const _DayCard3D({required this.date, required this.isToday});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsForDateProvider(
      DateTime(date.year, date.month, date.day),
    ));

    return sessionsAsync.when(
      data: (sessions) => _buildCard(context, sessions),
      loading: () => _buildLoadingCard(),
      error: (_, __) => _buildCard(context, []),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: AppTheme.card3DElevated,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
    );
  }

  Widget _buildCard(BuildContext context, List<SessionModel> sessions) {
    final hasWorkout = sessions.isNotEmpty;
    final session = hasWorkout ? sessions.first : null;
    final isCompleted = session?.status == 'completed';
    final progress = session?.completionPercentage ?? 0;

    return GestureDetector(
      onTap: () {
        if (session != null) context.push('/session/${session.id}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: isCompleted
            ? AppTheme.card3DColored(AppTheme.success)
            : isToday
                ? AppTheme.card3DColored(AppTheme.primary)
                : AppTheme.card3DElevated,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top: Date + Badge ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getRelativeDay(date),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isToday ? AppTheme.primary : AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1),
                      ),
                    ],
                  ),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'TODAY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  if (isCompleted)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.check_rounded, color: AppTheme.success, size: 24),
                    ),
                ],
              ),

              const Spacer(),

              // ─── Content ───
              if (hasWorkout) ...[
                // Workout name
                Text(
                  session!.templateName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2),
                ),
                const SizedBox(height: 8),
                // Tags
                Row(
                  children: [
                    _Tag(
                      label: '${session.exercises.length} exercises',
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    if (session.exercises.isNotEmpty)
                      _Tag(
                        label: session.exercises.first.muscleGroup,
                        color: muscleGroupColor(session.exercises.first.muscleGroup),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // Progress
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? AppTheme.success : AppTheme.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isCompleted
                      ? 'Completed'
                      : session.status == 'inProgress'
                          ? '${(progress * 100).toInt()}% done'
                          : 'Tap to start',
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted ? AppTheme.success : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else ...[
                // Rest day
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.self_improvement_rounded,
                    size: 32,
                    color: AppTheme.textHint,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rest Day',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textHint),
                ),
                const SizedBox(height: 4),
                const Text(
                  'No workout scheduled',
                  style: TextStyle(fontSize: 13, color: AppTheme.textHint),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tag Widget ───
class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: AppTheme.tagDecoration(color),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ─── 3D Quick Action ───
class _QuickAction3D extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction3D({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: AppTheme.card3D,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
