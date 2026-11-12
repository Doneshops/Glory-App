import 'package:dio/dio.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/review_signup_result.dart';
import '../mappers/auth_mappers.dart';
import '../models/login_model.dart';

final class ReviewSignupRemoteApiService extends ApiService {
  const ReviewSignupRemoteApiService(super.dio);

  /// Fails closed: anything other than an explicit `true` is `false`.
  Future<bool> isSignupEnabled() async {
    try {
      final response = await dio.get<dynamic>(Endpoints.mobileAppConfig);
      final body = response.data;
      if (body is! Map) return false;
      final data = body['data'];
      return data is Map && data['signupEnabled'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<ReviewSignupResult> signup({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirm,
    String? phone,
    String? phoneCountryCode,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        Endpoints.reviewSignup,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
          if (phone != null && phone.isNotEmpty) ...{
            'phone': phone,
            'phoneCountryCode': ?phoneCountryCode,
          },
        },
      );
      final body = response.data;
      if (body is! Map) {
        return const ReviewSignupFailure(ReviewSignupErrorKind.other);
      }
      // Same payload as login; tolerate it with or without a `data` wrapper.
      final payload = body['data'] is Map ? body['data'] as Map : body;
      final login = LoginModel.fromJson(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
      return ReviewSignupSuccess(login.toEntity());
    } on DioException catch (e) {
      final message = _readMessage(e.response?.data);
      final kind = switch (e.response?.statusCode) {
        400 => ReviewSignupErrorKind.invalid,
        403 => ReviewSignupErrorKind.disabled,
        409 => ReviewSignupErrorKind.alreadyExists,
        429 => ReviewSignupErrorKind.rateLimited,
        _ => ReviewSignupErrorKind.other,
      };
      return ReviewSignupFailure(kind, message);
    } catch (_) {
      return const ReviewSignupFailure(ReviewSignupErrorKind.other);
    }
  }

  /// Prefers the per-field `errors` list over the generic
  /// "Validation failed" `message`.
  String? _readMessage(dynamic body) {
    if (body is! Map) return null;
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) return errors.first.toString();
    final message = body['message'];
    if (message is List) return message.join('\n');
    return message?.toString();
  }
}
