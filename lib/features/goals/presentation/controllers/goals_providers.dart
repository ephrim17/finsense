import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../data/repositories/firestore_goals_repository.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/goals_repository.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return FirestoreGoalsRepository(ref.watch(firestoreProvider));
});

final goalsProvider = StreamProvider<List<SavingsGoal>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield const [];
    return;
  }

  yield* ref.watch(goalsRepositoryProvider).watchGoals(user.id);
});

class GoalActionController extends StateNotifier<AsyncValue<void>> {
  GoalActionController(this._repository) : super(const AsyncData(null));

  final GoalsRepository _repository;
  final _uuid = const Uuid();

  Future<void> save({
    required String userId,
    required String title,
    required double targetAmount,
    required double currentAmount,
    required String icon,
    required String color,
    DateTime? deadline,
    String? id,
  }) async {
    final now = DateTime.now();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.upsertGoal(
        SavingsGoal(
          id: id ?? _uuid.v4(),
          userId: userId,
          title: title,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          icon: icon,
          color: color,
          deadline: deadline,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
  }
}

final goalActionControllerProvider =
    StateNotifierProvider<GoalActionController, AsyncValue<void>>((ref) {
      return GoalActionController(ref.watch(goalsRepositoryProvider));
    });
