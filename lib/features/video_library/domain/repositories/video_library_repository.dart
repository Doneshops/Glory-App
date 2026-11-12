import '../../../../core/result/result.dart';
import '../entities/library_video_entity.dart';

abstract interface class VideoLibraryRepository {
  Future<Result<LibraryVideosPageEntity>> getVideos({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    VideoAudience? audience,
  });

  Future<Result<List<String>>> getCategories();
}
