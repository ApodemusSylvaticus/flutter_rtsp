import 'package:flutter/material.dart';

/// Mixin for app lifecycle tracking.
/// Automatically calls onAppResumed() and onAppPaused()
/// when app state changes.
mixin AppLifecycleMixin<T extends StatefulWidget> on State<T> {
  bool _wasInBackground = false;
  late final AppLifecycleListener _lifecycleListener;

  void _logLifecycle(String message) {
    print('[AppLifecycleMixin] $message');
  }

  @override
  void initState() {
    super.initState();
    _logLifecycle('initState() - setting up lifecycle listener');
    _lifecycleListener = AppLifecycleListener(
      onResume: _handleResume,
      onPause: _handlePause,
      onInactive: _handleInactive,
      onDetach: _handleDetach,
      onHide: _handleHide,
      onShow: _handleShow,
    );
  }

  @override
  void dispose() {
    _logLifecycle('dispose() - disposing lifecycle listener');
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _handleResume() {
    _logLifecycle('_handleResume() called, _wasInBackground=$_wasInBackground');
    if (_wasInBackground) {
      _wasInBackground = false;
      _logLifecycle('Calling onAppResumed()');
      onAppResumed();
    } else {
      _logLifecycle('Not calling onAppResumed() - was not in background');
    }
  }

  void _handlePause() {
    _logLifecycle('_handlePause() called, setting _wasInBackground=true');
    _wasInBackground = true;
    onAppPaused();
  }

  void _handleInactive() {
    _logLifecycle('_handleInactive() called');
    onAppInactive();
  }

  void _handleDetach() {
    _logLifecycle('_handleDetach() called');
    onAppDetached();
  }

  void _handleHide() {
    _logLifecycle('_handleHide() called');
  }

  void _handleShow() {
    _logLifecycle('_handleShow() called');
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
