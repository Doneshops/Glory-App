part of 'review_signup_cubit.dart';

enum ReviewSignupStatus { initial, loading, success, failure }

final class ReviewSignupState extends Equatable {
  const ReviewSignupState({
    this.status = ReviewSignupStatus.initial,
    this.session,
    this.errorKind,
    this.errorMessage,
  });

  final ReviewSignupStatus status;
  final AuthSessionEntity? session;
  final ReviewSignupErrorKind? errorKind;
  final String? errorMessage;

  bool get isLoading => status == ReviewSignupStatus.loading;

  @override
  List<Object?> get props => [status, session, errorKind, errorMessage];
}
