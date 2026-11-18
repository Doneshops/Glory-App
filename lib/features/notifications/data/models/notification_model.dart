import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
final class NotificationModel {
  const NotificationModel({
    required this.id,
    this.titleEn,
    this.titleAr,
    this.bodyEn,
    this.bodyAr,
    this.type,
    this.imageUrl,
    this.read = false,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  final String id;

  // Dashboard push notifications may be sent in one language only, so any
  // of the title/body fields can be null — the mapper falls back to the other.
  final String? titleEn;
  final String? titleAr;
  final String? bodyEn;
  final String? bodyAr;
  final String? type;
  final String? imageUrl;
  @JsonKey(defaultValue: false)
  final bool read;
  final DateTime? readAt;
  final DateTime createdAt;
}

@JsonSerializable()
final class UnreadCountModel {
  const UnreadCountModel({required this.count});

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountModelFromJson(json);

  final int count;
}

@JsonSerializable()
final class ReadAllModel {
  const ReadAllModel({required this.updated});

  factory ReadAllModel.fromJson(Map<String, dynamic> json) =>
      _$ReadAllModelFromJson(json);

  final int updated;
}
