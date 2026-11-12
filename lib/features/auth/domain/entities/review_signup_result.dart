import 'auth_session_entity.dart';

enum ReviewSignupErrorKind {
  /// 400 — a field failed validation; [ReviewSignupFailure.message] says which.
  invalid,

  /// 409 — that e-mail or phone already has an account.
  alreadyExists,

  /// 403 — sign-up is switched off (or the account cap is full).
  disabled,

  /// 429 — too many accounts from this device recently.
  rateLimited,

  other,
}

sealed class ReviewSignupResult {
  const ReviewSignupResult();
}

final class ReviewSignupSuccess extends ReviewSignupResult {
  const ReviewSignupSuccess(this.session);

  final AuthSessionEntity session;
}

final class ReviewSignupFailure extends ReviewSignupResult {
  const ReviewSignupFailure(this.kind, [this.message]);

  final ReviewSignupErrorKind kind;
  final String? message;
}
