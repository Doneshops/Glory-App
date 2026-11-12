import '../../../../core/error/app_failure.dart';
import '../../../../core/l10n/fallback_messages.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/library_video_entity.dart';
import '../models/video_library_models.dart';

final class VideoLibraryRemoteApiService extends ApiService {
  const VideoLibraryRemoteApiService(super.dio);

  Future<Result<LibraryVideosPageEntity>> getVideos({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    VideoAudience? audience,
  }) => _read(
    Endpoints.mobileVideos,
    queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category.isNotEmpty) 'category': category,
      if (audience == VideoAudience.male) 'audience': 'MALE',
      if (audience == VideoAudience.female) 'audience': 'FEMALE',
    },
    parse: readLibraryVideosPage,
  );

  Future<Result<List<String>>> getCategories() =>
      _read(Endpoints.mobileVideosCategories, parse: readVideoCategories);

  Future<Result<T>> _read<T>(
    String path, {
    required T Function(Map<String, dynamic> body) parse,
    Map<String, dynamic>? queryParameters,
  }) {
    return get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      fromJson: (json) => asStringKeyedMap(json),
    ).then((result) {
      return result.when(
        success: (map) {
          if (map['success'] == false) {
            return Failure(
              ServerFailure(
                map['message']?.toString() ?? FallbackMessages.errorTryAgain,
              ),
            );
          }
          return Success(parse(map));
        },
        failure: Failure.new,
      );
    });
  }
}
