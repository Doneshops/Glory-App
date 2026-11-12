import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles_extension.dart';
import '../../../../core/widgets/app_primary_header.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../domain/entities/library_video_entity.dart';
import '../widgets/vimeo_player_view.dart';

/// Watches one library video inside the app.
final class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key, required this.video});

  final LibraryVideoEntity video;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final description = languageCode == 'ar'
        ? video.descriptionAr ?? video.descriptionEn
        : video.descriptionEn ?? video.descriptionAr;
    final category = video.category;
    final duration = video.duration;
    final audienceLabel = switch (video.audience) {
      VideoAudience.male => l10n.videoAudienceMale,
      VideoAudience.female => l10n.videoAudienceFemale,
      VideoAudience.unknown => null,
    };

    return AppScaffold(
      appBar: AppPrimaryHeader(title: l10n.videoLibraryTitle),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neutral1000.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VimeoPlayerView(playerUrl: video.videoUrl),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (category != null || audienceLabel != null || duration != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (category != null)
                        _InfoChip(
                          label: category,
                          background: AppColors.primary100,
                          foreground: AppColors.primary900,
                        ),
                      if (audienceLabel != null)
                        _InfoChip(
                          icon: Iconsax.profile_2user,
                          label: audienceLabel,
                          background: AppColors.white,
                          foreground: AppColors.neutral700,
                          bordered: true,
                        ),
                      if (duration != null)
                        _InfoChip(
                          icon: Iconsax.clock,
                          label: duration,
                          background: AppColors.white,
                          foreground: AppColors.neutral700,
                          bordered: true,
                        ),
                    ],
                  ),
                ),
              Text(
                video.title(languageCode),
                style: context.heading5.copyWith(color: AppColors.neutral1000),
              ),
              if (description != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Iconsax.document_text,
                            size: 18,
                            color: AppColors.primary800,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.videoAboutTitle,
                            style: context.contentBold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: context.contentRegular.copyWith(
                          color: AppColors.neutral700,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.bordered = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: bordered ? Border.all(color: AppColors.neutral200) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: context.footnoteSemiboldBold.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
