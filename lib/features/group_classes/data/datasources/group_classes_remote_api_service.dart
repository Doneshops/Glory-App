import '../../../../core/error/app_failure.dart';
import '../../../../core/l10n/fallback_messages.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/result/result.dart';
import '../models/group_class_model.dart';

final class GroupClassesRemoteApiService extends ApiService {
  const GroupClassesRemoteApiService(super.dio);

  /// `GET /mobile/group-classes?from=&to=` — both `YYYY-MM-DD`, inclusive.
  /// Omitted → server defaults to today (Asia/Amman) … today + 6 days.
  /// No pagination: one call returns the whole range, nearest first.
  Future<Result<List<GroupClassModel>>> getGroupClasses({
    String? from,
    String? to,
  }) async {
    final result = await get<GroupClassesApiResponse>(
      Endpoints.mobileGroupClasses,
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
      fromJson: (data) =>
          GroupClassesApiResponse.fromJson(data as Map<String, dynamic>),
    );

    return switch (result) {
      Success(:final data) when data.success =>
        Success(data.data ?? const []),
      Success(:final data) => Failure(
          ServerFailure(data.message ?? FallbackMessages.errorTryAgain),
        ),
      Failure(:final failure) => Failure(failure),
    };
  }
}
