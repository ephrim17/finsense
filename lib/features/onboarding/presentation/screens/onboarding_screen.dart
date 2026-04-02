import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../controllers/onboarding_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _pageIndex = 0;

  static const _pages = [
    _OnboardingPageData(
      title: 'Track money without friction',
      description:
          'Log income and expenses in seconds, then let FinSense turn them into clean trends and reports.',
      accent: Color(0xFF8B5CF6),
      secondary: Color(0xFFE9DDFF),
      icon: Icons.wallet_rounded,
      bullets: ['Fast add flow', 'Beautiful reports', 'Smart categorisation'],
    ),
    _OnboardingPageData(
      title: 'Scan bills with delight',
      description:
          'Capture a receipt, extract the amount, and turn it into a transaction with a polished AI-assisted flow.',
      accent: Color(0xFF4F7CFF),
      secondary: Color(0xFFE3ECFF),
      icon: Icons.document_scanner_rounded,
      bullets: ['Bill OCR', 'Auto transaction entry', 'Smooth loading effects'],
    ),
    _OnboardingPageData(
      title: 'Plan and learn with FinSense',
      description:
          'Use Plan for budgets and goals, then open FinSense Insights for coaching, health reviews, and ideas.',
      accent: Color(0xFF2DBE8D),
      secondary: Color(0xFFE7FBF3),
      icon: Icons.auto_awesome_rounded,
      bullets: ['Budgets + goals together', 'Ask FinSense', 'FinSense Insights'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (!mounted) {
      return;
    }
    final user = ref.read(currentUserProvider).valueOrNull;
    context.go(user == null ? '/sign-in' : '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _pageIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F1FF), Colors.white, Color(0xFFF8FCFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    const Text(
                      'FinSense',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _pageIndex = value),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _OnboardingPage(
                      controller: _pageController,
                      index: index,
                      data: _pages[index],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(_pages.length, (index) {
                        final isActive = index == _pageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          margin: const EdgeInsets.only(right: 8),
                          width: isActive ? 28 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isActive
                                ? _pages[_pageIndex].accent
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () async {
                        if (isLastPage) {
                          await _finish();
                          return;
                        }
                        await _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(isLastPage ? 'Get Started' : 'Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.accent,
    required this.secondary,
    required this.icon,
    required this.bullets,
  });

  final String title;
  final String description;
  final Color accent;
  final Color secondary;
  final IconData icon;
  final List<String> bullets;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.controller,
    required this.index,
    required this.data,
  });

  final PageController controller;
  final int index;
  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double page = index.toDouble();
        if (controller.hasClients && controller.position.hasContentDimensions) {
          page = controller.page ?? index.toDouble();
        }
        final distance = (page - index).abs().clamp(0.0, 1.0);
        final translateY = 28 * distance;
        final scale = 1 - (0.08 * distance);

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: _AnimatedFeatureArtwork(data: data),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              data.description,
              style: const TextStyle(
                fontSize: 17,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            ...data.bullets.asMap().entries.map(
              (entry) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 500 + (entry.key * 120)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: data.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: data.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _AnimatedFeatureArtwork extends StatefulWidget {
  const _AnimatedFeatureArtwork({required this.data});

  final _OnboardingPageData data;

  @override
  State<_AnimatedFeatureArtwork> createState() => _AnimatedFeatureArtworkState();
}

class _AnimatedFeatureArtworkState extends State<_AnimatedFeatureArtwork>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final angle = _controller.value * math.pi * 2;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    widget.data.secondary,
                    widget.data.secondary.withValues(alpha: 0.18),
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
            for (final orbit in [0.0, 2.0, 4.0])
              Transform.translate(
                offset: Offset(
                  math.cos(angle + orbit) * 102,
                  math.sin(angle + orbit) * 70,
                ),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: widget.data.accent.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 1600),
              curve: Curves.easeInOut,
              builder: (context, value, child) => Transform.scale(
                scale: value + (math.sin(angle) * 0.04),
                child: child,
              ),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.data.accent, widget.data.accent.withBlue(255)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(44),
                  boxShadow: [
                    BoxShadow(
                      color: widget.data.accent.withValues(alpha: 0.28),
                      blurRadius: 38,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Icon(
                  widget.data.icon,
                  size: 72,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
