import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_mate/core/theme/app_theme.dart';
import 'package:gym_mate/presentation/providers/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    ref.listen<OnboardingState>(onboardingProvider, (prev, next) {
      if (prev?.currentStep != next.currentStep) _goToPage(next.currentStep);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Row(
                children: List.generate(5, (i) {
                  final isActive = i <= state.currentStep;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 3,
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primary : AppTheme.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomePage(onNext: () => ref.read(onboardingProvider.notifier).nextStep()),
                  _SelectionPage(
                    title: "What's Your Goal?",
                    items: const [
                      {'key': 'muscleGain', 'label': 'Muscle Gain', 'icon': Icons.fitness_center, 'desc': 'Build size & mass'},
                      {'key': 'fatLoss', 'label': 'Fat Loss', 'icon': Icons.local_fire_department, 'desc': 'Lean & shredded'},
                      {'key': 'strength', 'label': 'Strength', 'icon': Icons.bolt, 'desc': 'Lift heavier'},
                      {'key': 'endurance', 'label': 'Endurance', 'icon': Icons.directions_run, 'desc': 'Go longer'},
                    ],
                    selected: state.selectedGoal,
                    onSelect: (v) => ref.read(onboardingProvider.notifier).setGoal(v),
                    onNext: () => ref.read(onboardingProvider.notifier).nextStep(),
                    onBack: () => ref.read(onboardingProvider.notifier).prevStep(),
                  ),
                  _SelectionPage(
                    title: 'Experience Level',
                    items: const [
                      {'key': 'beginner', 'label': 'Beginner', 'icon': Icons.emoji_nature, 'desc': 'Just getting started'},
                      {'key': 'intermediate', 'label': 'Intermediate', 'icon': Icons.trending_up, 'desc': '1-3 years training'},
                      {'key': 'advanced', 'label': 'Advanced', 'icon': Icons.military_tech, 'desc': '3+ years experience'},
                    ],
                    selected: state.selectedLevel,
                    onSelect: (v) => ref.read(onboardingProvider.notifier).setLevel(v),
                    onNext: () => ref.read(onboardingProvider.notifier).nextStep(),
                    onBack: () => ref.read(onboardingProvider.notifier).prevStep(),
                  ),
                  _SelectionPage(
                    title: 'Workout Split',
                    items: const [
                      {'key': 'ppl', 'label': 'Push/Pull/Legs', 'icon': Icons.view_column, 'desc': '3-6 days/week'},
                      {'key': 'broSplit', 'label': 'Bro Split', 'icon': Icons.grid_view, 'desc': '5 days/week'},
                      {'key': 'upperLower', 'label': 'Upper/Lower', 'icon': Icons.swap_vert, 'desc': '4 days/week'},
                      {'key': 'fullBody', 'label': 'Full Body', 'icon': Icons.person, 'desc': '3 days/week'},
                      {'key': 'custom', 'label': 'Custom', 'icon': Icons.tune, 'desc': 'Build your own'},
                    ],
                    selected: state.selectedSplit,
                    onSelect: (v) => ref.read(onboardingProvider.notifier).setSplit(v),
                    onNext: () => ref.read(onboardingProvider.notifier).nextStep(),
                    onBack: () => ref.read(onboardingProvider.notifier).prevStep(),
                  ),
                  _ReadyPage(
                    state: state,
                    onComplete: () async {
                      await ref.read(onboardingProvider.notifier).completeOnboarding();
                      if (context.mounted) context.go('/');
                    },
                    onBack: () => ref.read(onboardingProvider.notifier).prevStep(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // 3D Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withValues(alpha: 0.2),
                  AppTheme.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withValues(alpha: 0.15), blurRadius: 40, spreadRadius: -8),
              ],
            ),
            child: const Icon(Icons.fitness_center_rounded, size: 56, color: AppTheme.primary),
          ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.6, 0.6)),
          const SizedBox(height: 40),
          const Text(
            'GYMATE',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
          const SizedBox(height: 8),
          Text(
            'Your Personal Workout Companion',
            style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ).animate().fadeIn(delay: 500.ms),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Get Started'),
            ),
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SelectionPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _SelectionPage({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
          child: Text(title, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: items.asMap().entries.map((entry) {
              final item = entry.value;
              final isSelected = selected == item['key'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => onSelect(item['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(18),
                    decoration: isSelected
                        ? AppTheme.card3DColored(AppTheme.primary)
                        : AppTheme.card3D,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['desc'] as String,
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.check, size: 16, color: Colors.black),
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (60 * entry.key).ms).slideX(begin: 0.05),
              );
            }).toList(),
          ),
        ),
        // Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(onPressed: onBack, child: const Text('Back')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selected != null ? onNext : null,
                    child: const Text('Continue'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadyPage extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _ReadyPage({required this.state, required this.onComplete, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 40),
              ],
            ),
            child: const Icon(Icons.check_rounded, size: 52, color: AppTheme.primary),
          ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms),
          const SizedBox(height: 32),
          const Text("You're All Set!", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800))
              .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          // Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.card3D,
            child: Column(
              children: [
                _SummaryRow(label: 'Goal', value: state.selectedGoal ?? ''),
                const SizedBox(height: 12),
                _SummaryRow(label: 'Level', value: state.selectedLevel ?? ''),
                const SizedBox(height: 12),
                _SummaryRow(label: 'Split', value: state.selectedSplit ?? ''),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(onPressed: onBack, child: const Text('Back')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(onPressed: onComplete, child: const Text('Generate & Start')),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: AppTheme.tagDecoration(AppTheme.primary),
          child: Text(value, style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
