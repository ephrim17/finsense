import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/native_finance_tab_bar.dart';
import 'dashboard_screen.dart';

class HomeShellScreen extends StatelessWidget {
  const HomeShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: NativeFinanceTabBar(
        selectedIndex: navigationShell.currentIndex,
        onTabSelected: navigationShell.goBranch,
      ),
    );
  }
}

class HomeShellBranch extends StatelessWidget {
  const HomeShellBranch({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}
