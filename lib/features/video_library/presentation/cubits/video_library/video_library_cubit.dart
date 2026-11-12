import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/library_video_entity.dart';
import '../../../domain/repositories/video_library_repository.dart';

part 'video_library_state.dart';

final class VideoLibraryCubit extends Cubit<VideoLibraryState> {
  VideoLibraryCubit(this._repository) : super(const VideoLibraryState());

  static const _pageSize = 20;
  static const _searchDebounce = Duration(milliseconds: 400);

  final VideoLibraryRepository _repository;
  Timer? _debounce;

  /// Loads categories (once) and the first page of videos.
  Future<void> init() async {
    unawaited(_loadCategories());
    await load();
  }

  Future<void> load({bool refresh = false}) async {
    emit(
      state.copyWith(
        status: VideoLibraryStatus.loading,
        clearError: true,
        videos: refresh ? const [] : state.videos,
        page: 1,
      ),
    );

    final result = await _repository.getVideos(
      limit: _pageSize,
      search: state.search,
      category: state.selectedCategory,
      audience: state.audience,
    );
    if (isClosed) return;

    result.fold(
      onSuccess: (page) => emit(
        state.copyWith(
          status: VideoLibraryStatus.loaded,
          videos: page.items,
          page: page.page,
          totalPages: page.totalPages,
        ),
      ),
      onFailure: (failure) => emit(
        state.copyWith(
          status: VideoLibraryStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    emit(state.copyWith(status: VideoLibraryStatus.loadingMore));

    final result = await _repository.getVideos(
      page: state.page + 1,
      limit: _pageSize,
      search: state.search,
      category: state.selectedCategory,
      audience: state.audience,
    );
    if (isClosed) return;

    result.fold(
      onSuccess: (page) => emit(
        state.copyWith(
          status: VideoLibraryStatus.loaded,
          videos: [...state.videos, ...page.items],
          page: page.page,
          totalPages: page.totalPages,
        ),
      ),
      onFailure: (failure) => emit(
        state.copyWith(
          status: VideoLibraryStatus.loaded,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  void search(String query) {
    final trimmed = query.trim();
    if (trimmed == state.search) return;
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      emit(state.copyWith(search: trimmed));
      load(refresh: true);
    });
  }

  void selectCategory(String? category) {
    if (category == state.selectedCategory) return;
    emit(
      category == null
          ? state.copyWith(clearCategory: true)
          : state.copyWith(selectedCategory: category),
    );
    load(refresh: true);
  }

  void selectAudience(VideoAudience? audience) {
    if (audience == state.audience) return;
    emit(
      audience == null
          ? state.copyWith(clearAudience: true)
          : state.copyWith(audience: audience),
    );
    load(refresh: true);
  }

  /// Applies the filter sheet's choices with a single reload.
  void applyFilters({VideoAudience? audience, String? category}) {
    if (audience == state.audience && category == state.selectedCategory) {
      return;
    }
    emit(
      state.copyWith(
        audience: audience,
        clearAudience: audience == null,
        selectedCategory: category,
        clearCategory: category == null,
      ),
    );
    load(refresh: true);
  }

  Future<void> _loadCategories() async {
    final result = await _repository.getCategories();
    if (isClosed) return;
    result.fold(
      onSuccess: (categories) => emit(state.copyWith(categories: categories)),
      onFailure: (_) {},
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
