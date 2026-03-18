import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            SwiftUiNavigator.open(
              context,
              screenId: SwiftUiScreenIds.commandDeck,
            );
          },
          child: const Text('Open Futuristic SwiftUI View'),
        ),
      ),
    );
  }
}

final class SwiftUiNavigator {
  const SwiftUiNavigator._();

  static void open(
    BuildContext context, {
    required String screenId,
    String? title,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NativeSwiftUiPage(
          screenId: screenId,
          title: title ?? _defaultTitleFor(screenId),
        ),
      ),
    );
  }

  static String _defaultTitleFor(String screenId) {
    switch (screenId) {
      case SwiftUiScreenIds.commandDeck:
        return 'Command Deck';
      default:
        return 'SwiftUI Screen';
    }
  }
}

final class SwiftUiScreenIds {
  const SwiftUiScreenIds._();

  static const commandDeck = 'commandDeck';
}

class NativeSwiftUiPage extends StatelessWidget {
  const NativeSwiftUiPage({
    super.key,
    required this.screenId,
    required this.title,
  });

  final String screenId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: NativeSwiftUiContainer(screenId: screenId)),
    );
  }
}

class NativeSwiftUiContainer extends StatelessWidget {
  const NativeSwiftUiContainer({super.key, required this.screenId});

  final String screenId;

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'native-swiftui-view',
          creationParams: <String, dynamic>{'screenId': screenId},
          creationParamsCodec: const StandardMessageCodec(),
          layoutDirection: TextDirection.ltr,
        );
      default:
        return const Center(
          child: Text('This native SwiftUI screen is only available on iOS.'),
        );
    }
  }
}
