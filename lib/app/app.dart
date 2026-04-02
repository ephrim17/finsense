import 'package:flutter/material.dart';

import 'app_intent_sync.dart';
import '../shared/theme/app_theme.dart';
import 'router/app_router.dart';
import 'widget_snapshot_sync.dart';

class FinSenseApp extends StatelessWidget {
  const FinSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FinSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        return AppIntentSync(
          child: WidgetSnapshotSync(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
