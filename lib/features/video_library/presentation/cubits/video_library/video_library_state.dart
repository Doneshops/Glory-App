part of 'video_library_cubit.dart';

enum VideoLibraryStatus { initial, loading, loaded, loadingMore, failure }

final class VideoLibraryState extends Equatable {
  const VideoLibraryState({
    this.status = VideoLibraryStatus.initial,
    this.videos = const [],
    this.categories = const [],
    this.selectedCategory,
    this.audience,
    this.search = '',
    this.page = 1,
    this.totalPages = 1,
    this.errorMessage,
  });

  final VideoLibraryStatus status;
  final List<LibraryVideoEntity> videos;
  final List<String> categories;
  final String? selectedCategory;

  /// `null` = everyone (the server has no default for public viewers).
  final VideoAudience? audience;
  final String search;
  final int page;
  final int totalPages;
  final String? errorMessage;

  bool get isLoading => status == VideoLibraryStatus.loading;
  bool get isLoadingMore => status == VideoLibraryStatus.loadingMore;
  bool get hasMore => page < totalPages;

  /// Filters set from the filter sheet (search is counted separately).
  int get activeFilterCount =>
      (audience != null ? 1 : 0) + (selectedCategory != null ? 1 : 0);

  bool get hasFilters =>
      search.isNotEmpty || selectedCategory != null || audience != null;

  VideoLibraryState copyWith({
    VideoLibraryStatus? status,
    List<LibraryVideoEntity>? videos,
    List<String>? categories,
    String? selectedCategory,
    bool clearCategory = false,
    VideoAudience? audience,
    bool clearAudience = false,
    String? search,
    int? page,
    int? totalPages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VideoLibraryState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      categories: categories ?? this.categories,
      selectedCategory: clearCategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      audience: clearAudience ? null : audience ?? this.audience,
      search: search ?? this.search,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    videos,
    categories,
    selectedCategory,
    audience,
    search,
    page,
    totalPages,
    errorMessage,
  ];
}
