import 'package:flutter/widgets.dart';

import '../../../../core/l10n/l10n_extension.dart';

/// Server categories read "Region – Muscle" (en dash or hyphen, e.g.
/// "Lower Body – Glutes"). Splits them so the UI can group by region.
final class VideoCategoryLabel {
  const VideoCategoryLabel._(this.raw, this.region, this.muscle);

  factory VideoCategoryLabel.parse(String raw) {
    final parts = raw.split(_separator);
    if (parts.length < 2) return VideoCategoryLabel._(raw, null, raw.trim());
    return VideoCategoryLabel._(
      raw,
      parts.first.trim(),
      parts.skip(1).join(' - ').trim(),
    );
  }

  static final _separator = RegExp(r'\s+[–—-]\s+');

  /// The exact server value, sent back as the `category` filter.
  final String raw;
  final String? region;
  final String muscle;

  /// Groups [categories] by region, keeping server order within a group.
  static Map<String?, List<VideoCategoryLabel>> group(List<String> categories) {
    final groups = <String?, List<VideoCategoryLabel>>{};
    for (final category in categories) {
      final label = VideoCategoryLabel.parse(category);
      groups.putIfAbsent(label.region, () => []).add(label);
    }
    return groups;
  }

  /// Localized heading for a region; unknown regions are shown as sent.
  static String regionTitle(BuildContext context, String? region) {
    final l10n = context.l10n;
    return switch (region?.toLowerCase()) {
      null => l10n.videoRegionOther,
      'core' => l10n.videoRegionCore,
      'lower body' => l10n.videoRegionLowerBody,
      'upper body' => l10n.videoRegionUpperBody,
      _ => region!,
    };
  }
}
