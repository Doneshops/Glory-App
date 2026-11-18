import '../../domain/entities/group_class_entity.dart';
import '../models/group_class_model.dart';

extension GroupClassModelX on GroupClassModel {
  GroupClassEntity toEntity() => GroupClassEntity(
        id: id,
        nameAr: _firstNonEmpty(nameAr, nameEn),
        nameEn: _firstNonEmpty(nameEn, nameAr),
        date: date,
        dayNameAr: dayNameAr ?? dayNameEn ?? '',
        dayNameEn: dayNameEn ?? dayNameAr ?? '',
        startTime: startTime,
        endTime: endTime,
        startAt: startAt,
        endAt: endAt,
        durationMinutes: durationMinutes,
        status: switch (status) {
          'CANCELLED' => GroupClassStatus.cancelled,
          'COMPLETED' => GroupClassStatus.completed,
          _ => GroupClassStatus.scheduled,
        },
        instructorName: instructor?.fullName,
        instructorAvatarUrl: instructor?.avatarUrl,
        branchNameAr: branch?.nameAr,
        branchNameEn: branch?.nameEn,
        location: location,
        cancelReason: cancelReason,
      );
}

String _firstNonEmpty(String? a, String? b) {
  if (a != null && a.trim().isNotEmpty) return a;
  return b ?? '';
}
