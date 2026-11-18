import 'package:json_annotation/json_annotation.dart';

part 'group_class_model.g.dart';

/// One scheduled group class from `GET /mobile/group-classes`.
@JsonSerializable(createToJson: false)
final class GroupClassModel {
  const GroupClassModel({
    required this.id,
    this.nameEn,
    this.nameAr,
    required this.date,
    this.dayOfWeek,
    this.dayNameEn,
    this.dayNameAr,
    required this.startTime,
    this.endTime,
    this.startAt,
    this.endAt,
    this.durationMinutes,
    this.instructor,
    this.branch,
    this.location,
    this.capacity,
    this.status,
    this.cancelReason,
  });

  factory GroupClassModel.fromJson(Map<String, dynamic> json) =>
      _$GroupClassModelFromJson(json);

  final String id;
  final String? nameEn;
  final String? nameAr;

  /// `YYYY-MM-DD`, already in gym local time (Asia/Amman).
  final String date;

  /// 0 = Sunday … 6 = Saturday.
  final int? dayOfWeek;
  final String? dayNameEn;
  final String? dayNameAr;

  /// `HH:mm`, already in gym local time — display as-is.
  final String startTime;
  final String? endTime;

  /// UTC — for sorting / "is it over" checks only, never for display.
  final DateTime? startAt;
  final DateTime? endAt;
  final int? durationMinutes;
  final GroupClassInstructorModel? instructor;
  final GroupClassBranchModel? branch;
  final String? location;
  final int? capacity;

  /// `SCHEDULED` | `CANCELLED` | `COMPLETED`.
  final String? status;
  final String? cancelReason;
}

@JsonSerializable(createToJson: false)
final class GroupClassInstructorModel {
  const GroupClassInstructorModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  factory GroupClassInstructorModel.fromJson(Map<String, dynamic> json) =>
      _$GroupClassInstructorModelFromJson(json);

  final String id;
  final String fullName;
  final String? avatarUrl;
}

@JsonSerializable(createToJson: false)
final class GroupClassBranchModel {
  const GroupClassBranchModel({required this.id, this.nameEn, this.nameAr});

  factory GroupClassBranchModel.fromJson(Map<String, dynamic> json) =>
      _$GroupClassBranchModelFromJson(json);

  final String id;
  final String? nameEn;
  final String? nameAr;
}

@JsonSerializable(createToJson: false)
final class GroupClassesApiResponse {
  const GroupClassesApiResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory GroupClassesApiResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupClassesApiResponseFromJson(json);

  final bool success;
  final List<GroupClassModel>? data;
  final String? message;
}
