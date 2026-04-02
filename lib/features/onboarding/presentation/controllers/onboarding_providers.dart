import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/onboarding_storage.dart';

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return OnboardingStorage();
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) {
  return ref.watch(onboardingStorageProvider).isCompleted();
});

class OnboardingController extends StateNotifier<AsyncValue<void>> {
  OnboardingController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> complete() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(onboardingStorageProvider).markCompleted();
      ref.invalidate(onboardingCompletedProvider);
    });
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, AsyncValue<void>>((ref) {
      return OnboardingController(ref);
    });
