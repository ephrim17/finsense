import '../entities/user_preferences.dart';

abstract class PreferencesRepository {
  Stream<UserPreferences> watchPreferences(String userId);
  Future<void> savePreferences(String userId, UserPreferences preferences);
}
