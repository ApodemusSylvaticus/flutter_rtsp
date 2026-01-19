import 'package:flutter/material.dart';

/// Mixin for app lifecycle tracking.
/// Automatically calls onAppResumed() and onAppPaused()
/// when app state changes.
mixin AppLifecycleMixin<T extends StatefulWidget> on State<T> {
  bool _wasInBackground = false;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _handleResume,
      onPause: _handlePause,
      onInactive: onAppInactive,
      onDetach: onAppDetached,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _handleResume() {
    if (_wasInBackground) {
      _wasInBackground = false;
      onAppResumed();
    }
  }

  void _handlePause() {
    _wasInBackground = true;
    onAppPaused();
  }

  /// Called when app returns to foreground
  void onAppResumed() {}

  /// Called when app goes to background
  void onAppPaused() {}

  /// Called when app is inactive (e.g., incoming call)
  void onAppInactive() {}

  /// Called when app is detached
  void onAppDetached() {}
}
