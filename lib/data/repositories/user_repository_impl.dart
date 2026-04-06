import 'package:hive/hive.dart';
import 'package:gym_mate/data/models/models.dart';
import 'package:gym_mate/data/datasources/hive_service.dart';
import 'package:gym_mate/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  Box<UserProfileModel> get _box => Hive.box<UserProfileModel>(HiveService.userBox);

  @override
  Future<UserProfileModel?> getUserProfile() async {
    return _box.get('profile');
  }

  @override
  Future<void> saveUserProfile(UserProfileModel profile) async {
    await _box.put('profile', profile);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final profile = _box.get('profile');
    return profile?.onboardingCompleted ?? false;
  }

  @override
  Future<void> completeOnboarding() async {
    final profile = _box.get('profile');
    if (profile != null) {
      final updated = profile.copyWith(onboardingCompleted: true);
      await _box.put('profile', updated);
    }
  }
}
