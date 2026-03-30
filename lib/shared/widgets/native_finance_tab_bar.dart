import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeFinanceTabBar extends StatefulWidget {
  const NativeFinanceTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  State<NativeFinanceTabBar> createState() => _NativeFinanceTabBarState();
}

class _NativeFinanceTabBarState extends State<NativeFinanceTabBar> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(covariant NativeFinanceTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _channel?.invokeMethod('setSelectedIndex', <String, dynamic>{
        'index': widget.selectedIndex,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final tabBarHeight = bottomInset + 49;

    return ColoredBox(
      color: Colors.transparent,
      child: SizedBox(
        height: tabBarHeight,
        child: UiKitView(
          viewType: 'native-swiftui-view',
          creationParams: <String, dynamic>{
            'screenId': 'financeTabBar',
            'selectedIndex': widget.selectedIndex,
            'tabBarHeight': tabBarHeight,
          },
          creationParamsCodec: const StandardMessageCodec(),
          layoutDirection: TextDirection.ltr,
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('native-swiftui-view/$id');
    _channel = channel;
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'tabSelected':
          final arguments = call.arguments as Map<dynamic, dynamic>?;
          final index = arguments?['index'] as int?;
          if (index != null) {
            widget.onTabSelected(index);
          }
          break;
      }
    });
  }
}
