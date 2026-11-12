import '../../../../core/result/result.dart';
import '../../domain/entities/library_video_entity.dart';
import '../../domain/repositories/video_library_repository.dart';
import '../datasources/video_library_remote_api_service.dart';

final class VideoLibraryRepositoryImpl implements VideoLibraryRepository {
  const VideoLibraryRepositoryImpl(this._remote);

  final VideoLibraryRemoteApiService _remote;

  @override
  Future<Result<LibraryVideosPageEntity>> getVideos({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    VideoAudience? audience,
  }) => _remote.getVideos(
    page: page,
    limit: limit,
    search: search,
    category: category,
    audience: audience,
  );

  @override
  Future<Result<List<String>>> getCategories() => _remote.getCategories();
}
