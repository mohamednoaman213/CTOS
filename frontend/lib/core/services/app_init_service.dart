import 'dart:async';

/// Handles all async startup work. The splash screen awaits [initFuture]
/// so navigation only happens after real initialization completes.
class AppInitService {
  static final instance = AppInitService._();
  AppInitService._();

  final _completer = Completer<void>();

  /// Resolves when initialization is complete.
  Future<void> get initFuture => _completer.future;

  /// Called from main() before runApp. Runs initialization in the background.
  Future<void> initialize() async {
    try {
      // Yield to the event loop so all platform bindings (geolocator,
      // image_picker, ML Kit) are fully registered before first use.
      await Future<void>.delayed(Duration.zero);
      // Additional async init steps (e.g. SharedPreferences, remote config)
      // can be added here with await before _completer.complete().
    } finally {
      _completer.complete();
    }
  }
}
