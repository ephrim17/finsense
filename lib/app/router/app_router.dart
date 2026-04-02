import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/enums/finance_enums.dart';
import '../../features/auth/presentation/screens/auth_gate.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/dashboard/presentation/screens/home_shell_screen.dart';
import '../../features/dashboard/presentation/screens/ai_insights_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/plan/presentation/screens/plan_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../../features/transactions/presentation/screens/bill_scanner_screen.dart';
import '../../features/transactions/presentation/screens/transactions_ai_insights_screen.dart';
import '../../features/transactions/presentation/screens/transaction_editor_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/ai-insights',
      builder: (context, state) =>
          AIInsightsScreen(snapshotJson: state.extra as String? ?? '{}'),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomeShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const HomeShellBranch(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/plan',
              builder: (context, state) => const PlanScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/insights',
              builder: (context, state) => const TransactionsAiInsightsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/transactions/new',
      builder: (context, state) {
        final typeParam = state.uri.queryParameters['type'];
        final initialType = typeParam == 'income'
            ? TransactionType.income
            : TransactionType.expense;
        return TransactionEditorScreen(
          initialType: initialType,
          initialTransaction: state.extra as dynamic,
        );
      },
    ),
    GoRoute(
      path: '/transactions/:transactionId/edit',
      builder: (context, state) => TransactionEditorScreen(
        initialTransaction: state.extra as dynamic,
      ),
    ),
    GoRoute(
      path: '/transactions/scan-bill',
      builder: (context, state) => const BillScannerScreen(),
    ),
    GoRoute(
      path: '/transactions/ai-insights',
      builder: (context, state) => const TransactionsAiInsightsScreen(),
    ),
    GoRoute(
      path: '/transactions/:transactionId',
      builder: (context, state) => TransactionDetailScreen(
        transactionId: state.pathParameters['transactionId'] ?? '',
      ),
    ),
  ],
);
