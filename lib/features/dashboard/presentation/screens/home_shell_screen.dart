import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/native_finance_tab_bar.dart';
import 'dashboard_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant HomeShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: NativeFinanceTabBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onTabSelected: widget.navigationShell.goBranch,
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
