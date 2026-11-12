import 'dart:async';

import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import '../router/app_routes.dart';
import '../../app/router/app_router.dart';
import '../../features/auth/presentation/cubits/user_profile/user_profile_cubit.dart';
import '../../features/coach_chat/data/datasources/coach_chat_socket_service.dart';
import '../../features/coach_chat/presentation/cubits/coach_chat_unread/coach_chat_unread_cubit.dart';
import '../../features/notifications/presentation/cubits/notifications_unread/notifications_unread_cubit.dart';
import 'auth_token_events.dart';

/// Listens for global 401 session expiry from [AuthInterceptor] and routes to login.
final class SessionExpiredListener extends StatefulWidget {
  const SessionExpiredListener({required this.child, super.key});

  final Widget child;

  @override
  State<SessionExpiredListener> createState() => _SessionExpiredListenerState();
}

final class _SessionExpiredListenerState extends State<SessionExpiredListener> {
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = AuthTokenEvents.onSessionExpired.listen((_) {
      _onSessionExpired();
    });
  }

  void _onSessionExpired() {
    sl<UserProfileCubit>().clear();
    sl<CoachChatSocketService>().disconnect();
    sl<CoachChatUnreadCubit>().resetCount();
    sl<NotificationsUnreadCubit>().resetCount();

    final router = AppRouter.router;
    final location = router.routeInformationProvider.value.uri.path;
    if (location != AppRoutes.login) {
      router.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
