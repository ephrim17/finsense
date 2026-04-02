import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../onboarding/presentation/controllers/onboarding_providers.dart';
import '../../../../shared/theme/app_colors.dart';
import '../controllers/auth_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final onboardingState = ref.watch(onboardingCompletedProvider);

    final user = authState.valueOrNull;
    final onboardingCompleted = onboardingState.valueOrNull;

    if (authState.isLoading || onboardingState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (onboardingCompleted != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        if (!onboardingCompleted) {
          context.go('/onboarding');
          return;
        }
        context.go(user == null ? '/sign-in' : '/dashboard');
      });
    }

    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
