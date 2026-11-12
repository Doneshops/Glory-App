import 'package:equatable/equatable.dart';

enum VideoAudience { male, female, unknown }

final class LibraryVideoEntity extends Equatable {
  const LibraryVideoEntity({
    required this.id,
    required this.audience,
    required this.titleEn,
    required this.videoUrl,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    this.category,
    this.thumbnailUrl,
    this.duration,
    this.createdAt,
  });

  final String id;
  final VideoAudience audience;
  final String titleEn;
  final String? titleAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? category;

  /// Embeddable Vimeo player URL.
  final String videoUrl;
  final String? thumbnailUrl;
  final String? duration;
  final DateTime? createdAt;

  String title(String languageCode) {
    final ar = titleAr;
    if (languageCode == 'ar' && ar != null && ar.isNotEmpty) return ar;
    return titleEn;
  }

  @override
  List<Object?> get props => [
    id,
    audience,
    titleEn,
    titleAr,
    descriptionEn,
    descriptionAr,
    category,
    videoUrl,
    thumbnailUrl,
    duration,
    createdAt,
  ];
}

final class LibraryVideosPageEntity extends Equatable {
  const LibraryVideosPageEntity({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  final List<LibraryVideoEntity> items;
  final int page;
  final int totalPages;

  @override
  List<Object?> get props => [items, page, totalPages];
}
