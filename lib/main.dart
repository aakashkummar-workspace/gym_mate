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

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await HiveService.init();
  await ExerciseRepositoryImpl().seedDefaultExercises();

  final onboardingCompleted = await UserRepositoryImpl().isOnboardingCompleted();

  runApp(
    ProviderScope(
      child: GymateApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class GymateApp extends StatefulWidget {
  final bool onboardingCompleted;
  const GymateApp({super.key, required this.onboardingCompleted});

  @override
  State<GymateApp> createState() => _GymateAppState();
}

class _GymateAppState extends State<GymateApp> {
  late final router = createRouter(onboardingCompleted: widget.onboardingCompleted);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gymate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
