import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class AppIntentService {
  AppIntentService();

  static const MethodChannel _channel = MethodChannel(
    'com.finsense.app_intents',
  );

  Future<Map<String, dynamic>?> consumePendingTransactionIntent() async {
    if (!Platform.isIOS) {
      return null;
    }

    final json = await _channel.invokeMethod<String>(
      'consumePendingTransactionIntent',
    );
    if (json == null || json.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(json);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
