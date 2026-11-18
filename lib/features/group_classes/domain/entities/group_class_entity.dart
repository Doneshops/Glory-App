enum GroupClassStatus { scheduled, cancelled, completed }

final class GroupClassEntity {
  const GroupClassEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.date,
    required this.dayNameAr,
    required this.dayNameEn,
    required this.startTime,
    required this.status,
    this.endTime,
    this.startAt,
    this.endAt,
    this.durationMinutes,
    this.instructorName,
    this.instructorAvatarUrl,
    this.branchNameAr,
    this.branchNameEn,
    this.location,
    this.cancelReason,
  });

  final String id;
  final String nameAr;
  final String nameEn;

  /// `YYYY-MM-DD` in gym local time — use for grouping by day.
  final String date;
  final String dayNameAr;
  final String dayNameEn;

  /// `HH:mm` in gym local time.
  final String startTime;
  final String? endTime;
  final DateTime? startAt;
  final DateTime? endAt;
  final int? durationMinutes;
  final GroupClassStatus status;
  final String? instructorName;
  final String? instructorAvatarUrl;
  final String? branchNameAr;
  final String? branchNameEn;
  final String? location;
  final String? cancelReason;

  bool get isCancelled => status == GroupClassStatus.cancelled;

  /// True once the class has ended (or started, when there's no end time).
  bool isOver(DateTime now) {
    if (status == GroupClassStatus.completed) return true;
    final reference = endAt ?? startAt;
    return reference != null && reference.isBefore(now);
  }

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;
  String dayName(String locale) => locale == 'ar' ? dayNameAr : dayNameEn;
  String? branchName(String locale) =>
      locale == 'ar' ? branchNameAr ?? branchNameEn : branchNameEn ?? branchNameAr;
}
