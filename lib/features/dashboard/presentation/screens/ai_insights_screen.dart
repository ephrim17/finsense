import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key, required this.snapshotJson});

  final String snapshotJson;

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('native-swiftui-view/$id');
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'closeAIInsights':
          if (!mounted) {
            return;
          }
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/dashboard');
          }
          break;
        case 'openTransactionDetails':
          final arguments = call.arguments as Map<dynamic, dynamic>?;
          final transactionId = arguments?['transactionId'] as String?;
          if (!mounted || transactionId == null || transactionId.isEmpty) {
            return;
          }
          context.push('/transactions/$transactionId');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: UiKitView(
        viewType: 'native-swiftui-view',
        creationParams: <String, dynamic>{
          'screenId': 'aiInsightsChat',
          'snapshotJson': widget.snapshotJson,
        },
        creationParamsCodec: const StandardMessageCodec(),
        layoutDirection: TextDirection.ltr,
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }
}
