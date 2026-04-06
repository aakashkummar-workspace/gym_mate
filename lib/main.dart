import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_mate/core/theme/app_theme.dart';
import 'package:gym_mate/core/router/app_router.dart';
import 'package:gym_mate/data/datasources/hive_service.dart';
import 'package:gym_mate/data/repositories/exercise_repository_impl.dart';
import 'package:gym_mate/data/repositories/user_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Hive
  await HiveService.init();

  // Seed default exercises
  await ExerciseRepositoryImpl().seedDefaultExercises();

  // Check onboarding
  final onboardingCompleted = await UserRepositoryImpl().isOnboardingCompleted();

  runApp(
    ProviderScope(
      child: GymateApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class GymateApp extends StatelessWidget {
  final bool onboardingCompleted;

  const GymateApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    final router = createRouter(onboardingCompleted: onboardingCompleted);

    return MaterialApp.router(
      title: 'Gymate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
