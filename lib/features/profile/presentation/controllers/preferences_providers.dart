import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../data/repositories/firestore_preferences_repository.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return FirestorePreferencesRepository(ref.watch(firestoreProvider));
});

final userPreferencesProvider = StreamProvider<UserPreferences>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield const UserPreferences();
    return;
  }

  yield* ref.watch(preferencesRepositoryProvider).watchPreferences(user.id);
});

class PreferencesController extends StateNotifier<AsyncValue<void>> {
  PreferencesController(this._repository) : super(const AsyncData(null));

  final PreferencesRepository _repository;

  Future<void> save({
    required String userId,
    required UserPreferences preferences,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.savePreferences(userId, preferences);
    });
  }
}

final preferencesControllerProvider =
    StateNotifierProvider<PreferencesController, AsyncValue<void>>((ref) {
      return PreferencesController(ref.watch(preferencesRepositoryProvider));
    });
