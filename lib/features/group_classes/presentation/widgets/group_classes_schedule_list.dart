import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glory_gym/core/core.dart';

import '../../domain/entities/group_class_entity.dart';
import '../cubits/group_classes/group_classes_cubit.dart';
import 'group_class_card.dart';

/// Full group-class schedule for this week (`GET /mobile/group-classes`),
/// grouped by day. Used by the "الحصص الجماعية" tab of "تماريني".
final class GroupClassesScheduleList extends StatelessWidget {
  const GroupClassesScheduleList({
    super.key,
    this.padding = const EdgeInsets.all(18),
  });

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupClassesCubit>()..load(),
      child: _ScheduleView(padding: padding),
    );
  }
}

final class _ScheduleView extends StatelessWidget {
  const _ScheduleView({required this.padding});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;

    return BlocBuilder<GroupClassesCubit, GroupClassesState>(
      builder: (context, state) {
        Future<void> refresh() => context.read<GroupClassesCubit>().load();

        if (state.isLoading && state.classes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == GroupClassesStatus.failure &&
            state.classes.isEmpty) {
          return AppPlatformRefreshScroll(
            fillViewport: true,
            onRefresh: refresh,
            child: Center(
              child: Text(
                state.errorMessage ?? context.l10n.errorTryAgain,
                style: context.captionRegular,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (state.classes.isEmpty) {
          return AppPlatformRefreshScroll(
            fillViewport: true,
            onRefresh: refresh,
            child: AppEmptyState(
              icon: AppEmptyIcons.bookings,
              title: context.l10n.emptyGroupClassesTitle,
              description: context.l10n.emptyGroupClassesDescription,
            ),
          );
        }

        final days = _groupByDate(state.classes);

        return AppPlatformRefreshListView(
          padding: padding,
          onRefresh: refresh,
          itemCount: days.length,
          separatorBuilder: (_, _) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final day = days[index];
            return AppEntrance(
              key: ValueKey('group-day-${day.first.date}'),
              delay: Duration(milliseconds: (index.clamp(0, 5)) * 70),
              offset: const Offset(0, 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    GroupClassFormat.dayHeader(day.first, locale),
                    style: context.contentBold,
                  ),
                  const SizedBox(height: 10),
                  for (final groupClass in day) ...[
                    GroupClassScheduleCard(
                      groupClass: groupClass,
                      showDay: false,
                    ),
                    if (groupClass != day.last) const SizedBox(height: 12),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Server returns classes nearest-first; keep that order within each day.
  static List<List<GroupClassEntity>> _groupByDate(
    List<GroupClassEntity> classes,
  ) {
    final byDate = <String, List<GroupClassEntity>>{};
    for (final c in classes) {
      byDate.putIfAbsent(c.date, () => []).add(c);
    }
    return byDate.values.toList();
  }
}
