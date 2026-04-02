import 'dart:io';

import 'package:path_provider/path_provider.dart';

class OnboardingStorage {
  static const _fileName = '.finsense_onboarding_complete';

  Future<bool> isCompleted() async {
    try {
      final file = await _file;
      return file.exists();
    } catch (_) {
      return false;
    }
  }

  Future<void> markCompleted() async {
    final file = await _file;
    await file.writeAsString('done', flush: true);
  }

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}
