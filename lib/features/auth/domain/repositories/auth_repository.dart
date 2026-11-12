import '../../../../core/result/result.dart';
import '../entities/auth_session_entity.dart';
import '../entities/member_entity.dart';
import '../entities/otp_sent_entity.dart';
import '../entities/review_signup_result.dart';

abstract interface class AuthRepository {
  Future<Result<OtpSentEntity>> register({
    required String fullName,
    required String phoneCountryCode,
    required String phone,
    required String email,
  });

  Future<Result<VerifyOtpEntity>> verifyOtp({
    required String email,
    required String purpose,
    required String code,
  });

  Future<Result<OtpSentEntity>> resendOtp({
    required String email,
    required String purpose,
  });

  Future<Result<OtpSentEntity>> forgotPassword({
    required String identifier,
  });

  Future<Result<MemberEntity>> completeRegistration({
    required String otpToken,
    required String password,
    required String passwordConfirm,
  });

  Future<Result<String>> resetPassword({
    required String otpToken,
    required String password,
    required String passwordConfirm,
  });

  Future<Result<AuthSessionEntity>> login({
    required String identifier,
    required String password,
  });

  /// Server switch for the sign-up screen (`GET /mobile/app-config`).
  Future<bool> isSignupEnabled();

  /// Creates the account and stores the session on success.
  Future<ReviewSignupResult> reviewSignup({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirm,
    String? phone,
    String? phoneCountryCode,
  });

  /// Returns `true` when a valid session exists (kept or refreshed).
  Future<Result<bool>> checkSession();

  Future<Result<MemberEntity>> getProfile();

  Future<Result<bool>> updatePushNotifications({required bool enabled});

  Future<Result<void>> logout();

  Future<Result<OtpSentEntity>> requestDeleteAccount();

  Future<Result<void>> confirmDeleteAccount({required String code});
}
