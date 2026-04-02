import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/finance_enums.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../controllers/transaction_providers.dart';

class BillScannerScreen extends ConsumerStatefulWidget {
  const BillScannerScreen({super.key});

  @override
  ConsumerState<BillScannerScreen> createState() => _BillScannerScreenState();
}

class _BillScannerScreenState extends ConsumerState<BillScannerScreen> {
  bool _isSaving = false;

  void _showToast(String message) {
    final messenger = ScaffoldMessenger.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 92),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('native-swiftui-view/$id');
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'closeBillScanner':
          if (!mounted) {
            return;
          }
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/dashboard');
          }
          break;
        case 'scanFailed':
          final arguments = call.arguments as Map<dynamic, dynamic>?;
          final message =
              arguments?['message'] as String? ??
              'Unable to scan that bill. Please try another image.';
          if (!mounted) {
            return;
          }
          _showToast(message);
          break;
        case 'scanCompleted':
          final arguments = call.arguments as Map<dynamic, dynamic>?;
          await _saveScannedTransaction(arguments);
          break;
      }
    });
  }

  Future<void> _saveScannedTransaction(Map<dynamic, dynamic>? arguments) async {
    if (!mounted || _isSaving) {
      return;
    }

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      _showToast('Please sign in to save scanned bills.');
      return;
    }

    final amount = _parseAmount(arguments?['amount']);
    if (amount <= 0) {
      _showToast('No valid bill total was found.');
      return;
    }

    _isSaving = true;
    try {
      final title = ((arguments?['title'] as String?)?.trim().isNotEmpty ?? false)
          ? (arguments?['title'] as String).trim()
          : 'Scanned Bill';

      await ref
          .read(transactionActionControllerProvider.notifier)
          .save(
            userId: user.id,
            title: title,
            amount: amount,
            categoryName: _inferCategory(title),
            accountId: 'Main Account',
            paymentMethod: 'Card',
            transactionDate: DateTime.now(),
            type: TransactionType.expense,
            note: 'Added from bill scan',
          );

      if (!mounted) {
        return;
      }

      _showToast('Added $title for ${amount.toStringAsFixed(2)}');
      context.pop();
    } finally {
      _isSaving = false;
    }
  }

  double _parseAmount(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _inferCategory(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('grocery') || normalized.contains('market')) {
      return 'Groceries';
    }
    if (normalized.contains('hotel') ||
        normalized.contains('restaurant') ||
        normalized.contains('cafe') ||
        normalized.contains('food')) {
      return 'Food & Dining';
    }
    if (normalized.contains('fuel') || normalized.contains('taxi')) {
      return 'Transport';
    }
    return 'Food & Dining';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: UiKitView(
        viewType: 'native-swiftui-view',
        creationParams: const <String, dynamic>{'screenId': 'billScanner'},
        creationParamsCodec: StandardMessageCodec(),
        layoutDirection: TextDirection.ltr,
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }
}
