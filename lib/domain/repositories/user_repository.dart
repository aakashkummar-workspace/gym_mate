import 'package:gym_mate/data/models/models.dart';

abstract class UserRepository {
  Future<UserProfileModel?> getUserProfile();
  Future<void> saveUserProfile(UserProfileModel profile);
  Future<bool> isOnboardingCompleted();
  Future<void> completeOnboarding();
}
