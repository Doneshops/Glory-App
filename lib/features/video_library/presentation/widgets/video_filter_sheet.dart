import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/library_video_entity.dart';
import '../utils/video_category_label.dart';

typedef VideoFilters = ({VideoAudience? audience, String? category});

/// Bottom sheet to pick audience and target muscle. Resolves to the chosen
/// filters on "Show results", or `null` when dismissed.
final class VideoFilterSheet extends StatefulWidget {
  const VideoFilterSheet({
    super.key,
    required this.categories,
    required this.initial,
  });

  final List<String> categories;
  final VideoFilters initial;

  static Future<VideoFilters?> show(
    BuildContext context, {
    required List<String> categories,
    required VideoFilters initial,
  }) {
    return showModalBottomSheet<VideoFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          VideoFilterSheet(categories: categories, initial: initial),
    );
  }

  @override
  State<VideoFilterSheet> createState() => _VideoFilterSheetState();
}

final class _VideoFilterSheetState extends State<VideoFilterSheet> {
  late VideoAudience? _audience = widget.initial.audience;
  late String? _category = widget.initial.category;

  bool get _hasSelection => _audience != null || _category != null;

  void _reset() => setState(() {
    _audience = null;
    _category = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groups = VideoCategoryLabel.group(widget.categories);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _DragHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.videoFilterTitle, style: context.heading5),
                ),
                AnimatedOpacity(
                  opacity: _hasSelection ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: TextButton.icon(
                    onPressed: _hasSelection ? _reset : null,
                    icon: const Icon(Iconsax.refresh, size: 16),
                    label: Text(l10n.videoFilterReset),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.neutral600,
                      textStyle: context.captionBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.neutral200),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    icon: Iconsax.people,
                    title: l10n.videoFilterAudience,
                  ),
                  12.vertical,
                  _AudienceOptions(
                    selected: _audience,
                    onSelected: (audience) =>
                        setState(() => _audience = audience),
                  ),
                  if (groups.isNotEmpty) ...[
                    24.vertical,
                    _SectionTitle(
                      icon: Iconsax.activity,
                      title: l10n.videoFilterMuscle,
                    ),
                    for (final MapEntry(key: region, value: labels)
                        in groups.entries) ...[
                      16.vertical,
                      Text(
                        VideoCategoryLabel.regionTitle(context, region),
                        style: context.footnoteSemiboldBold.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      10.vertical,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final label in labels)
                            _SelectableChip(
                              label: label.muscle,
                              selected: _category == label.raw,
                              // Tapping the selected muscle clears it.
                              onTap: () => setState(
                                () => _category = _category == label.raw
                                    ? null
                                    : label.raw,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: AppButton(
                label: l10n.videoFilterApply,
                height: 52,
                onPressed: () => Navigator.of(
                  context,
                ).pop<VideoFilters>((audience: _audience, category: _category)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary800),
        ),
        10.horizontal,
        Text(title, style: context.contentBold),
      ],
    );
  }
}

final class _AudienceOptions extends StatelessWidget {
  const _AudienceOptions({required this.selected, required this.onSelected});

  final VideoAudience? selected;
  final ValueChanged<VideoAudience?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = <(VideoAudience?, String, IconData)>[
      (null, l10n.videoLibraryAllCategories, Iconsax.people),
      (VideoAudience.male, l10n.videoAudienceMale, Iconsax.man),
      (VideoAudience.female, l10n.videoAudienceFemale, Iconsax.woman),
    ];

    return Row(
      children: [
        for (final (index, (audience, label, icon)) in options.indexed) ...[
          if (index > 0) 10.horizontal,
          Expanded(
            child: _AudienceTile(
              label: label,
              icon: icon,
              selected: audience == selected,
              onTap: () => onSelected(audience),
            ),
          ),
        ],
      ],
    );
  }
}

final class _AudienceTile extends StatelessWidget {
  const _AudienceTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary100 : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.neutral200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.primary800 : AppColors.neutral500,
            ),
            6.vertical,
            Text(
              label,
              style: context.captionBold.copyWith(
                color: selected ? AppColors.neutral1000 : AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.neutral1000 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.neutral1000 : AppColors.neutral200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              6.horizontal,
            ],
            Text(
              label,
              style: context.captionBold.copyWith(
                color: selected ? AppColors.white : AppColors.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
