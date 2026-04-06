import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_mate/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gym_mate/presentation/screens/home/app_shell.dart';
import 'package:gym_mate/presentation/screens/home/home_screen.dart';
import 'package:gym_mate/presentation/screens/library/workout_library_screen.dart';
import 'package:gym_mate/presentation/screens/templates/templates_screen.dart';
import 'package:gym_mate/presentation/screens/templates/create_template_screen.dart';
import 'package:gym_mate/presentation/screens/templates/template_detail_screen.dart';
import 'package:gym_mate/presentation/screens/calendar/calendar_screen.dart';
import 'package:gym_mate/presentation/screens/session/workout_session_screen.dart';
import 'package:gym_mate/presentation/screens/analytics/analytics_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({required bool onboardingCompleted}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: onboardingCompleted ? '/' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Library tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const WorkoutLibraryScreen(),
              ),
            ],
          ),
          // Calendar tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // Analytics tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Template routes (outside shell)
      GoRoute(
        path: '/templates',
        builder: (context, state) => const TemplatesScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreateTemplateScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TemplateDetailScreen(templateId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CreateTemplateScreen(templateId: id);
                },
              ),
            ],
          ),
        ],
      ),
      // Session route (outside shell)
      GoRoute(
        path: '/session/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WorkoutSessionScreen(sessionId: id);
        },
      ),
    ],
  );
}
