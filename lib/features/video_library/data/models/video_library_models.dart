import '../../domain/entities/library_video_entity.dart';

Map<String, dynamic> asStringKeyedMap(dynamic value) {
  if (value is! Map) return const {};
  return value.map((key, item) => MapEntry(key.toString(), item));
}

String? _readNonEmpty(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

/// `00:00` means Vimeo hasn't reported a length yet — treat it as unknown.
String? _readDuration(dynamic value) {
  final text = _readNonEmpty(value);
  if (text == null || RegExp(r'^[0:]+$').hasMatch(text)) return null;
  return text;
}

VideoAudience readVideoAudience(dynamic value) {
  return switch (value?.toString().toUpperCase()) {
    'MALE' => VideoAudience.male,
    'FEMALE' => VideoAudience.female,
    _ => VideoAudience.unknown,
  };
}

LibraryVideoEntity readLibraryVideo(dynamic value) {
  final map = asStringKeyedMap(value);
  return LibraryVideoEntity(
    id: map['id']?.toString() ?? '',
    audience: readVideoAudience(map['audience']),
    titleEn: map['titleEn']?.toString() ?? '',
    titleAr: _readNonEmpty(map['titleAr']),
    descriptionEn: _readNonEmpty(map['descriptionEn']),
    descriptionAr: _readNonEmpty(map['descriptionAr']),
    category: _readNonEmpty(map['category']),
    videoUrl: map['videoUrl']?.toString() ?? '',
    thumbnailUrl: _readNonEmpty(map['thumbnailUrl']),
    duration: _readDuration(map['duration']),
    createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
  );
}

/// Accepts `{ data: [...], meta: {...} }` as well as `{ data: { items, meta } }`.
LibraryVideosPageEntity readLibraryVideosPage(dynamic value) {
  final map = asStringKeyedMap(value);
  final data = map['data'];
  final nested = asStringKeyedMap(data);
  final rawItems = data is List ? data : nested['items'] ?? nested['data'];
  final items = (rawItems is List ? rawItems : const [])
      .map(readLibraryVideo)
      .where((video) => video.videoUrl.isNotEmpty)
      .toList(growable: false);
  final meta = asStringKeyedMap(map['meta'] ?? nested['meta']);

  return LibraryVideosPageEntity(
    items: items,
    page: (meta['page'] as num?)?.toInt() ?? 1,
    totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
  );
}

/// Accepts `{ data: { categories: [...] } }` (current API), plus
/// `{ data: [...] }` and `{ data: { items: [...] } }`.
List<String> readVideoCategories(dynamic value) {
  final map = asStringKeyedMap(value);
  final raw = map['data'];
  final nested = asStringKeyedMap(raw);
  final data = raw is List ? raw : nested['categories'] ?? nested['items'];
  if (data is! List) return const [];
  return data
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
