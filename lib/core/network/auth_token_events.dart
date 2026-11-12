import 'dart:async';

/// Broadcasts auth token lifecycle events for Dio and long-lived connections.
abstract final class AuthTokenEvents {
  static final _refreshedController = StreamController<void>.broadcast();
  static final _sessionExpiredController = StreamController<void>.broadcast();

  static bool _sessionExpiredPending = false;

  static Stream<void> get onRefreshed => _refreshedController.stream;

  /// Fired once when a protected API returns 401 and refresh cannot recover.
  static Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  static void notifyRefreshed() {
    _sessionExpiredPending = false;
    if (!_refreshedController.isClosed) {
      _refreshedController.add(null);
    }
  }

  static void notifySessionExpired() {
    if (_sessionExpiredPending) return;
    _sessionExpiredPending = true;
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }
}
