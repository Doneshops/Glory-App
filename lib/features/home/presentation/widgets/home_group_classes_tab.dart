import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glory_gym/core/core.dart';
import 'package:glory_gym/features/group_classes/presentation/cubits/group_classes/group_classes_cubit.dart';
import 'package:glory_gym/features/group_classes/presentation/widgets/group_class_card.dart';

/// Home "الحصص الجماعية" tab — the next upcoming group classes from the
/// schedule (`GET /mobile/group-classes`). Members attend without booking.
final class HomeGroupClassesTab extends StatelessWidget {
  const HomeGroupClassesTab({super.key, this.onViewAll});

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupClassesCubit>()..load(),
      child: _HomeGroupClassesView(onViewAll: onViewAll),
    );
  }
}

final class _HomeGroupClassesView extends StatelessWidget {
  const _HomeGroupClassesView({this.onViewAll});

  static const _previewCount = 2;

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupClassesCubit>().state;
    final upcoming =
        state.upcoming(DateTime.now()).take(_previewCount).toList();

    return AppPlatformRefreshScroll(
      fillViewport: upcoming.isEmpty,
      onRefresh: () => context.read<GroupClassesCubit>().load(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppEntrance(
            delay: const Duration(milliseconds: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.groupClasses,
                  style: context.highlightBold.copyWith(
                    color: AppColors.neutral900,
                  ),
                ),
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    context.l10n.seeAll,
                    style: context.captionRegular.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (state.isLoading && state.classes.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (state.status == GroupClassesStatus.failure &&
              state.classes.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  state.errorMessage ?? context.l10n.errorTryAgain,
                  style: context.captionRegular,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (upcoming.isEmpty)
            Expanded(
              child: AppEmptyState(
                icon: AppEmptyIcons.bookings,
                title: context.l10n.emptyGroupClassesTitle,
                description: context.l10n.emptyGroupClassesDescription,
                compact: true,
              ),
            )
          else
            ...upcoming.asMap().entries.map(
                  (entry) => AppEntrance(
                    delay: Duration(milliseconds: 80 + (entry.key * 90)),
                    offset: const Offset(0, 0.07),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GroupClassScheduleCard(groupClass: entry.value),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
