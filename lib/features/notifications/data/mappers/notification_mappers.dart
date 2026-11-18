import '../../../../core/network/models/pagination_meta_model.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';
import '../models/notifications_api_responses.dart';

extension NotificationModelX on NotificationModel {
  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        titleAr: _firstNonEmpty(titleAr, titleEn),
        titleEn: _firstNonEmpty(titleEn, titleAr),
        bodyAr: _firstNonEmpty(bodyAr, bodyEn),
        bodyEn: _firstNonEmpty(bodyEn, bodyAr),
        createdAt: createdAt,
        isRead: read,
        type: type,
        imageUrl: imageUrl,
      );
}

extension NotificationsApiResponseX on NotificationsApiResponse {
  NotificationsPageEntity? toPageEntity() {
    if (data == null) return null;
    final meta = this.meta ??
        const PaginationMetaModel(page: 1, limit: 20, total: 0, totalPages: 1);
    return NotificationsPageEntity(
      items: data!.map((item) => item.toEntity()).toList(),
      page: meta.page,
      totalPages: meta.totalPages,
    );
  }
}

extension NotificationApiResponseX on NotificationApiResponse {
  NotificationEntity? toEntity() => data?.toEntity();
}

/// Returns [preferred] unless it's null/blank, then [fallback], else ''.
String _firstNonEmpty(String? preferred, String? fallback) {
  if (preferred != null && preferred.trim().isNotEmpty) return preferred;
  return fallback ?? '';
}
