import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glory_gym/core/core.dart';

import '../../domain/entities/group_class_entity.dart';

/// Schedule card for one group class: name, status chip, coach / day / time,
/// and location. Members attend without booking, so there are no actions.
final class GroupClassScheduleCard extends StatelessWidget {
  const GroupClassScheduleCard({
    super.key,
    required this.groupClass,
    this.showDay = true,
  });

  final GroupClassEntity groupClass;

  /// Hide the day column when the list is already grouped by day.
  final bool showDay;

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final c = groupClass;
    final isOver = c.isOver(DateTime.now());
    final dimmed = c.isCancelled || isOver;
    final place = [c.branchName(locale), c.location]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' • ');

    return Opacity(
      opacity: dimmed ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      c.name(locale),
                      style: context.highlightBold.copyWith(
                        decoration:
                            c.isCancelled ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(groupClass: c, isOver: isOver),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.neutral200),
            Padding(
              padding: const EdgeInsets.all(16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _Detail(
                        label: context.l10n.instructorName,
                        value: c.instructorName ?? '—',
                      ),
                    ),
                    if (showDay) ...[
                      const VerticalDivider(
                        width: 1,
                        color: AppColors.neutral200,
                      ),
                      Expanded(
                        child: _Detail(
                          label: context.l10n.date,
                          value: c.dayName(locale),
                        ),
                      ),
                    ],
                    const VerticalDivider(width: 1, color: AppColors.neutral200),
                    Expanded(
                      child: _Detail(
                        label: context.l10n.time,
                        value: GroupClassFormat.timeRange(c, locale),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (place.isNotEmpty || (c.isCancelled && c.cancelReason != null))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (place.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place,
                              style: context.captionRegular.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (c.isCancelled &&
                        (c.cancelReason?.trim().isNotEmpty ?? false)) ...[
                      if (place.isNotEmpty) const SizedBox(height: 6),
                      Text(
                        c.cancelReason!,
                        style: context.captionRegular.copyWith(
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.groupClass, required this.isOver});

  final GroupClassEntity groupClass;
  final bool isOver;

  @override
  Widget build(BuildContext context) {
    final (label, color) = groupClass.isCancelled
        ? (context.l10n.groupClassCancelled, AppColors.red)
        : isOver
            ? (context.l10n.groupClassFinished, AppColors.neutral500)
            : (context.l10n.groupClassScheduled, AppColors.green200);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: context.footnoteRegular.copyWith(color: color),
      ),
    );
  }
}

final class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: context.footnoteRegular.copyWith(color: AppColors.neutral400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(value, style: context.subtitleMedium, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Display helpers. Server times are already in gym local time, so they are
/// only re-formatted (24h → localized 12h), never timezone-converted.
abstract final class GroupClassFormat {
  static String time(String hhmm, String locale) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts.first);
    final m = parts.length > 1 ? int.tryParse(parts[1]) : 0;
    if (h == null || m == null) return hhmm;
    return DateFormat('h:mm a', locale).format(DateTime(2000, 1, 1, h, m));
  }

  static String timeRange(GroupClassEntity c, String locale) {
    final start = time(c.startTime, locale);
    final end = c.endTime;
    return end == null ? start : '$start - ${time(end, locale)}';
  }

  /// Section header for a `YYYY-MM-DD` day, e.g. "الاثنين، 16 نوفمبر".
  static String dayHeader(GroupClassEntity c, String locale) {
    final date = DateTime.tryParse(c.date);
    if (date == null) return c.dayName(locale);
    final dayName = c.dayName(locale);
    final dayMonth = DateFormat('d MMMM', locale).format(date);
    if (dayName.isEmpty) return dayMonth;
    final separator = locale == 'ar' ? '، ' : ', ';
    return '$dayName$separator$dayMonth';
  }
}
