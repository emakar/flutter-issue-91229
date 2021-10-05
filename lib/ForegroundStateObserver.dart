import 'package:flutter/material.dart';

mixin ForegroundStateObserver<T extends StatefulWidget> on State<T> {
  late final _WidgetsBindingObserver _observer = _WidgetsBindingObserver(
    didForeground: didForeground,
    didBackground: didBackground,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(_observer);
    _observer.checkForeground();
  }

  @override
  void dispose() {
    _observer._didBackground();
    WidgetsBinding.instance!.removeObserver(_observer);
    super.dispose();
  }

  void didForeground() {}

  void didBackground() {}
}

class _WidgetsBindingObserver extends WidgetsBindingObserver {
  bool _foreground = false;
  final void Function() didForeground;
  final void Function() didBackground;

  _WidgetsBindingObserver({required this.didForeground, required this.didBackground});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _didForeground();
        break;
      case AppLifecycleState.inactive:
        _didBackground();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void checkForeground() {
    if (WidgetsBinding.instance!.lifecycleState == AppLifecycleState.resumed) {
      _didForeground();
    } else {
      _didBackground();
    }
  }

  void _didForeground() {
    if (_foreground) return;
    _foreground = true;
    didForeground();
  }

  void _didBackground() {
    if (!_foreground) return;
    _foreground = false;
    didBackground();
  }
}
